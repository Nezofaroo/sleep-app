import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';
import 'settings_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});
  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _notifications = true;
  bool _smartAlarm   = false;
  bool _haptics      = true;
  double _targetSleep = 8.0;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return Scaffold(
      backgroundColor: c.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildHero(c),
              const SizedBox(height: 24),
              _buildXpCard(c),
              const SizedBox(height: 24),
              _buildSection('Sleep Goal', [_buildSleepSlider(c)], c),
              _buildSection('Settings', [
                _buildSwitchRow(
                  icon: Icons.notifications_outlined,
                  label: 'Sleep Reminders',
                  subtitle: 'Notify 30 min before bedtime',
                  value: _notifications,
                  onChanged: (v) => setState(() => _notifications = v),
                  c: c,
                ),
                _buildDivider(c),
                _buildSwitchRow(
                  icon: Icons.alarm_on_outlined,
                  label: 'Smart Alarm',
                  subtitle: 'Wake during lightest sleep phase',
                  value: _smartAlarm,
                  onChanged: (v) => setState(() => _smartAlarm = v),
                  c: c,
                ),
                _buildDivider(c),
                _buildSwitchRow(
                  icon: Icons.vibration_rounded,
                  label: 'Haptic Feedback',
                  subtitle: 'Vibrate on interactions',
                  value: _haptics,
                  onChanged: (v) => setState(() => _haptics = v),
                  c: c,
                ),
              ], c),
              _buildSection('Account', [
                _buildNavRow(icon: Icons.person_outline_rounded, label: 'Edit Profile', c: c),
                _buildDivider(c),
                _buildNavRow(icon: Icons.share_outlined, label: 'Export Sleep Data', c: c),
                _buildDivider(c),
                _buildNavRow(icon: Icons.info_outline_rounded, label: 'About', c: c),
                _buildDivider(c),
                _buildNavRow(
                    icon: Icons.logout_rounded,
                    label: 'Sign Out',
                    c: c,
                    isDestructive: true),
              ], c),
              const SizedBox(height: 12),
              Text('Sleep Tracker v1.0.0',
                  style: GoogleFonts.montserrat(
                      fontSize: 11, color: c.textDisabled)),
              const SizedBox(height: 28),
            ],
          ),
        ),
      ),
    );
  }

  // ── Hero ──────────────────────────────────────────────────────────────────
  Widget _buildHero(AppColors c) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Profile',
                  style: GoogleFonts.montserrat(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: c.textPrimary)),
              GestureDetector(
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (_) => const SettingsPage()),
                ),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: c.cardRaised(radius: 14),
                  child: Icon(Icons.settings_outlined,
                      color: c.textSecondary, size: 20),
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              Container(
                width: 100, height: 100,
                decoration: c.avatarDecoration(),
                child: Icon(Icons.person_rounded,
                    size: 54,
                    color: c.isDark
                        ? c.textPrimary.withValues(alpha: 0.95)
                        : const Color(0xFFFFFFFF)),
              ),
              Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: c.isDark ? c.cardBg : c.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: c.accent.withValues(alpha: 0.4), width: 1),
                  boxShadow: [
                    BoxShadow(
                        color: c.shadowDark.withValues(alpha: 0.5),
                        blurRadius: 6),
                  ],
                ),
                child: Icon(Icons.edit_rounded, size: 13, color: c.accent),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text('CYBER_SLEEPER_01',
              style: GoogleFonts.montserrat(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: c.textPrimary)),
          const SizedBox(height: 4),
          Text('Neural Optimization Level: 7',
              style: GoogleFonts.montserrat(
                  fontSize: 13, color: c.textSecondary)),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8, runSpacing: 8,
            alignment: WrapAlignment.center,
            children: [
              _badge('NIGHT OWL', c),
              _badge('7-DAY STREAK', c),
              _badge('DEEP DIVER', c),
            ],
          ),
        ],
      ),
    );
  }

  Widget _badge(String label, AppColors c) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: c.tagDecoration(radius: 30),
      child: Text(label,
          style: GoogleFonts.montserrat(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: c.tagText,
              letterSpacing: 0.5)),
    );
  }

  // ── XP card ───────────────────────────────────────────────────────────────
  Widget _buildXpCard(AppColors c) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: c.cardRaised(radius: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: c.iconBadge(radius: 10),
                      child: Icon(Icons.bolt_rounded, color: c.accent, size: 18),
                    ),
                    const SizedBox(width: 12),
                    Text('Sleep XP',
                        style: GoogleFonts.montserrat(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: c.textPrimary)),
                  ],
                ),
                Text('2,450 / 3,000',
                    style: GoogleFonts.montserrat(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: c.accent)),
              ],
            ),
            const SizedBox(height: 14),
            // Progress track
            Container(
              height: 10,
              decoration: BoxDecoration(
                color: c.progressBg,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                      color: c.shadowDark.withValues(alpha: 0.5),
                      offset: const Offset(2, 2),
                      blurRadius: 4),
                  BoxShadow(
                      color: c.shadowLight.withValues(alpha: c.isDark ? 0.04 : 1.0),
                      offset: const Offset(-2, -2),
                      blurRadius: 4),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: 0.82,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: c.progressGradient),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text('550 XP to next level',
                style: GoogleFonts.montserrat(
                    fontSize: 12, color: c.textSecondary)),
          ],
        ),
      ),
    );
  }

  // ── Section wrapper ────────────────────────────────────────────────────────
  Widget _buildSection(String title, List<Widget> children, AppColors c) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: GoogleFonts.montserrat(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: c.textPrimary)),
          const SizedBox(height: 12),
          Container(
            decoration: c.cardRaised(radius: 20),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Column(children: children),
            ),
          ),
        ],
      ),
    );
  }

  // ── Sleep slider ──────────────────────────────────────────────────────────
  Widget _buildSleepSlider(AppColors c) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(children: [
                Icon(Icons.bedtime_outlined, color: c.accent, size: 20),
                const SizedBox(width: 10),
                Text('Target Duration',
                    style: GoogleFonts.montserrat(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: c.textPrimary)),
              ]),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: c.accentButton(radius: 30),
                child: Text('${_targetSleep.toStringAsFixed(1)}h',
                    style: GoogleFonts.montserrat(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: c.white)),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 9),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 18),
              // Dark velvet: add amber glow to thumb via overlay color
              overlayColor: c.isDark
                  ? const Color(0xFFD4A84B).withValues(alpha: 0.20)
                  : c.accent.withValues(alpha: 0.15),
            ),
            child: Slider(
              value: _targetSleep,
              min: 4, max: 12, divisions: 16,
              onChanged: (v) => setState(() => _targetSleep = v),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('4h', style: GoogleFonts.montserrat(fontSize: 11, color: c.textDisabled)),
              Text('8h (optimal)', style: GoogleFonts.montserrat(fontSize: 11, color: c.textDisabled)),
              Text('12h', style: GoogleFonts.montserrat(fontSize: 11, color: c.textDisabled)),
            ],
          ),
        ],
      ),
    );
  }

  // ── Switch row ────────────────────────────────────────────────────────────
  Widget _buildSwitchRow({
    required IconData icon,
    required String label,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required AppColors c,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: c.iconBadge(radius: 10),
            child: Icon(icon, color: c.accent, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: GoogleFonts.montserrat(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: c.textPrimary)),
                Text(subtitle,
                    style: GoogleFonts.montserrat(
                        fontSize: 12, color: c.textSecondary)),
              ],
            ),
          ),
          Switch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }

  // ── Nav row ───────────────────────────────────────────────────────────────
  Widget _buildNavRow({
    required IconData icon,
    required String label,
    required AppColors c,
    bool isDestructive = false,
  }) {
    final color = isDestructive ? const Color(0xFFE57373) : c.accent;
    return GestureDetector(
      onTap: () {},
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(label,
                  style: GoogleFonts.montserrat(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isDestructive ? const Color(0xFFE57373) : c.textPrimary)),
            ),
            Icon(Icons.arrow_forward_ios_rounded,
                size: 14, color: c.textDisabled),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider(AppColors c) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Divider(color: c.divider, thickness: 1, height: 1),
      );
}
