import 'package:flutter/material.dart';

/// Dark Velvet palette — optimised for low-light / night-time viewing.
/// Colours are intentionally unsaturated, warm-shifted, and low-luminance.
class DV {
  // ── Backgrounds ──────────────────────────────────────────────────────────
  /// Primary screen background — deep midnight blue-slate
  static const Color bg         = Color(0xFF12121A);
  /// Card / container surface — slightly elevated matte
  static const Color surface    = Color(0xFF1A1A24);
  /// Elevated card — glassmorphism layer
  static const Color surfaceHi  = Color(0xFF242831);
  /// Subtle sapphire-tinted card border
  static const Color border     = Color(0xFF2A3650);

  // ── Text ─────────────────────────────────────────────────────────────────
  /// Warm cream-white — replaces harsh pure white
  static const Color textPrimary   = Color(0xFFE6E1D8);
  /// Muted cream — secondary labels
  static const Color textSecondary = Color(0xFF9A9490);
  /// Disabled / placeholder
  static const Color textDisabled  = Color(0xFF4E4A56);

  // ── Sapphire accent (main accent) ────────────────────────────────────────
  static const Color sapphire      = Color(0xFF356D9C);
  static const Color sapphireLight = Color(0xFF4A85B8);
  static const Color sapphireDim   = Color(0xFF1E3F60); // fill/bg tint

  // ── Amber-gold (single warm accent — used only for active nav + slider glow)
  static const Color amber     = Color(0xFFD4880A);
  static const Color amberGlow = Color(0xFFE8A030);

  // ── Velvet eggplant — tag backgrounds ────────────────────────────────────
  static const Color tagBg     = Color(0xFF3D2B4A);
  static const Color tagBorder = Color(0xFF5B3F6E);

  // ── XP bar (titian ocean blue) ────────────────────────────────────────────
  static const Color xpFill = Color(0xFF1E6B7A);
  static const Color xpTrack = Color(0xFF162430);

  // ── Nav ───────────────────────────────────────────────────────────────────
  static const Color navBg       = Color(0xFF0E0E16);
  static const Color navInactive = Color(0xFF6A6470);
}

// ────────────────────────────────────────────────────────────────────────────
// Reusable decoration helpers
// ────────────────────────────────────────────────────────────────────────────

/// Glassmorphism card — deep blue surface with subtle sapphire edge
BoxDecoration dvCard({
  double radius = 18,
  bool elevated = false,
}) =>
    BoxDecoration(
      color: elevated ? DV.surfaceHi : DV.surface,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(
        color: DV.border,
        width: 1,
      ),
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          elevated
              ? const Color(0xFF2C3040)
              : const Color(0xFF1E1E2C),
          elevated ? DV.surfaceHi : DV.surface,
        ],
        stops: const [0.0, 1.0],
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.45),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
        BoxShadow(
          color: DV.sapphire.withValues(alpha: 0.06),
          blurRadius: 30,
          offset: const Offset(0, 2),
        ),
      ],
    );

/// Sapphire glow (used on avatar ring, active elements)
List<BoxShadow> sapphireGlow({double intensity = 0.35}) => [
      BoxShadow(
        color: DV.sapphire.withValues(alpha: intensity),
        blurRadius: 18,
        spreadRadius: 2,
      ),
      BoxShadow(
        color: DV.sapphire.withValues(alpha: intensity * 0.4),
        blurRadius: 36,
        spreadRadius: 4,
      ),
    ];

/// Amber glow (slider thumb, active nav)
List<BoxShadow> amberGlow({double intensity = 0.4}) => [
      BoxShadow(
        color: DV.amber.withValues(alpha: intensity),
        blurRadius: 12,
        spreadRadius: 2,
      ),
    ];
