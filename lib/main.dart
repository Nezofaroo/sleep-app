import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import 'theme/neumorphic_theme.dart';
import 'theme/dark_velvet_theme.dart';

import 'theme/app_colors.dart';
import 'pages/tracker_page.dart';
import 'pages/discover_page.dart';
import 'pages/statistics_page.dart';
import 'pages/profile_page.dart';
import 'pages/login_page.dart';
import 'models/sound_event.dart';
import 'services/background_service_init.dart';
import 'providers/alarm_settings_provider.dart';
import 'providers/sleep_audio_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initializeDateFormatting('ru_RU');




  await [
    Permission.microphone,
    Permission.notification,
  ].request();



  final docsDir = await getApplicationDocumentsDirectory();
  await initSoundEventHive(docsDir.path);

  final settingsBox = await Hive.openBox('settings');
  if (!settingsBox.containsKey('registered_users')) {
    await settingsBox.put('registered_users', {
      'user@sleep.ly': 'password123'
    });
  }


  await configureBackgroundService();


  final alarmProvider = AlarmSettingsProvider();
  final audioProvider = SleepAudioProvider();

  runApp(SleepTrackerApp(
    alarmProvider: alarmProvider,
    audioProvider: audioProvider,
  ));
}

class SleepTrackerApp extends StatelessWidget {
  final AlarmSettingsProvider alarmProvider;
  final SleepAudioProvider    audioProvider;

  const SleepTrackerApp({
    super.key,
    required this.alarmProvider,
    required this.audioProvider,
  });

  @override
  Widget build(BuildContext context) {


    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF060B18),
      systemNavigationBarIconBrightness: Brightness.light,
    ));
    return MaterialApp(
      title: 'Sleep.ly',
      debugShowCheckedModeBanner: false,
      theme: NeumorphicTheme.theme,
      darkTheme: DarkVelvetTheme.theme,
      themeMode: ThemeMode.dark,
      home: AuthWrapper(
        alarmProvider: alarmProvider,
        audioProvider: audioProvider,
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  final AlarmSettingsProvider alarmProvider;
  final SleepAudioProvider    audioProvider;

  const AuthWrapper({
    super.key,
    required this.alarmProvider,
    required this.audioProvider,
  });

  @override
  Widget build(BuildContext context) {
    final bool isLoggedIn = Hive.box('settings').get('is_logged_in', defaultValue: false);
    if (isLoggedIn) {
      return MainShell(
        alarmProvider: alarmProvider,
        audioProvider: audioProvider,
      );
    } else {
      return LoginPage(
        alarmProvider: alarmProvider,
        audioProvider: audioProvider,
      );
    }
  }
}




class MainShell extends StatefulWidget {
  final AlarmSettingsProvider alarmProvider;
  final SleepAudioProvider    audioProvider;

  const MainShell({
    super.key,
    required this.alarmProvider,
    required this.audioProvider,
  });

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  static const List<_NavItem> _navItems = [
    _NavItem(icon: Icons.bedtime_outlined,       activeIcon: Icons.bedtime_rounded,       label: 'Трекер'),
    _NavItem(icon: Icons.explore_outlined,       activeIcon: Icons.explore_rounded,       label: 'Открыть'),
    _NavItem(icon: Icons.bar_chart_outlined,     activeIcon: Icons.bar_chart_rounded,     label: 'Статистика'),
    _NavItem(icon: Icons.person_outline_rounded, activeIcon: Icons.person_rounded,        label: 'Профиль'),
  ];

  void _onTap(int i) {
    HapticFeedback.selectionClick();
    setState(() => _currentIndex = i);
  }

  @override
  Widget build(BuildContext context) {


    final pages = [
      TrackerPage(
        alarmProvider: widget.alarmProvider,
        audioProvider: widget.audioProvider,
      ),
      const DiscoverPage(),
      StatisticsPage(audioProvider: widget.audioProvider),
      ProfilePage(
        alarmProvider: widget.alarmProvider,
        audioProvider: widget.audioProvider,
      ),
    ];

    return Scaffold(
      backgroundColor: AppColors.of(context).background,
      body: IndexedStack(index: _currentIndex, children: pages),
      bottomNavigationBar: _NavBar(
        currentIndex: _currentIndex,
        items: _navItems,
        onTap: _onTap,
      ),
    );
  }
}

class _NavBar extends StatelessWidget {
  final int currentIndex;
  final List<_NavItem> items;
  final ValueChanged<int> onTap;
  const _NavBar({required this.currentIndex, required this.items, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return Container(
      decoration: BoxDecoration(
        color: c.background,
        boxShadow: [
          BoxShadow(
              color: c.shadowDark.withValues(alpha: c.isDark ? 0.9 : 1.0),
              offset: const Offset(0, -4),
              blurRadius: 16),
          BoxShadow(
              color: c.shadowLight.withValues(alpha: c.isDark ? 0.04 : 1.0),
              offset: const Offset(0, -1),
              blurRadius: 4),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 68,
          child: Row(
            children: List.generate(items.length, (i) {
              final item = items[i];
              final active = i == currentIndex;
              final iconColor = active ? c.navActive : c.textSecondary;
              return Expanded(
                child: GestureDetector(
                  onTap: () => onTap(i),
                  behavior: HitTestBehavior.opaque,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.all(8),
                        decoration: active
                            ? BoxDecoration(
                          color: c.navActive.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                        )
                            : null,
                        child: Icon(
                          active ? item.activeIcon : item.icon,
                          color: iconColor,
                          size: 22,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(item.label,
                          style: GoogleFonts.montserrat(
                            fontSize: 10,
                            fontWeight:
                            active ? FontWeight.w700 : FontWeight.w500,
                            color: iconColor,
                          )),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  const _NavItem({required this.icon, required this.activeIcon, required this.label});
}