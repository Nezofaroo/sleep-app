import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'theme/neumorphic_theme.dart';
import 'theme/dark_velvet.dart';
import 'pages/tracker_page.dart';
import 'pages/discover_page.dart';
import 'pages/statistics_page.dart';
import 'pages/profile_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
    systemNavigationBarColor: NeumorphicColors.background,
    systemNavigationBarIconBrightness: Brightness.dark,
  ));
  runApp(const SleepTrackerApp());
}

class SleepTrackerApp extends StatelessWidget {
  const SleepTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sleep Tracker',
      debugShowCheckedModeBanner: false,
      theme: NeumorphicTheme.theme,
      home: const MainShell(),
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────
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
    _NavItem(
      icon: Icons.bedtime_outlined,
      activeIcon: Icons.bedtime_rounded,
      label: 'Tracker',
    ),
    _NavItem(
      icon: Icons.explore_outlined,
      activeIcon: Icons.explore_rounded,
      label: 'Discover',
    ),
    _NavItem(
      icon: Icons.bar_chart_outlined,
      activeIcon: Icons.bar_chart_rounded,
      label: 'Stats',
    ),
    _NavItem(
      icon: Icons.person_outline_rounded,
      activeIcon: Icons.person_rounded,
      label: 'Profile',
    ),
  ];

  void _onTap(int i) {
    HapticFeedback.selectionClick();
    setState(() => _currentIndex = i);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NeumorphicColors.background,
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: _NeumorphicNavBar(
        currentIndex: _currentIndex,
        items: _navItems,
        onTap: _onTap,
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────
class _NeumorphicNavBar extends StatelessWidget {
  final int currentIndex;
  final List<_NavItem> items;
  final ValueChanged<int> onTap;

  const _NeumorphicNavBar({
    required this.currentIndex,
    required this.items,
    required this.onTap,
  });

  // Profile tab (index 3) uses the dark velvet palette
  bool get _isDark => currentIndex == 3;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: _isDark ? DV.navBg : NeumorphicColors.background,
        border: Border(
          top: BorderSide(
            color: _isDark
                ? DV.border
                : NeumorphicColors.shadowDark.withValues(alpha: 0.6),
            width: 1,
          ),
        ),
        boxShadow: _isDark
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.5),
                  blurRadius: 20,
                  offset: const Offset(0, -4),
                ),
              ]
            : [
                const BoxShadow(
                  color: NeumorphicColors.shadowDark,
                  offset: Offset(0, -4),
                  blurRadius: 16,
                ),
                const BoxShadow(
                  color: NeumorphicColors.shadowLight,
                  offset: Offset(0, -1),
                  blurRadius: 4,
                ),
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

              // Colors adapt to dark/light mode
              final activeColor = _isDark ? DV.amber : NeumorphicColors.coral;
              final inactiveColor =
                  _isDark ? DV.navInactive : NeumorphicColors.textSecondary;

              return Expanded(
                child: GestureDetector(
                  onTap: () => onTap(i),
                  behavior: HitTestBehavior.opaque,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Icon with optional active bg / amber glow
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.all(8),
                        decoration: active
                            ? BoxDecoration(
                                color: _isDark
                                    ? DV.amber.withValues(alpha: 0.10)
                                    : NeumorphicColors.coral
                                        .withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: _isDark && active
                                    ? [
                                        BoxShadow(
                                          color: DV.amber
                                              .withValues(alpha: 0.20),
                                          blurRadius: 12,
                                          spreadRadius: 2,
                                        ),
                                      ]
                                    : null,
                              )
                            : null,
                        child: Icon(
                          active ? item.activeIcon : item.icon,
                          color: active ? activeColor : inactiveColor,
                          size: 22,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item.label,
                        style: GoogleFonts.montserrat(
                          fontSize: 10,
                          fontWeight:
                              active ? FontWeight.w700 : FontWeight.w500,
                          color: active ? activeColor : inactiveColor,
                        ),
                      ),
                      // Amber glow indicator dot (dark mode only, active only)
                      const SizedBox(height: 2),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: active && _isDark ? 18 : 0,
                        height: active && _isDark ? 2 : 0,
                        decoration: BoxDecoration(
                          color: DV.amber,
                          borderRadius: BorderRadius.circular(2),
                          boxShadow: [
                            BoxShadow(
                              color: DV.amberGlow.withValues(alpha: 0.6),
                              blurRadius: 6,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                      ),
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
  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}
