import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:hive/hive.dart';
import 'package:permission_handler/permission_handler.dart'; // Добавлено
import '../models/sound_event.dart';
import '../services/background_service_init.dart';

/// Possible states shown in the UI.
enum MonitoringStatus { idle, monitoring, recording, error }

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
      final event = SoundEvent(
        id:              data['id']              as String,
        filePath:        data['filePath']        as String,
        startTime:       DateTime.fromMillisecondsSinceEpoch(
            data['startTime']     as int),
        durationSeconds: data['durationSeconds'] as int,
        typeIndex:       data['typeIndex']       as int,
        peakAmplitude:   (data['peakAmplitude']  as num).toDouble(),
      );
      _events.insert(0, event);
      notifyListeners();
    });

    _errorSub = svc.on('error').listen((data) {
      _errorMsg = data?['message'] as String?;
      _status   = MonitoringStatus.error;
      notifyListeners();
    });
  }

  // ── Public controls ───────────────────────────────────────────────────────

  /// ИСПРАВЛЕНО: Теперь запрашивает разрешения ПЕРЕД запуском сервиса.
  Future<void> startMonitoring() async {
    _errorMsg = null;

    // 1. Сначала запрашиваем разрешения в UI-потоке
    final micStatus = await Permission.microphone.request();
    final notifyStatus = await Permission.notification.request();

    if (micStatus.isGranted && notifyStatus.isGranted) {
      _status = MonitoringStatus.monitoring;
      notifyListeners();

      // Даем небольшую паузу, чтобы системные диалоги закрылись
      await Future.delayed(const Duration(milliseconds: 300));

      await startSnoreDetectionService();
    } else {
      _errorMsg = "Необходимы разрешения на микрофон и уведомления";
      _status = MonitoringStatus.error;
      notifyListeners();
    }
  }

  Future<void> stopMonitoring() async {
    await stopSnoreDetectionService();
    _status = MonitoringStatus.idle;
    notifyListeners();
  }

  Future<void> deleteEvent(SoundEvent event) async {
    _events.remove(event);
    notifyListeners();
    try {
      if (Hive.isBoxOpen(kSoundEventBoxName)) {
        await Hive.box<SoundEvent>(kSoundEventBoxName).delete(event.id);
      }
    } catch (_) {}
  }

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