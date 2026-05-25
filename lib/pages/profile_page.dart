import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/dark_velvet.dart';

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

  // ── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Theme(
      // Self-contained dark theme override — only this page is dark
      data: Theme.of(context).copyWith(
        scaffoldBackgroundColor: DV.bg,
        switchTheme: SwitchThemeData(
          thumbColor: WidgetStateProperty.resolveWith((s) =>
              s.contains(WidgetState.selected)
                  ? DV.textPrimary
                  : const Color(0xFFB0ABB5)),
          trackColor: WidgetStateProperty.resolveWith((s) =>
              s.contains(WidgetState.selected)
                  ? DV.sapphire
                  : const Color(0xFF2E2B38)),
          trackOutlineColor:
              WidgetStateProperty.all(Colors.transparent),
        ),
        sliderTheme: SliderThemeData(
          activeTrackColor: DV.sapphire,
          inactiveTrackColor: const Color(0xFF1A2D45),
          thumbColor: DV.sapphire,
          overlayColor: DV.amber.withValues(alpha: 0.18),
          thumbShape: _AmberGlowThumbShape(),
          trackHeight: 4,
          tickMarkShape: SliderTickMarkShape.noTickMark,
        ),
      ),
      child: Scaffold(
        backgroundColor: DV.bg,
        body: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                _buildHero(),
                const SizedBox(height: 20),
                _buildXpCard(),
                const SizedBox(height: 16),
                _buildSleepGoalCard(),
                const SizedBox(height: 16),
                _buildSystemCard(),
                const SizedBox(height: 16),
                _buildAccountCard(),
                const SizedBox(height: 24),
                Text(
                  'Sleep Tracker v1.0.0  ·  NeuroCorp Systems',
                  style: GoogleFonts.montserrat(
                    fontSize: 10,
                    color: DV.textDisabled,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 28),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Hero / Avatar ─────────────────────────────────────────────────────────
  Widget _buildHero() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 28),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFF161624),
            DV.bg,
          ],
        ),
      ),
      child: Column(
        children: [
          // ── Page label row ──────────────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'PROFILE',
                style: GoogleFonts.montserrat(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: DV.textPrimary,
                  letterSpacing: 3,
                ),
              ),
              GestureDetector(
                onTap: () {},
                child: Container(
                  padding: const EdgeInsets.all(9),
                  decoration: dvCard(radius: 12),
                  child: Icon(
                    Icons.settings_outlined,
                    color: DV.textSecondary,
                    size: 18,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),

          // ── Avatar ──────────────────────────────────────────────────────
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              // Outer sapphire glow ring
              Container(
                width: 108,
                height: 108,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: sapphireGlow(intensity: 0.28),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: DV.sapphire, width: 2),
                    // Subtle inner sapphire gradient
                    gradient: RadialGradient(
                      colors: [
                        DV.sapphireDim.withValues(alpha: 0.5),
                        DV.surface,
                      ],
                      stops: const [0.0, 1.0],
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.person_rounded,
                      size: 58,
                      color: DV.sapphireLight.withValues(alpha: 0.9),
                    ),
                  ),
                ),
              ),
              // Edit badge
              Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: DV.surfaceHi,
                  shape: BoxShape.circle,
                  border: Border.all(color: DV.border, width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.4),
                      blurRadius: 6,
                    ),
                  ],
                ),
                child: Icon(
                  Icons.edit_rounded,
                  size: 12,
                  color: DV.sapphireLight,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // ── Name ────────────────────────────────────────────────────────
          Text(
            'CYBER_SLEEPER_01',
            style: GoogleFonts.montserrat(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: DV.textPrimary,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Neural Optimization Level: 7',
            style: GoogleFonts.montserrat(
              fontSize: 13,
              color: DV.textSecondary,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 16),

          // ── Tags (velvet eggplant) ───────────────────────────────────────
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: [
              _tag('NIGHT OWL'),
              _tag('7-DAY STREAK'),
              _tag('DEEP DIVER'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _tag(String label) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 6),
        decoration: BoxDecoration(
          color: DV.tagBg,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: DV.tagBorder, width: 1),
        ),
        child: Text(
          label,
          style: GoogleFonts.montserrat(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: DV.textPrimary,
            letterSpacing: 1,
          ),
        ),
      );

  // ── XP Card ───────────────────────────────────────────────────────────────
  Widget _buildXpCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: dvCard(radius: 18, elevated: false),
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
                        color: DV.sapphireDim,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.bolt_rounded,
                          color: DV.sapphireLight, size: 18),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'SLEEP XP',
                      style: GoogleFonts.montserrat(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: DV.textPrimary,
                      ),
                    ),
                  ],
                ),
                Text(
                  '2,450 / 3,000',
                  style: GoogleFonts.montserrat(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: DV.sapphireLight,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Progress track
            Container(
              height: 8,
              decoration: BoxDecoration(
                color: DV.xpTrack,
                borderRadius: BorderRadius.circular(8),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: 0.82,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1A556A), Color(0xFF28899E)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: DV.xpFill.withValues(alpha: 0.45),
                        blurRadius: 8,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              '550 XP to next level',
              style: GoogleFonts.montserrat(
                fontSize: 12,
                color: DV.textDisabled,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Sleep Goal Card ───────────────────────────────────────────────────────
  Widget _buildSleepGoalCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
        decoration: dvCard(radius: 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionLabel('SLEEP GOAL'),
            const SizedBox(height: 16),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: DV.sapphireDim,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.bedtime_rounded,
                      color: DV.sapphireLight, size: 20),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    'Target Duration',
                    style: GoogleFonts.montserrat(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: DV.textPrimary,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: DV.sapphireDim,
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: DV.sapphire.withValues(alpha: 0.5)),
                  ),
                  child: Text(
                    '${_targetSleep.toStringAsFixed(1)}h',
                    style: GoogleFonts.montserrat(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: DV.textPrimary,
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: ['4h', '8h', '12h']
                    .map((l) => Text(l,
                        style: GoogleFonts.montserrat(
                          fontSize: 11,
                          color: DV.textSecondary,
                        )))
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── System Card ───────────────────────────────────────────────────────────
  Widget _buildSystemCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        decoration: dvCard(radius: 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 4),
              child: _sectionLabel('SYSTEM'),
            ),
            _switchRow(
              icon: Icons.notifications_outlined,
              label: 'Sleep Reminders',
              subtitle: 'Notify 30 min before bedtime',
              value: _notifications,
              onChanged: (v) => setState(() => _notifications = v),
            ),
            _dvDivider(),
            _switchRow(
              icon: Icons.alarm_on_outlined,
              label: 'Smart Alarm',
              subtitle: 'Wake during lightest sleep phase',
              value: _smartAlarm,
              onChanged: (v) => setState(() => _smartAlarm = v),
            ),
            _dvDivider(),
            _switchRow(
              icon: Icons.vibration_rounded,
              label: 'Haptic Feedback',
              subtitle: 'Vibrate on interactions',
              value: _haptics,
              onChanged: (v) => setState(() => _haptics = v),
            ),
            const SizedBox(height: 4),
          ],
        ),
      ),
    );
  }

  Widget _switchRow({
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
              color: DV.sapphireDim,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: DV.sapphireLight, size: 20),
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
                      color: DV.textPrimary,
                    )),
                Text(subtitle,
                    style: GoogleFonts.montserrat(
                      fontSize: 12,
                      color: DV.textSecondary,
                    )),
              ],
            ),
          ),
          Switch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }

  // ── Account Card ──────────────────────────────────────────────────────────
  Widget _buildAccountCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        decoration: dvCard(radius: 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 4),
              child: _sectionLabel('ACCOUNT'),
            ),
            _navRow(icon: Icons.person_outline_rounded, label: 'Edit Profile'),
            _dvDivider(),
            _navRow(icon: Icons.share_outlined, label: 'Export Sleep Data'),
            _dvDivider(),
            _navRow(icon: Icons.info_outline_rounded, label: 'About'),
            _dvDivider(),
            _navRow(
              icon: Icons.logout_rounded,
              label: 'Sign Out',
              isDestructive: true,
            ),
            const SizedBox(height: 4),
          ],
        ),
      ),
    );
  }

  Widget _navRow({
    required IconData icon,
    required String label,
    bool isDestructive = false,
  }) {
    final color = isDestructive ? const Color(0xFFB05555) : DV.sapphireLight;
    return GestureDetector(
      onTap: () {},
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isDestructive
                    ? const Color(0xFF3A1A1A)
                    : DV.sapphireDim,
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
                  color: isDestructive ? const Color(0xFFB05555) : DV.textPrimary,
                ),
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded,
                size: 13, color: DV.textDisabled),
          ],
        ),
      ),
    );
  }

  // ── Shared helpers ────────────────────────────────────────────────────────
  Widget _sectionLabel(String text) => Text(
        text,
        style: GoogleFonts.montserrat(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: DV.sapphireLight,
          letterSpacing: 2.5,
        ),
      );

  Widget _dvDivider() => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Divider(
          color: DV.border,
          thickness: 1,
          height: 1,
        ),
      );
}

// ─── Custom amber-glow thumb ─────────────────────────────────────────────────
class _AmberGlowThumbShape extends SliderComponentShape {
  static const double _radius = 9;

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) =>
      const Size.fromRadius(_radius + 4);

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    final canvas = context.canvas;

    // Amber glow layer
    canvas.drawCircle(
      center,
      _radius + 5,
      Paint()
        ..color = DV.amber.withValues(alpha: 0.25)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );

    // Sapphire fill
    canvas.drawCircle(
      center,
      _radius,
      Paint()..color = DV.sapphire,
    );

    // Cream centre highlight
    canvas.drawCircle(
      center,
      _radius * 0.42,
      Paint()..color = DV.textPrimary.withValues(alpha: 0.9),
    );
  }
}
