import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
// Добавляем импорт для разрешений
import 'package:permission_handler/permission_handler.dart';

import 'theme/neumorphic_theme.dart';
import 'theme/dark_velvet_theme.dart';
import 'theme/theme_notifier.dart';
import 'theme/app_colors.dart';
import 'pages/tracker_page.dart';
import 'pages/discover_page.dart';
import 'pages/statistics_page.dart';
import 'pages/profile_page.dart';
import 'models/sound_event.dart';
import 'services/background_service_init.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // --- БЛОК ЗАПРОСА РАЗРЕШЕНИЙ ---
  // Запрашиваем разрешения перед инициализацией сервиса.
  // Это предотвратит вылет на Android 13/14+.
  await [
    Permission.microphone,
    Permission.notification,
  ].request();
  // -------------------------------

  // Initialise Hive for the UI isolate.
  final docsDir = await getApplicationDocumentsDirectory();
  await initSoundEventHive(docsDir.path);

  // Register background service handlers (must be called before runApp).
  // Теперь вызывается только после того, как разрешения получены или запрошены.
  await configureBackgroundService();

  runApp(const SleepTrackerApp());
}

class SleepTrackerApp extends StatelessWidget {
  const SleepTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (context, mode, child) {
        final isDark = mode == ThemeMode.dark;
        SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness:
          isDark ? Brightness.light : Brightness.dark,
          systemNavigationBarColor:
          isDark ? const Color(0xFF12121A) : NeumorphicColors.background,
          systemNavigationBarIconBrightness:
          isDark ? Brightness.light : Brightness.dark,
        ));
        return MaterialApp(
          title: 'Sleep Tracker',
          debugShowCheckedModeBanner: false,
          theme: NeumorphicTheme.theme,
          darkTheme: DarkVelvetTheme.theme,
          themeMode: mode,
          home: const MainShell(),
        );
      },
    );
  }
}

// Остальной код MainShell, _NavBar и т.д. остается без изменений
// ── Main shell with bottom nav ────────────────────────────────────────────────
class MainShell extends StatefulWidget {
  const MainShell({super.key});
  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  static const List<Widget> _pages = [
    TrackerPage(),
    DiscoverPage(),
    StatisticsPage(),
    ProfilePage(),
  ];

  static const List<_NavItem> _navItems = [
    _NavItem(icon: Icons.bedtime_outlined,      activeIcon: Icons.bedtime_rounded,      label: 'Tracker'),
    _NavItem(icon: Icons.explore_outlined,      activeIcon: Icons.explore_rounded,      label: 'Discover'),
    _NavItem(icon: Icons.bar_chart_outlined,    activeIcon: Icons.bar_chart_rounded,    label: 'Stats'),
    _NavItem(icon: Icons.person_outline_rounded,activeIcon: Icons.person_rounded,       label: 'Profile'),
  ];

  void _onTap(int i) {
    HapticFeedback.selectionClick();
    setState(() => _currentIndex = i);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.of(context).background,
      body: IndexedStack(index: _currentIndex, children: _pages),
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