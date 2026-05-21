import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'theme/cyberpunk_theme.dart';
import 'pages/tracker_page.dart';
import 'pages/discover_page.dart';
import 'pages/statistics_page.dart';
import 'pages/profile_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: Color(0xFF080E14),
    systemNavigationBarIconBrightness: Brightness.light,
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
      theme: CyberpunkTheme.theme,
      home: const MainShell(),
    );
  }
}

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    TrackerPage(),
    DiscoverPage(),
    StatisticsPage(),
    ProfilePage(),
  ];

  final List<_NavItem> _navItems = const [
    _NavItem(
      icon: Icons.bedtime_outlined,
      activeIcon: Icons.bedtime,
      label: 'TRACKER',
      activeColor: CyberpunkColors.neonCyan,
    ),
    _NavItem(
      icon: Icons.explore_outlined,
      activeIcon: Icons.explore,
      label: 'DISCOVER',
      activeColor: CyberpunkColors.neonGreen,
    ),
    _NavItem(
      icon: Icons.bar_chart_outlined,
      activeIcon: Icons.bar_chart,
      label: 'STATS',
      activeColor: CyberpunkColors.neonPurple,
    ),
    _NavItem(
      icon: Icons.person_outline,
      activeIcon: Icons.person,
      label: 'PROFILE',
      activeColor: CyberpunkColors.neonYellow,
    ),
  ];

  void _onNavTap(int index) {
    HapticFeedback.selectionClick();
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CyberpunkColors.background,
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: _CyberpunkNavBar(
        currentIndex: _currentIndex,
        items: _navItems,
        onTap: _onNavTap,
      ),
    );
  }
}

class _CyberpunkNavBar extends StatelessWidget {
  final int currentIndex;
  final List<_NavItem> items;
  final ValueChanged<int> onTap;

  const _CyberpunkNavBar({
    required this.currentIndex,
    required this.items,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF080E14),
        border: const Border(
          top: BorderSide(color: Color(0xFF1A3040), width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: items[currentIndex].activeColor.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            children: List.generate(items.length, (i) {
              final item = items[i];
              final isActive = i == currentIndex;
              return Expanded(
                child: GestureDetector(
                  onTap: () => onTap(i),
                  behavior: HitTestBehavior.opaque,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeInOut,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          child: Icon(
                            isActive ? item.activeIcon : item.icon,
                            key: ValueKey(isActive),
                            color: isActive
                                ? item.activeColor
                                : CyberpunkColors.textSecondary,
                            size: 22,
                            shadows: isActive
                                ? neonGlow(item.activeColor)
                                    .map((s) => Shadow(
                                          color: s.color,
                                          blurRadius: s.blurRadius,
                                        ))
                                    .toList()
                                : [],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.label,
                          style: GoogleFonts.orbitron(
                            fontSize: 8,
                            color: isActive
                                ? item.activeColor
                                : CyberpunkColors.textSecondary,
                            letterSpacing: 1,
                            fontWeight: isActive
                                ? FontWeight.w700
                                : FontWeight.w400,
                            shadows:
                                isActive ? neonGlow(item.activeColor) : [],
                          ),
                        ),
                        const SizedBox(height: 2),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          height: 2,
                          width: isActive ? 20 : 0,
                          decoration: BoxDecoration(
                            color: item.activeColor,
                            borderRadius: BorderRadius.circular(1),
                            boxShadow: isActive
                                ? [
                                    BoxShadow(
                                      color:
                                          item.activeColor.withOpacity(0.8),
                                      blurRadius: 6,
                                    ),
                                  ]
                                : [],
                          ),
                        ),
                      ],
                    ),
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
  final Color activeColor;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.activeColor,
  });
}
