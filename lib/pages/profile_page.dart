import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/neumorphic_theme.dart';

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
    return Scaffold(
      backgroundColor: NeumorphicColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildHero(),
              const SizedBox(height: 24),
              _buildXpCard(),
              const SizedBox(height: 24),
              _buildSection('Sleep Goal', [_buildSleepSlider()]),
              _buildSection('Settings', [
                _buildSwitchRow(
                  icon: Icons.notifications_outlined,
                  label: 'Sleep Reminders',
                  subtitle: 'Notify 30 min before bedtime',
                  value: _notifications,
                  onChanged: (v) => setState(() => _notifications = v),
                ),
                _buildDivider(),
                _buildSwitchRow(
                  icon: Icons.alarm_on_outlined,
                  label: 'Smart Alarm',
                  subtitle: 'Wake during lightest sleep phase',
                  value: _smartAlarm,
                  onChanged: (v) => setState(() => _smartAlarm = v),
                ),
                _buildDivider(),
                _buildSwitchRow(
                  icon: Icons.vibration_rounded,
                  label: 'Haptic Feedback',
                  subtitle: 'Vibrate on interactions',
                  value: _haptics,
                  onChanged: (v) => setState(() => _haptics = v),
                ),
              ]),
              _buildSection('Account', [
                _buildNavRow(
                  icon: Icons.person_outline_rounded,
                  label: 'Edit Profile',
                ),
                _buildDivider(),
                _buildNavRow(
                  icon: Icons.share_outlined,
                  label: 'Export Sleep Data',
                ),
                _buildDivider(),
                _buildNavRow(
                  icon: Icons.info_outline_rounded,
                  label: 'About',
                ),
                _buildDivider(),
                _buildNavRow(
                  icon: Icons.logout_rounded,
                  label: 'Sign Out',
                  isDestructive: true,
                ),
              ]),
              const SizedBox(height: 12),
              Text(
                'Sleep Tracker v1.0.0',
                style: GoogleFonts.montserrat(
                  fontSize: 11,
                  color: NeumorphicColors.textDisabled,
                ),
              ),
              const SizedBox(height: 28),
            ],
          ),
        ),
      ),
    );
  }

  // ── Hero / avatar section ──────────────────────────────────────────────────
  Widget _buildHero() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      child: Column(
        children: [
          // Header row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Profile',
                style: GoogleFonts.montserrat(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: NeumorphicColors.textPrimary,
                ),
              ),
              GestureDetector(
                onTap: () {},
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: neumorphicRaised(radius: 14),
                  child: const Icon(
                    Icons.settings_outlined,
                    color: NeumorphicColors.textSecondary,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),

          // Avatar
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFFFF9B72), Color(0xFFFF6030)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: NeumorphicColors.coral.withOpacity(0.35),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                    const BoxShadow(
                      color: NeumorphicColors.shadowLight,
                      blurRadius: 10,
                      offset: Offset(-6, -6),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.person_rounded,
                  size: 54,
                  color: NeumorphicColors.white,
                ),
              ),
              // Edit badge
              Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: NeumorphicColors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: NeumorphicColors.shadowDark.withOpacity(0.6),
                      blurRadius: 6,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.edit_rounded,
                  size: 13,
                  color: NeumorphicColors.coral,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Name & level
          Text(
            'Cyber Sleeper',
            style: GoogleFonts.montserrat(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: NeumorphicColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Optimization Level 7',
            style: GoogleFonts.montserrat(
              fontSize: 13,
              color: NeumorphicColors.textSecondary,
            ),
          ),
          const SizedBox(height: 14),

          // Badges (coral tags)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: [
              _badge('NIGHT OWL'),
              _badge('7-DAY STREAK'),
              _badge('DEEP DIVER'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _badge(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: NeumorphicColors.coral.withOpacity(0.12),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: NeumorphicColors.coral.withOpacity(0.35),
          width: 1,
        ),
      ),
      child: Text(
        label,
        style: GoogleFonts.montserrat(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: NeumorphicColors.coral,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  // ── XP progress card ───────────────────────────────────────────────────────
  Widget _buildXpCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: neumorphicRaised(radius: 20),
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
                      decoration: BoxDecoration(
                        color: NeumorphicColors.coral.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.bolt_rounded,
                          color: NeumorphicColors.coral, size: 18),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Sleep XP',
                      style: GoogleFonts.montserrat(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: NeumorphicColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                Text(
                  '2,450 / 3,000',
                  style: GoogleFonts.montserrat(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: NeumorphicColors.coral,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Progress track (neumorphic pressed container)
            Container(
              height: 10,
              decoration: BoxDecoration(
                color: NeumorphicColors.chartBg,
                borderRadius: BorderRadius.circular(10),
                boxShadow: const [
                  BoxShadow(
                    color: NeumorphicColors.shadowDark,
                    offset: Offset(2, 2),
                    blurRadius: 4,
                  ),
                  BoxShadow(
                    color: NeumorphicColors.shadowLight,
                    offset: Offset(-2, -2),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: 0.82,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFF9B72), Color(0xFFFF6030)],
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              '550 XP to next level',
              style: GoogleFonts.montserrat(
                fontSize: 12,
                color: NeumorphicColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Section wrapper ────────────────────────────────────────────────────────
  Widget _buildSection(String title, List<Widget> children) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.montserrat(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: NeumorphicColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            decoration: neumorphicRaised(radius: 20),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Column(children: children),
            ),
          ),
        ],
      ),
    );
  }

  // ── Sleep slider ───────────────────────────────────────────────────────────
  Widget _buildSleepSlider() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Target Duration',
                style: GoogleFonts.montserrat(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: NeumorphicColors.textPrimary,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: coralButtonDecoration(radius: 30),
                child: Text(
                  '${_targetSleep.toStringAsFixed(1)}h',
                  style: GoogleFonts.montserrat(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: NeumorphicColors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Slider(
            value: _targetSleep,
            min: 4,
            max: 12,
            divisions: 16,
            onChanged: (v) => setState(() => _targetSleep = v),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('4h',
                  style: GoogleFonts.montserrat(
                      fontSize: 11, color: NeumorphicColors.textDisabled)),
              Text('8h (optimal)',
                  style: GoogleFonts.montserrat(
                      fontSize: 11, color: NeumorphicColors.textDisabled)),
              Text('12h',
                  style: GoogleFonts.montserrat(
                      fontSize: 11, color: NeumorphicColors.textDisabled)),
            ],
          ),
        ],
      ),
    );
  }

  // ── Setting row with switch ────────────────────────────────────────────────
  Widget _buildSwitchRow({
    required IconData icon,
    required String label,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: NeumorphicColors.coral.withOpacity(0.10),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: NeumorphicColors.coral, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.montserrat(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: NeumorphicColors.textPrimary,
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.montserrat(
                    fontSize: 12,
                    color: NeumorphicColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Switch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }

  // ── Navigation row ────────────────────────────────────────────────────────
  Widget _buildNavRow({
    required IconData icon,
    required String label,
    bool isDestructive = false,
  }) {
    final color = isDestructive
        ? const Color(0xFFE57373)
        : NeumorphicColors.coral;

    return GestureDetector(
      onTap: () {},
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.10),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.montserrat(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isDestructive
                      ? const Color(0xFFE57373)
                      : NeumorphicColors.textPrimary,
                ),
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded,
                size: 14, color: NeumorphicColors.textDisabled),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Divider(
        color: NeumorphicColors.divider,
        thickness: 1,
        height: 1,
      ),
    );
  }
}
