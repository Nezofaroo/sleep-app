import 'dart:async';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:hive/hive.dart';
import 'package:record/record.dart';
import 'package:uuid/uuid.dart';
import '../models/sound_event.dart';
import 'audio_cache_manager.dart';

// ── VAD state machine ─────────────────────────────────────────────────────────
enum _VADState { idle, monitoring, recording, cooldown }

/// Core Voice Activity Detection service.
///
/// Architectural decisions:
/// • Uses `record` package's [AudioRecorder] for both amplitude polling
///   (via startStream → onAmplitudeChanged) and file recording.
/// • Two-phase approach: phase-1 = stream-only for detection,
///   phase-2 = file recording when threshold exceeded.
///   This avoids storing 8 h of continuous audio.
/// • Runs entirely inside the background service isolate so the OS
///   cannot kill it when the screen is locked.
/// • Communicates events to the UI isolate via [ServiceInstance.invoke].
class SleepAudioTriggerService {
  // ── Constants ────────────────────────────────────────────────────────────
  static const double kThresholdDb   = -35.0; // dBFS; tune per device
  static const Duration kPollInterval = Duration(milliseconds: 250);
  static const Duration kCooldown     = Duration(milliseconds: 1500);
  static const Duration kMinDuration  = Duration(seconds: 1);

  // ── Dependencies ─────────────────────────────────────────────────────────
  final ServiceInstance _service;
  final AudioRecorder   _recorder = AudioRecorder();
  final _uuid = const Uuid();

  // ── Mutable state ─────────────────────────────────────────────────────────
  _VADState _state          = _VADState.idle;
  DateTime? _recordingStart;
  double    _peakAmplitude  = -160.0;
  Timer?    _cooldownTimer;
  StreamSubscription<Amplitude>? _ampSub;

  SleepAudioTriggerService(this._service);

  // ── Public API ────────────────────────────────────────────────────────────

  /// Initialise: purge old cache files, verify permissions.
  Future<bool> initialize() async {
    await AudioCacheManager.purgeOldFiles();
    final hasPermission = await _recorder.hasPermission();
    if (!hasPermission) {
      _service.invoke('error', {'message': 'Microphone permission denied'});
      return false;
    }
    return true;
  }

  /// Start the detection loop (transitions idle → monitoring).
  Future<void> startMonitoring() async {
    if (_state != _VADState.idle) return;
    await _beginListening();
  }

  /// Stop everything and clean up resources.
  Future<void> stopAll() async {
    _cooldownTimer?.cancel();
    _cooldownTimer = null;
    await _ampSub?.cancel();
    _ampSub = null;
    if (await _recorder.isRecording()) {
      await _recorder.stop(); // discard any in-progress recording
    }
    _state = _VADState.idle;
    _service.invoke('statusChanged', {'status': 'idle'});
  }

  // ── Phase 1: amplitude-only monitoring ───────────────────────────────────

  Future<void> _beginListening() async {
    _state = _VADState.monitoring;
    _service.invoke('statusChanged', {'status': 'monitoring'});

    try {
      // Start recording to a stream (audio bytes discarded — we only need amplitude).
      await _recorder.startStream(const RecordConfig(
        encoder: AudioEncoder.pcm16bits,
        sampleRate: 16000,
        numChannels: 1,
      ));

      // Subscribe to amplitude events at our poll interval.
      _ampSub = _recorder
          .onAmplitudeChanged(kPollInterval)
          .listen(_onAmplitude, onError: _onAmpError);
    } catch (e) {
      _service.invoke('error', {'message': 'Failed to start mic stream: $e'});
    }
  }

  // ── Amplitude handler (state machine core) ────────────────────────────────

  void _onAmplitude(Amplitude amp) {
    final db = amp.current;

    switch (_state) {
      case _VADState.monitoring:
        if (db > kThresholdDb) {
          _transitionToRecording();
        }
        break;

      case _VADState.recording:
        if (db > _peakAmplitude) _peakAmplitude = db;
        if (db <= kThresholdDb) {
          _startCooldown();
        }
        break;

      case _VADState.cooldown:
        if (db > kThresholdDb) {
          // Sound resumed — cancel cooldown, stay in recording.
          _cooldownTimer?.cancel();
          _cooldownTimer = null;
          _state = _VADState.recording;
          if (db > _peakAmplitude) _peakAmplitude = db;
        }
        break;

      case _VADState.idle:
        break;
    }
  }

  void _onAmpError(Object error) {
    _service.invoke('error', {'message': 'Amplitude stream error: $error'});
    // Attempt restart after a short delay.
    Future.delayed(const Duration(seconds: 2), () {
      if (_state != _VADState.idle) _beginListening();
    });
  }

  // ── Phase 2: switch to file recording ─────────────────────────────────────

  Future<void> _transitionToRecording() async {
    _state = _VADState.recording;
    _peakAmplitude = kThresholdDb;
    _recordingStart = DateTime.now();

    // Stop the stream recording first.
    await _ampSub?.cancel();
    _ampSub = null;
    try {
      await _recorder.stop();
    } catch (_) {}

    // Start recording to a real file.
    final path = await AudioCacheManager.newRecordingPath();
    try {
      await _recorder.start(
        const RecordConfig(
          encoder: AudioEncoder.aacLc,
          bitRate: 64000,
          sampleRate: 22050,
          numChannels: 1,
        ),
        path: path,
      );

      // Re-subscribe to amplitude while recording to the file.
      _ampSub = _recorder
          .onAmplitudeChanged(kPollInterval)
          .listen(_onAmplitude, onError: _onAmpError);

      _service.invoke('statusChanged', {'status': 'recording', 'path': path});
    } catch (e) {
      _service.invoke('error', {'message': 'Failed to start file recording: $e'});
      await _beginListening(); // fall back to monitoring
    }
  }

  // ── Cooldown → save ───────────────────────────────────────────────────────

  void _startCooldown() {
    _state = _VADState.cooldown;
    _cooldownTimer?.cancel();
    _cooldownTimer = Timer(kCooldown, _finishRecording);
  }

  Future<void> _finishRecording() async {
    _cooldownTimer = null;
    final start = _recordingStart ?? DateTime.now();
    final durationSec = DateTime.now().difference(start).inSeconds;

    // Discard very short noise bursts (< kMinDuration).
    if (durationSec < kMinDuration.inSeconds) {
      await _discardCurrentRecording();
      await _beginListening();
      return;
    }

    // Stop recorder and retrieve the saved file path.
    String? savedPath;
    try {
      await _ampSub?.cancel();
      _ampSub = null;
      savedPath = await _recorder.stop();
    } catch (e) {
      _service.invoke('error', {'message': 'Failed to stop recorder: $e'});
    }

    if (savedPath != null) {
      await _persistEvent(savedPath, start, durationSec);
    }

    // Always restart monitoring, even on error.
    await _beginListening();
  }

  Future<void> _discardCurrentRecording() async {
    try {
      await _ampSub?.cancel();
      _ampSub = null;
      final path = await _recorder.stop();
      if (path != null) await AudioCacheManager.deleteFile(path);
    } catch (_) {}
  }

  // ── Hive persistence + UI notification ───────────────────────────────────

  Future<void> _persistEvent(
      String filePath, DateTime start, int durationSec) async {
    final type = SoundEventTypeExt.fromDuration(durationSec);
    final event = SoundEvent(
      id:              _uuid.v4(),
      filePath:        filePath,
      startTime:       start,
      durationSeconds: durationSec,
      typeIndex:       type.index,
      peakAmplitude:   _peakAmplitude,
    );

    try {
      final box = Hive.box<SoundEvent>(kSoundEventBoxName);
      await box.put(event.id, event);
    } catch (e) {
      _service.invoke('error', {'message': 'Hive write error: $e'});
    }

    // Notify the UI isolate so it can refresh the timeline.
    _service.invoke('newEvent', {
      'id':              event.id,
      'filePath':        event.filePath,
      'startTime':       event.startTime.millisecondsSinceEpoch,
      'durationSeconds': event.durationSeconds,
      'typeIndex':       event.typeIndex,
      'peakAmplitude':   event.peakAmplitude,
    });
  }
}
