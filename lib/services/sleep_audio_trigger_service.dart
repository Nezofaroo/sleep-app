import 'dart:async';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:hive/hive.dart';
import 'package:record/record.dart';
import 'package:uuid/uuid.dart';
import '../models/sound_event.dart';
import 'audio_cache_manager.dart';


enum _VADState { idle, monitoring, recording, cooldown }

class SleepAudioTriggerService {

  static const double kThresholdDb   = -35.0;
  static const Duration kPollInterval = Duration(milliseconds: 250);
  static const Duration kCooldown     = Duration(milliseconds: 1500);
  static const Duration kMinDuration  = Duration(seconds: 1);


  final ServiceInstance _service;

  final AudioRecorder   _recorder = AudioRecorder();
  final _uuid = const Uuid();


  _VADState _state          = _VADState.idle;
  DateTime? _recordingStart;
  double    _peakAmplitude  = -160.0;
  Timer?    _cooldownTimer;
  StreamSubscription<Amplitude>? _ampSub;

  SleepAudioTriggerService(this._service);




  Future<bool> initialize() async {
    try {
      await AudioCacheManager.purgeOldFiles();


      if (await _recorder.isRecording()) {
        await _recorder.stop();
      }





      return true;
    } catch (e) {
      _service.invoke('error', {'message': 'Ошибка инициализации аудио: $e'});
      return false;
    }
  }


  Future<void> startMonitoring() async {
    if (_state != _VADState.idle) return;
    await _beginListening();
  }


  Future<void> stopAll() async {
    _cooldownTimer?.cancel();
    _cooldownTimer = null;
    await _ampSub?.cancel();
    _ampSub = null;
    try {
      if (await _recorder.isRecording()) {
        await _recorder.stop();
      }
    } catch (_) {}
    _state = _VADState.idle;
    _service.invoke('statusChanged', {'status': 'idle'});
  }



  Future<void> _beginListening() async {
    _state = _VADState.monitoring;
    _service.invoke('statusChanged', {'status': 'monitoring'});

    try {

      await _ampSub?.cancel();

      await _recorder.startStream(const RecordConfig(
        encoder: AudioEncoder.pcm16bits,
        sampleRate: 16000,
        numChannels: 1,
      ));

      _ampSub = _recorder
          .onAmplitudeChanged(kPollInterval)
          .listen(_onAmplitude, onError: _onAmpError);
    } catch (e) {

      _service.invoke('error', {'message': 'Не удалось захватить микрофон: $e'});
      _state = _VADState.idle;
    }
  }




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
    _service.invoke('error', {'message': 'Ошибка потока аудио: $error'});
    Future.delayed(const Duration(seconds: 2), () {
      if (_state != _VADState.idle) _beginListening();
    });
  }

  Future<void> _transitionToRecording() async {
    _state = _VADState.recording;
    _peakAmplitude = kThresholdDb;
    _recordingStart = DateTime.now();

    await _ampSub?.cancel();
    _ampSub = null;
    try {
      await _recorder.stop();
    } catch (_) {}

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

      _ampSub = _recorder
          .onAmplitudeChanged(kPollInterval)
          .listen(_onAmplitude, onError: _onAmpError);

      _service.invoke('statusChanged', {'status': 'recording', 'path': path});
    } catch (e) {
      _service.invoke('error', {'message': 'Ошибка записи в файл: $e'});
      await _beginListening();
    }
  }

  void _startCooldown() {
    _state = _VADState.cooldown;
    _cooldownTimer?.cancel();
    _cooldownTimer = Timer(kCooldown, _finishRecording);
  }

  Future<void> _finishRecording() async {
    _cooldownTimer = null;
    final start = _recordingStart ?? DateTime.now();
    final durationSec = DateTime.now().difference(start).inSeconds;

    if (durationSec < kMinDuration.inSeconds) {
      await _discardCurrentRecording();
      await _beginListening();
      return;
    }

    String? savedPath;
    try {
      await _ampSub?.cancel();
      _ampSub = null;
      savedPath = await _recorder.stop();
    } catch (e) {
      _service.invoke('error', {'message': 'Ошибка остановки записи: $e'});
    }

    if (savedPath != null) {
      await _persistEvent(savedPath, start, durationSec);
    }

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
      _service.invoke('error', {'message': 'Ошибка Hive: $e'});
    }

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