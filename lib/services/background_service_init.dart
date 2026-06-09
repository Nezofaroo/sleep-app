import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import '../models/sound_event.dart';
import 'sleep_audio_trigger_service.dart';
import 'alarm_service.dart';

@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse notificationResponse) {
  final actionId = notificationResponse.actionId;
  final svc = FlutterBackgroundService();
  if (actionId == 'stop') {
    svc.invoke('stopAlarm');
  } else if (actionId == 'snooze') {
    svc.invoke('snoozeAlarm');
  }
}

Future<void> _triggerBackgroundAlarm(
    ServiceInstance service, String ringtone, double volume, bool vibrate) async {
  final alarmService = AlarmService();
  await alarmService.startRinging(
    ringtoneId: ringtone,
    volume: volume,
    vibrate: vibrate,
  );

  final FlutterLocalNotificationsPlugin notificationPlugin = FlutterLocalNotificationsPlugin();

  const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
    'sleep_ly_alarm',
    'Sleep.ly Alarm',
    channelDescription: 'Alarm notifications',
    importance: Importance.max,
    priority: Priority.high,
    ongoing: true,
    autoCancel: false,
    fullScreenIntent: true,
    showWhen: true,
    actions: <AndroidNotificationAction>[
      AndroidNotificationAction('snooze', 'Отложить', showsUserInterface: true),
      AndroidNotificationAction('stop', 'Выключить', showsUserInterface: true),
    ],
  );

  await notificationPlugin.show(
    id: 1002,
    title: 'Будильник Sleep.ly',
    body: 'Пора просыпаться!',
    notificationDetails: const NotificationDetails(android: androidDetails),
  );

  service.invoke('alarmTriggered');
}

@pragma('vm:entry-point')
Future<void> onBackgroundServiceStart(ServiceInstance service) async {
  WidgetsFlutterBinding.ensureInitialized();

  if (service is AndroidServiceInstance) {
    service.on('setAsForeground').listen((event) => service.setAsForegroundService());
    service.on('setAsBackground').listen((event) => service.setAsBackgroundService());
    service.setAsForegroundService();
  }

  await Future.delayed(const Duration(milliseconds: 1500));

  final docsDir = await getApplicationDocumentsDirectory();
  await initSoundEventHive(docsDir.path);

  // Initialize and check Hive settings box
  if (!Hive.isBoxOpen('settings')) {
    await Hive.openBox('settings');
  }
  final settingsBox = Hive.box('settings');

  final vad = SleepAudioTriggerService(service);

  try {
    final ready = await vad.initialize();
    if (!ready) {
      await Future.delayed(const Duration(seconds: 1));
      final retryReady = await vad.initialize();
      if (!retryReady) {
        service.invoke('error', {'message': 'Микрофон занят другим приложением'});
        service.stopSelf();
        return;
      }
    }

    await vad.startMonitoring();
    service.invoke('statusChanged', {'status': 'monitoring'});
    print("Background Service: Мониторинг успешно запущен");
  } catch (e) {
    service.invoke('error', {'message': 'Ошибка сервиса: $e'});
    service.stopSelf();
    return;
  }

  // Alarm Management state
  final alarmService = AlarmService();
  bool isAlarmRinging = false;
  int lastTriggeredMin = -1;

  // Start downloading default melodies in the background
  AlarmService.downloadBaseMelodies();

  // Listen to Stop Alarm event from UI or Notification
  service.on('stopAlarm').listen((_) async {
    isAlarmRinging = false;
    await alarmService.stopRinging();
    
    final FlutterLocalNotificationsPlugin notificationPlugin = FlutterLocalNotificationsPlugin();
    await notificationPlugin.cancel(id: 1002);

    final b = Hive.box('settings');
    await b.delete('snoozeAlarmTime');
    await b.delete('currentSnoozeMinutes');

    service.invoke('alarmStopped');
  });

  // Listen to Snooze Alarm event from UI or Notification
  service.on('snoozeAlarm').listen((_) async {
    isAlarmRinging = false;
    await alarmService.stopRinging();

    final FlutterLocalNotificationsPlugin notificationPlugin = FlutterLocalNotificationsPlugin();
    await notificationPlugin.cancel(id: 1002);

    final b = Hive.box('settings');
    final int defaultSnooze = b.get('snoozeMinutes', defaultValue: 10) as int;
    final bool smartSnooze = b.get('smartSnoozeEnabled', defaultValue: false) as bool;
    
    int currentSnooze = b.get('currentSnoozeMinutes', defaultValue: defaultSnooze) as int;

    final now = DateTime.now();
    final snoozeTarget = now.add(Duration(minutes: currentSnooze));
    await b.put('snoozeAlarmTime', snoozeTarget.toIso8601String());

    int nextSnooze = currentSnooze;
    if (smartSnooze) {
      nextSnooze = (currentSnooze - 5).clamp(0, 60);
      await b.put('currentSnoozeMinutes', nextSnooze);
    }

    service.invoke('alarmSnoozed', {
      'snoozeTime': snoozeTarget.toIso8601String(),
      'nextSnoozeMinutes': nextSnooze,
    });
  });

  // Periodic alarm timer checker
  Timer.periodic(const Duration(seconds: 5), (timer) async {
    if (isAlarmRinging) return;

    final b = Hive.box('settings');
    final bool alarmEnabled = b.get('alarmEnabled', defaultValue: false) as bool;
    if (!alarmEnabled) return;

    final int alarmHour = b.get('alarmHour', defaultValue: 7) as int;
    final int alarmMinute = b.get('alarmMinute', defaultValue: 0) as int;
    final String ringtone = b.get('ringtone', defaultValue: 'default') as String;
    final double alarmVolume = (b.get('alarmVolume', defaultValue: 0.7) as num).toDouble();
    final bool vibrate = b.get('vibrationEnabled', defaultValue: true) as bool;

    final now = DateTime.now();

    // Check if snooze is active
    final String? snoozeTimeStr = b.get('snoozeAlarmTime') as String?;
    if (snoozeTimeStr != null) {
      final snoozeTime = DateTime.parse(snoozeTimeStr);
      if (now.isAfter(snoozeTime) || now.isAtSameMomentAs(snoozeTime)) {
        isAlarmRinging = true;
        await _triggerBackgroundAlarm(service, ringtone, alarmVolume, vibrate);
      }
    } else {
      // Check normal alarm
      if (now.hour == alarmHour && now.minute == alarmMinute && now.minute != lastTriggeredMin) {
        lastTriggeredMin = now.minute;
        isAlarmRinging = true;
        final int defaultSnooze = b.get('snoozeMinutes', defaultValue: 10) as int;
        await b.put('currentSnoozeMinutes', defaultSnooze);
        
        await _triggerBackgroundAlarm(service, ringtone, alarmVolume, vibrate);
      }
    }
  });

  service.on('stopMonitoring').listen((_) async {
    isAlarmRinging = false;
    await alarmService.stopRinging();
    final FlutterLocalNotificationsPlugin notificationPlugin = FlutterLocalNotificationsPlugin();
    await notificationPlugin.cancel(id: 1002);
    
    await vad.stopAll();
    service.stopSelf();
  });

  service.on('ping').listen((_) => service.invoke('pong', {}));
}

@pragma('vm:entry-point')
Future<bool> onIosBackground(ServiceInstance service) async {
  WidgetsFlutterBinding.ensureInitialized();
  return true;
}

Future<void> configureBackgroundService() async {
  final svc = FlutterBackgroundService();

  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'sleep_tracker_audio',
    'Sleep Tracker Service',
    description: 'This channel is used for recording sleep sounds.',
    importance: Importance.low,
  );

  // High importance channel for alarm notifications (heads-up)
  const AndroidNotificationChannel alarmChannel = AndroidNotificationChannel(
    'sleep_ly_alarm',
    'Sleep.ly Alarm',
    description: 'This channel is used for alarm notifications.',
    importance: Importance.max,
    playSound: false, // sound played manually via audioplayers
  );

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(alarmChannel);

  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );

  await flutterLocalNotificationsPlugin.initialize(
    settings: initializationSettings,
    onDidReceiveNotificationResponse: (details) {
      final actionId = details.actionId;
      final backgroundSvc = FlutterBackgroundService();
      if (actionId == 'stop') {
        backgroundSvc.invoke('stopAlarm');
      } else if (actionId == 'snooze') {
        backgroundSvc.invoke('snoozeAlarm');
      }
    },
    onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
  );

  await svc.configure(
    androidConfiguration: AndroidConfiguration(
      onStart: onBackgroundServiceStart,
      autoStart: false,
      isForegroundMode: true,
      notificationChannelId: 'sleep_tracker_audio',
      initialNotificationTitle: 'Трекер сна',
      initialNotificationContent: 'Готов к работе...',
      foregroundServiceNotificationId: 2001,
      foregroundServiceTypes: const [AndroidForegroundType.microphone],
    ),
    iosConfiguration: IosConfiguration(
      autoStart: false,
      onForeground: onBackgroundServiceStart,
      onBackground: onIosBackground,
    ),
  );
}

Future<void> startSnoreDetectionService() async {
  final service = FlutterBackgroundService();

  if (await service.isRunning()) {
    service.invoke('stopMonitoring');
    await Future.delayed(const Duration(milliseconds: 500));
  }
  await service.startService();
}

Future<void> stopSnoreDetectionService() async {
  FlutterBackgroundService().invoke('stopMonitoring');
}

Future<bool> isSnoreDetectionRunning() async {
  return FlutterBackgroundService().isRunning();
}
