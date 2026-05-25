import 'package:flutter/material.dart';

/// Context-aware color palette + decoration helpers.
/// Usage in any build():  final c = AppColors.of(context);
class AppColors {
  final bool isDark;

  // ── Surfaces ──────────────────────────────────────────────────────────────
  final Color background;
  final Color surface;
  final Color cardBg;
  final Color shadowDark;
  final Color shadowLight;
  final Color border;

  // ── Accent ────────────────────────────────────────────────────────────────
  final Color accent;        // coral (light) / sapphire (dark)
  final Color accentLight;
  final Color accentDark;
  final List<Color> accentGradient;

  // ── Typography ────────────────────────────────────────────────────────────
  final Color textPrimary;
  final Color textSecondary;
  final Color textDisabled;
  final Color white;

  // ── Misc ──────────────────────────────────────────────────────────────────
  final Color chartBg;
  final Color divider;

  // ── Navigation ────────────────────────────────────────────────────────────
  final Color navActive;       // coral (light) / amber (dark)

  // ── Tags / badges ─────────────────────────────────────────────────────────
  final Color tagBg;
  final Color tagBorder;
  final Color tagText;

  // ── Progress bar ──────────────────────────────────────────────────────────
  final Color progressBg;
  final List<Color> progressGradient;

  // ── Avatar ────────────────────────────────────────────────────────────────
  final Color avatarRing;
  final List<Color> avatarGradient;

  // ── Slider thumb glow (amber in dark) ─────────────────────────────────────
  final Color sliderThumbGlow;

  const AppColors._({
    required this.isDark,
    required this.background,
    required this.surface,
    required this.cardBg,
    required this.shadowDark,
    required this.shadowLight,
    required this.border,
    required this.accent,
    required this.accentLight,
    required this.accentDark,
    required this.accentGradient,
    required this.textPrimary,
    required this.textSecondary,
    required this.textDisabled,
    required this.white,
    required this.chartBg,
    required this.divider,
    required this.navActive,
    required this.tagBg,
    required this.tagBorder,
    required this.tagText,
    required this.progressBg,
    required this.progressGradient,
    required this.avatarRing,
    required this.avatarGradient,
    required this.sliderThumbGlow,
  });

  // ── Factories ─────────────────────────────────────────────────────────────
  static AppColors of(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? _dark()
        : _light();
  }

  static AppColors _light() => const AppColors._(
        isDark: false,
        background: Color(0xFFF0F2F5),
        surface: Color(0xFFF0F2F5),
        cardBg: Color(0xFFF0F2F5),
        shadowDark: Color(0xFFC8CACD),
        shadowLight: Color(0xFFFFFFFF),
        border: Color(0xFFF0F2F5),
        accent: Color(0xFFFF7F50),
        accentLight: Color(0xFFFF9B72),
        accentDark: Color(0xFFFF6030),
        accentGradient: [Color(0xFFFF9B72), Color(0xFFFF6030)],
        textPrimary: Color(0xFF3D3D5C),
        textSecondary: Color(0xFF8E8E9A),
        textDisabled: Color(0xFFBEBECB),
        white: Color(0xFFFFFFFF),
        chartBg: Color(0xFFE8EAF0),
        divider: Color(0xFFDEE0E6),
        navActive: Color(0xFFFF7F50),
        tagBg: Color(0x1FFF7F50),
        tagBorder: Color(0x59FF7F50),
        tagText: Color(0xFFFF7F50),
        progressBg: Color(0xFFE8EAF0),
        progressGradient: [Color(0xFFFF9B72), Color(0xFFFF6030)],
        avatarRing: Color(0xFFFF7F50),
        avatarGradient: [Color(0xFFFF9B72), Color(0xFFFF6030)],
        sliderThumbGlow: Color(0x00000000),
      );

  static AppColors _dark() => const AppColors._(
        isDark: true,
        background: Color(0xFF12121A),
        surface: Color(0xFF1A1D25),
        cardBg: Color(0xFF1F2330),
        shadowDark: Color(0xFF090910),
        shadowLight: Color(0xFF252A38),
        border: Color(0xFF2A3248),
        accent: Color(0xFF4A8EC0),        // sapphire
        accentLight: Color(0xFF6AA8D4),
        accentDark: Color(0xFF2A5A88),
        accentGradient: [Color(0xFF4A8EC0), Color(0xFF2A5A88)],
        textPrimary: Color(0xFFF5F1E9),   // warm cream
        textSecondary: Color(0xFF8B97B0),
        textDisabled: Color(0xFF3D4A5C),
        white: Color(0xFFFFFFFF),
        chartBg: Color(0xFF1A2535),
        divider: Color(0xFF252A38),
        navActive: Color(0xFFD4A84B),     // warm amber
        tagBg: Color(0xFF2E1F42),         // deep aubergine
        tagBorder: Color(0xFF4A3558),
        tagText: Color(0xFFC9B8E8),       // soft lavender-white
        progressBg: Color(0xFF1A2535),
        progressGradient: [Color(0xFF1D6A7A), Color(0xFF0F4A58)], // teal
        avatarRing: Color(0xFF4A8EC0),
        avatarGradient: [Color(0xFF4A8EC0), Color(0xFF2A5A88)],
        sliderThumbGlow: Color(0x4DD4A84B), // amber glow @ 30%
      );

  // ── Decoration helpers ────────────────────────────────────────────────────

  BoxDecoration cardRaised({double radius = 16}) {
    if (isDark) {
      return BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: border.withValues(alpha: 0.7), width: 0.5),
        boxShadow: [
          BoxShadow(
              color: shadowDark.withValues(alpha: 0.9),
              offset: const Offset(4, 4),
              blurRadius: 12),
          BoxShadow(
              color: shadowLight.withValues(alpha: 0.06),
              offset: const Offset(-2, -2),
              blurRadius: 8),
        ],
      );
    }
    return BoxDecoration(
      color: background,
      borderRadius: BorderRadius.circular(radius),
      boxShadow: [
        BoxShadow(
            color: shadowDark,
            offset: const Offset(6, 6),
            blurRadius: 14,
            spreadRadius: 1),
        BoxShadow(
            color: shadowLight,
            offset: const Offset(-6, -6),
            blurRadius: 14,
            spreadRadius: 1),
      ],
    );
  }

  BoxDecoration cardPressed({double radius = 16}) {
    if (isDark) {
      return BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: border.withValues(alpha: 0.5), width: 0.5),
        boxShadow: [
          BoxShadow(
              color: shadowDark.withValues(alpha: 0.95),
              offset: const Offset(-3, -3),
              blurRadius: 8),
          BoxShadow(
              color: shadowLight.withValues(alpha: 0.04),
              offset: const Offset(3, 3),
              blurRadius: 6),
        ],
      );
    }
    return BoxDecoration(
      color: background,
      borderRadius: BorderRadius.circular(radius),
      boxShadow: [
        BoxShadow(
            color: shadowDark,
            offset: const Offset(-4, -4),
            blurRadius: 10,
            spreadRadius: 1),
        BoxShadow(
            color: shadowLight,
            offset: const Offset(4, 4),
            blurRadius: 10,
            spreadRadius: 1),
      ],
    );
  }

  BoxDecoration accentButton({double radius = 50}) {
    return BoxDecoration(
      gradient:
          LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: accentGradient),
      borderRadius: BorderRadius.circular(radius),
      boxShadow: [
        BoxShadow(
            color: accent.withValues(alpha: 0.40),
            offset: const Offset(4, 8),
            blurRadius: 16),
        BoxShadow(
            color: isDark
                ? shadowLight.withValues(alpha: 0.05)
                : const Color(0xFFFFFFFF),
            offset: const Offset(-3, -3),
            blurRadius: 8),
      ],
    );
  }

  BoxDecoration iconBadge({double radius = 10}) => BoxDecoration(
        color: accent.withValues(alpha: isDark ? 0.15 : 0.10),
        borderRadius: BorderRadius.circular(radius),
      );

  BoxDecoration tagDecoration({double radius = 30}) => BoxDecoration(
        color: tagBg,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: tagBorder, width: 1),
      );

  BoxDecoration avatarDecoration() => BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: avatarGradient),
        boxShadow: [
          BoxShadow(
              color: avatarRing.withValues(alpha: isDark ? 0.30 : 0.35),
              blurRadius: isDark ? 16 : 20,
              offset: const Offset(0, 8)),
          if (isDark)
            BoxShadow(
                color: avatarRing.withValues(alpha: 0.15),
                blurRadius: 24,
                spreadRadius: 2),
          BoxShadow(
              color: shadowLight.withValues(alpha: isDark ? 0.04 : 1.0),
              blurRadius: 10,
              offset: const Offset(-6, -6)),
        ],
      );
}
