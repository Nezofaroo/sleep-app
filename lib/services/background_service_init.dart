import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
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

Future<void> _showBedtimeNotification(String title, String body) async {
  final FlutterLocalNotificationsPlugin notificationPlugin = FlutterLocalNotificationsPlugin();

  const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
    'sleep_ly_bedtime',
    'Sleep.ly Bedtime Reminders',
    channelDescription: 'Bedtime notifications',
    importance: Importance.high,
    priority: Priority.high,
    showWhen: true,
  );

  await notificationPlugin.show(
    id: 2003,
    title: title,
    body: body,
    notificationDetails: const NotificationDetails(android: androidDetails),
  );
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

  final vad = SleepAudioTriggerService(service);

  // Setup startMonitoring listener
  service.on('startMonitoring').listen((_) async {
    try {
      final ready = await vad.initialize();
      if (ready) {
        await vad.startMonitoring();
        if (service is AndroidServiceInstance) {
          service.setForegroundNotificationInfo(
            title: 'Трекер сна',
            content: 'Запись звука и анализ дыхания...',
          );
        }
        service.invoke('statusChanged', {'status': 'monitoring'});
      } else {
        service.invoke('error', {'message': 'Микрофон занят другим приложением'});
      }
    } catch (e) {
      service.invoke('error', {'message': 'Ошибка запуска мониторинга: $e'});
    }
  });

  if (service is AndroidServiceInstance) {
    service.setForegroundNotificationInfo(
      title: 'Sleep.ly',
      content: 'Служба активна в фоновом режиме',
    );
  }

  // Alarm Management state
  final alarmService = AlarmService();
  bool isAlarmRinging = false;
  DateTime? lastAlarmTriggeredTime;
  DateTime? lastBedtimeTriggeredTime;
  DateTime? lastPreBedtimeTriggeredTime;

  // Listen to Settings updates from main isolate
  service.on('updateSettings').listen((event) async {
    if (event != null) {
      final b = Hive.box('settings');
      for (final entry in event.entries) {
        if (entry.value == null) {
          await b.delete(entry.key);
        } else {
          await b.put(entry.key, entry.value);
        }
      }
      lastAlarmTriggeredTime = null;
      lastBedtimeTriggeredTime = null;
      lastPreBedtimeTriggeredTime = null;
    }
  });

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

  // Periodic alarm and bedtime reminder checker
  Timer.periodic(const Duration(seconds: 5), (timer) async {
    final b = Hive.box('settings');
    final now = DateTime.now();

    // 1. Bedtime Reminder Check
    final bool bedtimeReminderEnabled = b.get('bedtimeReminderEnabled', defaultValue: false) as bool;
    if (bedtimeReminderEnabled) {
      final int bedtimeHour = b.get('bedtimeHour', defaultValue: 23) as int;
      final int bedtimeMinute = b.get('bedtimeMinute', defaultValue: 0) as int;
      final int reminderOffsetHours = b.get('reminderOffsetHours', defaultValue: 0) as int;
      final int reminderOffsetMinutes = b.get('reminderOffsetMinutes', defaultValue: 30) as int;

      final nowMinutes = now.hour * 60 + now.minute;
      final targetMinutes = bedtimeHour * 60 + bedtimeMinute;
      final totalOffsetMinutes = reminderOffsetHours * 60 + reminderOffsetMinutes;

      // Check pre-bedtime reminder
      if (totalOffsetMinutes > 0) {
        final preMinutes = (targetMinutes - totalOffsetMinutes) % 1440;
        if (nowMinutes == preMinutes) {
          final lastTriggered = lastPreBedtimeTriggeredTime;
          if (lastTriggered == null || now.difference(lastTriggered).inMinutes >= 2) {
            lastPreBedtimeTriggeredTime = now;
            String offsetText = '';
            if (reminderOffsetHours > 0 && reminderOffsetMinutes > 0) {
              offsetText = '$reminderOffsetHours ч. $reminderOffsetMinutes мин.';
            } else if (reminderOffsetHours > 0) {
              offsetText = '$reminderOffsetHours ч.';
            } else {
              offsetText = '$reminderOffsetMinutes мин.';
            }
            await _showBedtimeNotification(
              'Скоро пора спать 🌙',
              'До вашего целевого времени сна осталось $offsetText. Пора готовиться ко сну!',
            );
          }
        }
      }

      // Check bedtime reminder
      if (nowMinutes == targetMinutes) {
        final lastTriggered = lastBedtimeTriggeredTime;
        if (lastTriggered == null || now.difference(lastTriggered).inMinutes >= 2) {
          lastBedtimeTriggeredTime = now;
          await _showBedtimeNotification(
            'Время спать 💤',
            'Наступило ваше целевое время сна. Желаем вам спокойной ночи и приятных снов!',
          );
        }
      }
    }

    // 2. Alarm Check
    if (!isAlarmRinging) {
      final bool alarmEnabled = b.get('alarmEnabled', defaultValue: false) as bool;
      if (alarmEnabled) {
        final int alarmHour = b.get('alarmHour', defaultValue: 7) as int;
        final int alarmMinute = b.get('alarmMinute', defaultValue: 0) as int;
        final String ringtone = b.get('ringtone', defaultValue: 'default') as String;
        final double alarmVolume = (b.get('alarmVolume', defaultValue: 0.7) as num).toDouble();
        final bool vibrate = b.get('vibrationEnabled', defaultValue: true) as bool;

        // Check if snooze is active
        final String? snoozeTimeStr = b.get('snoozeAlarmTime') as String?;
        if (snoozeTimeStr != null) {
          try {
            final snoozeTime = DateTime.parse(snoozeTimeStr);
            if (now.isAfter(snoozeTime) || now.isAtSameMomentAs(snoozeTime)) {
              isAlarmRinging = true;
              await _triggerBackgroundAlarm(service, ringtone, alarmVolume, vibrate);
            }
          } catch (e) {
            print("Background Service: Error parsing snoozeAlarmTime: $e");
            await b.delete('snoozeAlarmTime');
          }
        } else {
          // Check normal alarm
          if (now.hour == alarmHour && now.minute == alarmMinute) {
            final lastTriggered = lastAlarmTriggeredTime;
            if (lastTriggered == null || now.difference(lastTriggered).inMinutes >= 2) {
              lastAlarmTriggeredTime = now;
              isAlarmRinging = true;
              final int defaultSnooze = b.get('snoozeMinutes', defaultValue: 10) as int;
              await b.put('currentSnoozeMinutes', defaultSnooze);
              
              await _triggerBackgroundAlarm(service, ringtone, alarmVolume, vibrate);
            }
          }
        }
      }
    }
  });

  service.on('stopMonitoring').listen((_) async {
    isAlarmRinging = false;
    await alarmService.stopRinging();
    final FlutterLocalNotificationsPlugin notificationPlugin = FlutterLocalNotificationsPlugin();
    await notificationPlugin.cancel(id: 1002);
    
    await vad.stopAll();
    if (service is AndroidServiceInstance) {
      service.setForegroundNotificationInfo(
        title: 'Sleep.ly',
        content: 'Служба активна в фоновом режиме',
      );
    }
    service.invoke('statusChanged', {'status': 'idle'});
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

  // Channel for bedtime reminders
  const AndroidNotificationChannel bedtimeChannel = AndroidNotificationChannel(
    'sleep_ly_bedtime',
    'Sleep.ly Bedtime Reminders',
    description: 'This channel is used for bedtime reminders.',
    importance: Importance.high,
    playSound: true,
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

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(bedtimeChannel);

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
      autoStart: true,
      isForegroundMode: true,
      notificationChannelId: 'sleep_tracker_audio',
      initialNotificationTitle: 'Sleep.ly',
      initialNotificationContent: 'Служба активна в фоновом режиме',
      foregroundServiceNotificationId: 2001,
      foregroundServiceTypes: const [AndroidForegroundType.microphone],
    ),
    iosConfiguration: IosConfiguration(
      autoStart: false,
      onForeground: onBackgroundServiceStart,
      onBackground: onIosBackground,
    ),
  );

  final isRunning = await svc.isRunning();
  if (!isRunning) {
    await svc.startService();
  }
}

Future<void> startSnoreDetectionService() async {
  final service = FlutterBackgroundService();
  final isRunning = await service.isRunning();

  final b = Hive.box('settings');
  await b.put('isTrackingActive', true);

  if (!isRunning) {
    await service.startService();
    await Future.delayed(const Duration(milliseconds: 500));
  }
  service.invoke('startMonitoring');
}

Future<void> stopSnoreDetectionService() async {
  final b = Hive.box('settings');
  await b.put('isTrackingActive', false);

  FlutterBackgroundService().invoke('stopMonitoring');
}

Future<bool> isSnoreDetectionRunning() async {
  return FlutterBackgroundService().isRunning();
}
