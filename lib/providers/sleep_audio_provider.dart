import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:hive/hive.dart';
import '../models/sound_event.dart';
import '../services/background_service_init.dart';

/// Possible states shown in the UI.
enum MonitoringStatus { idle, monitoring, recording, error }

/// ChangeNotifier that bridges the background service ↔ UI.
///
/// The provider:
/// 1. Loads existing events from Hive on creation.
/// 2. Starts/stops the background service.
/// 3. Listens to [FlutterBackgroundService] events and updates state.
/// 4. Exposes sorted [events] list for the timeline widget.
class SleepAudioProvider extends ChangeNotifier {
  // ── State ─────────────────────────────────────────────────────────────────
  MonitoringStatus _status    = MonitoringStatus.idle;
  String?          _errorMsg;
  final List<SoundEvent> _events = [];

  MonitoringStatus get status   => _status;
  String?          get errorMsg => _errorMsg;
  List<SoundEvent> get events   => List.unmodifiable(_events);
  bool get isActive =>
      _status == MonitoringStatus.monitoring ||
      _status == MonitoringStatus.recording;

  // ── Background service subscriptions ─────────────────────────────────────
  StreamSubscription? _statusSub;
  StreamSubscription? _eventSub;
  StreamSubscription? _errorSub;

  SleepAudioProvider() {
    _loadFromHive();
    _listenToService();
  }

  // ── Hive ──────────────────────────────────────────────────────────────────
  void _loadFromHive() {
    try {
      if (Hive.isBoxOpen(kSoundEventBoxName)) {
        final box = Hive.box<SoundEvent>(kSoundEventBoxName);
        _events
          ..clear()
          ..addAll(box.values.toList()
            ..sort((a, b) => b.startTime.compareTo(a.startTime)));
        notifyListeners();
      }
    } catch (_) {}
  }

  // ── Background service event listeners ────────────────────────────────────
  void _listenToService() {
    final svc = FlutterBackgroundService();

    _statusSub = svc.on('statusChanged').listen((data) {
      if (data == null) return;
      final raw = data['status'] as String? ?? 'idle';
      _status = switch (raw) {
        'monitoring' => MonitoringStatus.monitoring,
        'recording'  => MonitoringStatus.recording,
        _            => MonitoringStatus.idle,
      };
      notifyListeners();
    });

    _eventSub = svc.on('newEvent').listen((data) {
      if (data == null) return;
      // Reconstruct event from IPC map (Hive object from background isolate
      // is not directly accessible in the UI isolate).
      final event = SoundEvent(
        id:              data['id']              as String,
        filePath:        data['filePath']        as String,
        startTime:       DateTime.fromMillisecondsSinceEpoch(
                           data['startTime']     as int),
        durationSeconds: data['durationSeconds'] as int,
        typeIndex:       data['typeIndex']       as int,
        peakAmplitude:   (data['peakAmplitude']  as num).toDouble(),
      );
      _events.insert(0, event); // prepend so newest is first
      notifyListeners();
    });

    _errorSub = svc.on('error').listen((data) {
      _errorMsg = data?['message'] as String?;
      _status   = MonitoringStatus.error;
      notifyListeners();
    });
  }

  // ── Public controls ───────────────────────────────────────────────────────

  /// Start background monitoring. Requests permissions lazily (the service
  /// itself calls [AudioRecorder.hasPermission] and reports via 'error').
  Future<void> startMonitoring() async {
    _errorMsg = null;
    _status   = MonitoringStatus.monitoring;
    notifyListeners();
    await startSnoreDetectionService();
  }

  Future<void> stopMonitoring() async {
    await stopSnoreDetectionService();
    _status = MonitoringStatus.idle;
    notifyListeners();
  }

  /// Remove an event from the in-memory list and delete its file.
  Future<void> deleteEvent(SoundEvent event) async {
    _events.remove(event);
    notifyListeners();
    // Hive deletion must happen in the UI isolate's own box.
    try {
      if (Hive.isBoxOpen(kSoundEventBoxName)) {
        await Hive.box<SoundEvent>(kSoundEventBoxName).delete(event.id);
      }
    } catch (_) {}
  }

  /// Clear all events for the current session.
  void clearEvents() {
    _events.clear();
    notifyListeners();
  }

  @override
  void dispose() {
    _statusSub?.cancel();
    _eventSub?.cancel();
    _errorSub?.cancel();
    super.dispose();
  }
}
