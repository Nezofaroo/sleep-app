import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:path_provider/path_provider.dart';
import '../models/sound_event.dart';
import 'sleep_audio_trigger_service.dart';

// ── Background isolate entry-point ────────────────────────────────────────────
@pragma('vm:entry-point')
Future<void> onBackgroundServiceStart(ServiceInstance service) async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. СРАЗУ закрепляем статус Foreground
  if (service is AndroidServiceInstance) {
    // Устанавливаем обработчики переключения
    service.on('setAsForeground').listen((event) => service.setAsForegroundService());
    service.on('setAsBackground').listen((event) => service.setAsBackgroundService());

    // ПРИНУДИТЕЛЬНО активируем режим перед любой работой с аудио
    service.setAsForegroundService();
  }

  // 2. КРИТИЧЕСКАЯ ЗАДЕРЖКА (1.5 - 2 секунды)
  // Даем Android 14 время "увидеть" Foreground статус и разрешить микрофон в фоне
  await Future.delayed(const Duration(milliseconds: 1500));

  final docsDir = await getApplicationDocumentsDirectory();
  await initSoundEventHive(docsDir.path);

  final vad = SleepAudioTriggerService(service);

  try {
    // 3. Пытаемся инициализироваться
    final ready = await vad.initialize();

    if (!ready) {
      // Если вернулось false (занято), пробуем еще раз через секунду
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

  service.on('stopMonitoring').listen((_) async {
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

// ── One-time configuration ───────────────────────────────────────────────────
Future<void> configureBackgroundService() async {
  final svc = FlutterBackgroundService();

  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'sleep_tracker_audio',
    'Sleep Tracker Service',
    description: 'This channel is used for recording sleep sounds.',
    importance: Importance.low,
  );

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
      AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

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

// ── Convenience helpers ───────────────────────────────────────────────────────
Future<void> startSnoreDetectionService() async {
  final service = FlutterBackgroundService();
  // Если сервис уже запущен, сначала пробуем его остановить, чтобы освободить микрофон
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
