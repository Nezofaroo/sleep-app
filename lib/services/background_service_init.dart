import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:path_provider/path_provider.dart';
import '../models/sound_event.dart';
import 'sleep_audio_trigger_service.dart';

// ── Background isolate entry-point ────────────────────────────────────────────
// IMPORTANT: These must be top-level functions annotated with
// @pragma('vm:entry-point') so the AOT compiler doesn't tree-shake them.

@pragma('vm:entry-point')
Future<void> onBackgroundServiceStart(ServiceInstance service) async {
  // Ensure Flutter bindings are available in the background isolate.
  WidgetsFlutterBinding.ensureInitialized();

  // Initialise Hive in this isolate (separate from the UI isolate).
  final docsDir = await getApplicationDocumentsDirectory();
  await initSoundEventHive(docsDir.path);

  // Build and initialise the VAD service.
  final vad = SleepAudioTriggerService(service);
  final ready = await vad.initialize();
  if (!ready) {
    service.stopSelf();
    return;
  }

  // Start monitoring immediately.
  await vad.startMonitoring();

  // Listen for stop commands from the UI isolate.
  service.on('stopMonitoring').listen((_) async {
    await vad.stopAll();
    service.stopSelf();
  });

  // Keep the service alive with a heartbeat (required on some Android OEMs).
  service.on('ping').listen((_) => service.invoke('pong', {}));
}

@pragma('vm:entry-point')
Future<bool> onIosBackground(ServiceInstance service) async {
  WidgetsFlutterBinding.ensureInitialized();
  return true; // Keep service alive in iOS background
}

// ── One-time configuration (call from main()) ─────────────────────────────────
Future<void> configureBackgroundService() async {
  final svc = FlutterBackgroundService();

  await svc.configure(
    // ── Android: runs as a Foreground Service with mic access ────────────────
    androidConfiguration: AndroidConfiguration(
      onStart: onBackgroundServiceStart,
      autoStart: false,
      isForegroundMode: true,
      // Channel and notification ID for the persistent notification.
      notificationChannelId: 'sleep_tracker_audio',
      initialNotificationTitle: 'Sleep Tracker',
      initialNotificationContent: 'Listening for sleep sounds…',
      foregroundServiceNotificationId: 2001,
      // Required on Android 14+ to access mic in foreground service.
      foregroundServiceTypes: const [AndroidForegroundType.microphone],
    ),
    // ── iOS: uses background audio session ───────────────────────────────────
    iosConfiguration: IosConfiguration(
      autoStart: false,
      onForeground: onBackgroundServiceStart,
      onBackground: onIosBackground,
    ),
  );
}

// ── Convenience helpers ───────────────────────────────────────────────────────
Future<void> startSnoreDetectionService() async {
  await FlutterBackgroundService().startService();
}

Future<void> stopSnoreDetectionService() async {
  FlutterBackgroundService().invoke('stopMonitoring');
}

Future<bool> isSnoreDetectionRunning() async {
  return FlutterBackgroundService().isRunning();
}
