import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:hive/hive.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/sound_event.dart';
import '../services/background_service_init.dart';


enum MonitoringStatus { idle, monitoring, recording, error }

class SleepAudioProvider extends ChangeNotifier {

  MonitoringStatus _status   = MonitoringStatus.idle;
  String?          _errorMsg;
  final List<SoundEvent> _events = [];

  MonitoringStatus get status   => _status;
  String?          get errorMsg => _errorMsg;
  List<SoundEvent> get events   => List.unmodifiable(_events);
  bool get isActive =>
      _status == MonitoringStatus.monitoring ||
      _status == MonitoringStatus.recording;


  final AudioPlayer _audioPlayer = AudioPlayer();


  String? _currentlyPlayingId;
  String? get currentlyPlayingId => _currentlyPlayingId;


  double? _playProgress;
  double? get playProgress => _playProgress;

  StreamSubscription? _positionSub;
  StreamSubscription? _completeSub;
  StreamSubscription? _durationSub;
  Duration?           _trackDuration;


  StreamSubscription? _statusSub;
  StreamSubscription? _eventSub;
  StreamSubscription? _errorSub;

  SleepAudioProvider() {
    _loadFromHive();
    _listenToService();
    _initPlayerListeners();
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


  void _initPlayerListeners() {

    _positionSub = _audioPlayer.onPositionChanged.listen((pos) {
      if (_trackDuration != null && _trackDuration!.inMilliseconds > 0) {
        _playProgress =
            pos.inMilliseconds / _trackDuration!.inMilliseconds;
        notifyListeners();
      }
    });


    _durationSub = _audioPlayer.onDurationChanged.listen((dur) {
      _trackDuration = dur;
    });


    _completeSub = _audioPlayer.onPlayerComplete.listen((_) {
      _currentlyPlayingId = null;
      _playProgress       = null;
      _trackDuration      = null;
      notifyListeners();
    });
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



  Future<void> startMonitoring() async {
    _errorMsg = null;

    final micStatus    = await Permission.microphone.request();
    final notifyStatus = await Permission.notification.request();

    if (micStatus.isGranted && notifyStatus.isGranted) {
      _status = MonitoringStatus.monitoring;
      notifyListeners();
      await Future.delayed(const Duration(milliseconds: 300));
      await startSnoreDetectionService();
    } else {
      _errorMsg = 'Необходимы разрешения на микрофон и уведомления';
      _status   = MonitoringStatus.error;
      notifyListeners();
    }
  }

  Future<void> stopMonitoring() async {
    await stopSnoreDetectionService();
    _status = MonitoringStatus.idle;
    notifyListeners();
  }






  Future<void> playEvent(SoundEvent event) async {
    if (_currentlyPlayingId == event.id) {

      final state = _audioPlayer.state;
      if (state == PlayerState.playing) {
        await _audioPlayer.pause();
      } else {
        await _audioPlayer.resume();
      }
      return;
    }


    await _audioPlayer.stop();
    _currentlyPlayingId = event.id;
    _playProgress       = 0.0;
    _trackDuration      = null;
    notifyListeners();

    try {
      await _audioPlayer.play(DeviceFileSource(event.filePath));
    } catch (_) {
      _currentlyPlayingId = null;
      _playProgress       = null;
      notifyListeners();
    }
  }


  Future<void> stopPlayback() async {
    await _audioPlayer.stop();
    _currentlyPlayingId = null;
    _playProgress       = null;
    _trackDuration      = null;
    notifyListeners();
  }


  bool isPlaying(String eventId) =>
      _currentlyPlayingId == eventId &&
      _audioPlayer.state == PlayerState.playing;



  Future<void> deleteEvent(SoundEvent event) async {

    if (_currentlyPlayingId == event.id) {
      await stopPlayback();
    }
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

  Future<void> deleteEvents(List<SoundEvent> eventsToDelete) async {
    for (final event in eventsToDelete) {
      if (_currentlyPlayingId == event.id) {
        await stopPlayback();
      }
      _events.remove(event);
    }
    notifyListeners();
    try {
      if (Hive.isBoxOpen(kSoundEventBoxName)) {
        final box = Hive.box<SoundEvent>(kSoundEventBoxName);
        for (final event in eventsToDelete) {
          await box.delete(event.id);
        }
      }
    } catch (_) {}
  }


  List<SoundEvent> get allRecords {
    if (!Hive.isBoxOpen(kSoundEventBoxName)) return const [];
    return Hive.box<SoundEvent>(kSoundEventBoxName)
        .values
        .toList()
        ..sort((a, b) => b.startTime.compareTo(a.startTime));
  }

  @override
  void dispose() {
    _statusSub?.cancel();
    _eventSub?.cancel();
    _errorSub?.cancel();
    _positionSub?.cancel();
    _durationSub?.cancel();
    _completeSub?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }
}