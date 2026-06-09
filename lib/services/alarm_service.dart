import 'dart:async';
import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

class AlarmService {
  static final AlarmService _instance = AlarmService._internal();
  factory AlarmService() => _instance;
  AlarmService._internal();

  AudioPlayer? _audioPlayer;
  Timer? _vibrationTimer;
  bool _isRinging = false;

  bool get isRinging => _isRinging;

  // Stable default URLs for built-in ringtones
  static const Map<String, String> _ringtoneUrls = {
    'gentle': 'https://actions.google.com/sounds/v1/alarms/digital_watch_alarm_long.ogg',
    'chime': 'https://assets.mixkit.co/active_storage/sfx/2568/2568-84.wav',
    'nature': 'https://actions.google.com/sounds/v1/nature/forest_morning_birds.ogg',
    'digital': 'https://actions.google.com/sounds/v1/alarms/digital_watch_alarm_long.ogg',
    'piano': 'https://actions.google.com/sounds/v1/alarms/mechanical_clock_ring.ogg',
  };

  /// Asynchronously download base alarm sounds if they are not already cached
  static Future<void> downloadBaseMelodies() async {
    try {
      final docsDir = await getApplicationDocumentsDirectory();
      final client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 10);

      for (final entry in _ringtoneUrls.entries) {
        final ext = entry.key == 'chime' ? 'wav' : 'ogg';
        final file = File('${docsDir.path}/${entry.key}.$ext');
        
        if (!await file.exists()) {
          try {
            final request = await client.getUrl(Uri.parse(entry.value));
            final response = await request.close();
            if (response.statusCode == 200) {
              await response.pipe(file.openWrite());
              print("AlarmService: Downloaded default melody '${entry.key}'");
            }
          } catch (e) {
            print("AlarmService: Error downloading melody '${entry.key}': $e");
          }
        }
      }
      client.close();
    } catch (e) {
      print("AlarmService: Error initializing background downloader: $e");
    }
  }

  /// Get the appropriate audio source path for the ringtone
  static Future<String> getRingtonePath(String ringtoneId) async {
    final docsDir = await getApplicationDocumentsDirectory();
    
    if (ringtoneId == 'custom') {
      final box = Hive.box('settings');
      final customPath = box.get('customRingtonePath') as String?;
      if (customPath != null && await File(customPath).exists()) {
        return customPath;
      }
    }
    
    // Check locally downloaded file
    final ext = ringtoneId == 'chime' ? 'wav' : 'ogg';
    final localFile = File('${docsDir.path}/$ringtoneId.$ext');
    if (await localFile.exists()) {
      return localFile.path;
    }

    // Fallback to URL or system default
    return _ringtoneUrls[ringtoneId] ?? 'content://settings/system/alarm_alert';
  }

  /// Start playing the alarm ringtone and vibrating continuously
  Future<void> startRinging({
    required String ringtoneId,
    required double volume,
    required bool vibrate,
  }) async {
    if (_isRinging) return;
    _isRinging = true;

    // 1. Play Alarm Sound
    try {
      _audioPlayer = AudioPlayer();
      await _audioPlayer!.setReleaseMode(ReleaseMode.loop);
      
      final audioPath = await getRingtonePath(ringtoneId);
      Source source;
      if (audioPath.startsWith('http') || audioPath.startsWith('content://')) {
        source = UrlSource(audioPath);
      } else {
        source = DeviceFileSource(audioPath);
      }
      
      await _audioPlayer!.setVolume(volume);
      await _audioPlayer!.play(source);
    } catch (e) {
      print("AlarmService: Failed to play ringtone: $e. Falling back to system default.");
      try {
        await _audioPlayer?.stop();
        _audioPlayer = AudioPlayer();
        await _audioPlayer!.setReleaseMode(ReleaseMode.loop);
        await _audioPlayer!.setVolume(volume);
        await _audioPlayer!.play(UrlSource('content://settings/system/alarm_alert'));
      } catch (ex) {
        print("AlarmService: Deep fallback failed: $ex");
      }
    }

    // 2. Start Vibration loop (vibrates once per second)
    if (vibrate) {
      _vibrationTimer?.cancel();
      _vibrationTimer = Timer.periodic(const Duration(milliseconds: 1000), (timer) {
        HapticFeedback.vibrate();
      });
      // Trigger first vibration immediately
      HapticFeedback.vibrate();
    }
  }

  /// Stop the alarm sound and vibration
  Future<void> stopRinging() async {
    if (!_isRinging) return;
    _isRinging = false;

    _vibrationTimer?.cancel();
    _vibrationTimer = null;

    try {
      if (_audioPlayer != null) {
        await _audioPlayer!.stop();
        await _audioPlayer!.dispose();
        _audioPlayer = null;
      }
    } catch (e) {
      print("AlarmService: Error stopping audio player: $e");
    }
  }
}
