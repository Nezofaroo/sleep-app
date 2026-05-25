import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';
import '../theme/theme_notifier.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);

    return Scaffold(
      backgroundColor: c.background,
      appBar: AppBar(
        backgroundColor: c.background,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: c.cardRaised(radius: 12),
            child: Icon(Icons.arrow_back_ios_new_rounded,
                color: c.accent, size: 18),
          ),
        ),
        title: Text(
          'Settings',
          style: GoogleFonts.montserrat(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: c.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Theme section ──────────────────────────────────────────────
            _sectionLabel('Appearance', c),
            const SizedBox(height: 12),
            _ThemeSelector(c: c),
            const SizedBox(height: 28),

            // ── About section ─────────────────────────────────────────────
            _sectionLabel('About', c),
            const SizedBox(height: 12),
            Container(
              decoration: c.cardRaised(radius: 20),
              child: Column(
                children: [
                  _infoRow('Version', '1.0.0', c),
                  _divider(c),
                  _infoRow('Framework', 'Flutter 3.x', c),
                  _divider(c),
                  _infoRow('Database', 'SQLite', c),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(String label, AppColors c) => Text(
        label,
        style: GoogleFonts.montserrat(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: c.textSecondary,
          letterSpacing: 0.5,
        ),
      );

  Widget _divider(AppColors c) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Divider(color: c.divider, thickness: 1, height: 1),
      );

  Widget _infoRow(String label, String value, AppColors c) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label,
                style: GoogleFonts.montserrat(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: c.textPrimary)),
            Text(value,
                style: GoogleFonts.montserrat(
                    fontSize: 14, color: c.textSecondary)),
          ],
        ),
      );
}

// ── Theme Selector widget ─────────────────────────────────────────────────────
class _ThemeSelector extends StatelessWidget {
  final AppColors c;
  const _ThemeSelector({required this.c});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (_, mode, __) {
        final isLight = mode == ThemeMode.light;
        return Column(
          children: [
            // Preview cards row
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => themeNotifier.value = ThemeMode.light,
                    child: _ThemePreviewCard(
                      label: 'Light',
                      isSelected: isLight,
                      bg: const Color(0xFFF0F2F5),
                      cardBg: const Color(0xFFFFFFFF),
                      accent: const Color(0xFFFF7F50),
                      textColor: const Color(0xFF3D3D5C),
                      selectionColor: c.accent,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: GestureDetector(
                    onTap: () => themeNotifier.value = ThemeMode.dark,
                    child: _ThemePreviewCard(
                      label: 'Dark Velvet',
                      isSelected: !isLight,
                      bg: const Color(0xFF12121A),
                      cardBg: const Color(0xFF1F2330),
                      accent: const Color(0xFF4A8EC0),
                      textColor: const Color(0xFFF5F1E9),
                      selectionColor: c.accent,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Toggle row
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: c.cardRaised(radius: 16),
              child: Row(
                children: [
                  Icon(
                    isLight ? Icons.wb_sunny_rounded : Icons.nights_stay_rounded,
                    color: c.accent,
                    size: 22,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isLight ? 'Light Mode' : 'Dark Velvet Mode',
                          style: GoogleFonts.montserrat(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: c.textPrimary),
                        ),
                        Text(
                          isLight
                              ? 'Neumorphic coral design'
                              : 'Deep evening comfort palette',
                          style: GoogleFonts.montserrat(
                              fontSize: 12, color: c.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: !isLight,
                    onChanged: (v) => themeNotifier.value =
                        v ? ThemeMode.dark : ThemeMode.light,
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ThemePreviewCard extends StatelessWidget {
  final String label;
  final bool isSelected;
  final Color bg;
  final Color cardBg;
  final Color accent;
  final Color textColor;
  final Color selectionColor;

  const _ThemePreviewCard({
    required this.label,
    required this.isSelected,
    required this.bg,
    required this.cardBg,
    required this.accent,
    required this.textColor,
    required this.selectionColor,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected ? selectionColor : Colors.transparent,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
              color: isSelected
                  ? selectionColor.withValues(alpha: 0.25)
                  : Colors.black.withValues(alpha: 0.12),
              blurRadius: 12,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        children: [
          // Mini card mock
          Container(
            height: 48,
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                CircleAvatar(radius: 8, backgroundColor: accent),
                const SizedBox(width: 6),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(height: 4, width: 40,
                          decoration: BoxDecoration(
                              color: textColor.withValues(alpha: 0.7),
                              borderRadius: BorderRadius.circular(2))),
                      const SizedBox(height: 4),
                      Container(height: 3, width: 28,
                          decoration: BoxDecoration(
                              color: textColor.withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(2))),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // Accent pill mock
          Container(
            height: 10,
            decoration: BoxDecoration(
              color: accent,
              borderRadius: BorderRadius.circular(5),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label,
                  style: GoogleFonts.montserrat(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: textColor)),
              if (isSelected)
                Icon(Icons.check_circle_rounded,
                    color: selectionColor, size: 16),
            ],
          ),
        ],
      ),
    );
  }
}
