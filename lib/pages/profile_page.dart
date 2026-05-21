import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/cyberpunk_theme.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _notifications = true;
  bool _smartAlarm = false;
  bool _darkMode = true;
  bool _haptics = true;
  double _targetSleep = 8.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CyberpunkColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildProfileHero(),
              _buildXpBar(),
              const SizedBox(height: 20),
              _buildSection('SLEEP GOAL', [_buildSliderTile()]),
              _buildSection('SYSTEM', [
                _buildSwitchTile(
                  icon: Icons.notifications_outlined,
                  label: 'Sleep Reminders',
                  subtitle: 'Notify 30 min before bedtime',
                  color: CyberpunkColors.neonCyan,
                  value: _notifications,
                  onChanged: (v) => setState(() => _notifications = v),
                ),
                _buildSwitchTile(
                  icon: Icons.access_alarm,
                  label: 'Smart Alarm',
                  subtitle: 'Wake during light sleep phase',
                  color: CyberpunkColors.neonGreen,
                  value: _smartAlarm,
                  onChanged: (v) => setState(() => _smartAlarm = v),
                ),
                _buildSwitchTile(
                  icon: Icons.vibration,
                  label: 'Haptic Feedback',
                  subtitle: 'Vibrate on interactions',
                  color: CyberpunkColors.neonPurple,
                  value: _haptics,
                  onChanged: (v) => setState(() => _haptics = v),
                ),
                _buildSwitchTile(
                  icon: Icons.dark_mode_outlined,
                  label: 'Dark Mode',
                  subtitle: 'Cyberpunk darkness enabled',
                  color: CyberpunkColors.neonYellow,
                  value: _darkMode,
                  onChanged: (v) => setState(() => _darkMode = v),
                ),
              ]),
              _buildSection('ACCOUNT', [
                _buildNavTile(
                  icon: Icons.person_outline,
                  label: 'Edit Profile',
                  color: CyberpunkColors.neonCyan,
                ),
                _buildNavTile(
                  icon: Icons.share_outlined,
                  label: 'Export Sleep Data',
                  color: CyberpunkColors.neonGreen,
                ),
                _buildNavTile(
                  icon: Icons.info_outline,
                  label: 'About',
                  color: CyberpunkColors.neonPurple,
                ),
                _buildNavTile(
                  icon: Icons.logout,
                  label: 'Sign Out',
                  color: CyberpunkColors.neonPink,
                  isDestructive: true,
                ),
              ]),
              const SizedBox(height: 24),
              Text(
                'SLEEP TRACKER v1.0.0',
                style: GoogleFonts.orbitron(
                  fontSize: 9,
                  color: CyberpunkColors.textDisabled,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'NEUROCORP SYSTEMS',
                style: GoogleFonts.orbitron(
                  fontSize: 8,
                  color: CyberpunkColors.textDisabled.withOpacity(0.5),
                  letterSpacing: 3,
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHero() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            CyberpunkColors.neonCyan.withOpacity(0.05),
            CyberpunkColors.neonPurple.withOpacity(0.08),
            CyberpunkColors.background,
          ],
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                'PROFILE',
                style: GoogleFonts.orbitron(
                  fontSize: 12,
                  color: CyberpunkColors.neonCyan,
                  letterSpacing: 4,
                  shadows: neonGlow(CyberpunkColors.neonCyan),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: CyberpunkColors.cardBg,
                  border: Border.all(color: CyberpunkColors.neonCyan, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: CyberpunkColors.neonCyan.withOpacity(0.3),
                      blurRadius: 16,
                      spreadRadius: 2,
                    ),
                  ],
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      CyberpunkColors.neonPurple.withOpacity(0.3),
                      CyberpunkColors.neonCyan.withOpacity(0.2),
                    ],
                  ),
                ),
                child: const Icon(
                  Icons.person,
                  color: CyberpunkColors.neonCyan,
                  size: 48,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: CyberpunkColors.neonGreen,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.edit,
                  size: 12,
                  color: CyberpunkColors.background,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            'CYBER_SLEEPER_01',
            style: GoogleFonts.orbitron(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: CyberpunkColors.textPrimary,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Neural Optimization Level: 7',
            style: GoogleFonts.rajdhani(
              fontSize: 13,
              color: CyberpunkColors.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildBadge('NIGHT OWL', CyberpunkColors.neonPurple),
              const SizedBox(width: 8),
              _buildBadge('7-DAY STREAK', CyberpunkColors.neonYellow),
              const SizedBox(width: 8),
              _buildBadge('DEEP DIVER', CyberpunkColors.neonCyan),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.5), width: 1),
      ),
      child: Text(
        label,
        style: GoogleFonts.orbitron(
          fontSize: 8,
          color: color,
          letterSpacing: 1,
        ),
      ),
    );
  }

  Widget _buildXpBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: cyberpunkCardDecoration(
          borderColor: CyberpunkColors.neonGreen.withOpacity(0.4),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'SLEEP XP',
                  style: GoogleFonts.orbitron(
                    fontSize: 10,
                    color: CyberpunkColors.neonGreen,
                    letterSpacing: 2,
                  ),
                ),
                Text(
                  '2,450 / 3,000',
                  style: GoogleFonts.orbitron(
                    fontSize: 10,
                    color: CyberpunkColors.textSecondary,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: 0.82,
                minHeight: 8,
                backgroundColor: CyberpunkColors.surfaceVariant,
                valueColor: const AlwaysStoppedAnimation<Color>(
                  CyberpunkColors.neonGreen,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '550 XP to next level',
              style: GoogleFonts.rajdhani(
                fontSize: 12,
                color: CyberpunkColors.textDisabled,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              children: [
                Text(
                  title,
                  style: GoogleFonts.orbitron(
                    fontSize: 10,
                    color: CyberpunkColors.textSecondary,
                    letterSpacing: 3,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Divider(
                    color: CyberpunkColors.textDisabled.withOpacity(0.3),
                  ),
                ),
              ],
            ),
          ),
          Container(
            decoration: cyberpunkCardDecoration(
              borderColor: CyberpunkColors.neonCyan.withOpacity(0.15),
            ),
            child: Column(children: children),
          ),
        ],
      ),
    );
  }

  Widget _buildSliderTile() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.bedtime_outlined,
                    color: CyberpunkColors.neonCyan,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Target Sleep Duration',
                    style: GoogleFonts.rajdhani(
                      fontSize: 15,
                      color: CyberpunkColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              Text(
                '${_targetSleep.toStringAsFixed(1)}h',
                style: GoogleFonts.orbitron(
                  fontSize: 14,
                  color: CyberpunkColors.neonCyan,
                  fontWeight: FontWeight.w700,
                  shadows: neonGlow(CyberpunkColors.neonCyan),
                ),
              ),
            ],
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: CyberpunkColors.neonCyan,
              inactiveTrackColor: CyberpunkColors.surfaceVariant,
              thumbColor: CyberpunkColors.neonCyan,
              overlayColor: CyberpunkColors.neonCyan.withOpacity(0.2),
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
              trackHeight: 3,
            ),
            child: Slider(
              value: _targetSleep,
              min: 4,
              max: 12,
              divisions: 16,
              onChanged: (v) => setState(() => _targetSleep = v),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '4h',
                style: GoogleFonts.rajdhani(
                  fontSize: 11,
                  color: CyberpunkColors.textDisabled,
                ),
              ),
              Text(
                '8h (optimal)',
                style: GoogleFonts.rajdhani(
                  fontSize: 11,
                  color: CyberpunkColors.textDisabled,
                ),
              ),
              Text(
                '12h',
                style: GoogleFonts.rajdhani(
                  fontSize: 11,
                  color: CyberpunkColors.textDisabled,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String label,
    required String subtitle,
    required Color color,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.rajdhani(
                    fontSize: 15,
                    color: CyberpunkColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.rajdhani(
                    fontSize: 12,
                    color: CyberpunkColors.textSecondary,
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

  Widget _buildNavTile({
    required IconData icon,
    required String label,
    required Color color,
    bool isDestructive = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(
            icon,
            color: isDestructive ? CyberpunkColors.neonPink : color,
            size: 20,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.rajdhani(
                fontSize: 15,
                color: isDestructive
                    ? CyberpunkColors.neonPink
                    : CyberpunkColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Icon(
            Icons.arrow_forward_ios,
            color: CyberpunkColors.textDisabled,
            size: 14,
          ),
        ],
      ),
    );
  }
}
