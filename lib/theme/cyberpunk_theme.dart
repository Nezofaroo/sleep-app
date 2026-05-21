import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CyberpunkColors {
  // Background layers
  static const Color background = Color(0xFF050A0F);
  static const Color surface = Color(0xFF0D1117);
  static const Color surfaceVariant = Color(0xFF111823);
  static const Color cardBg = Color(0xFF0A1520);

  // Neon accents
  static const Color neonCyan = Color(0xFF00F0FF);
  static const Color neonPink = Color(0xFFFF003C);
  static const Color neonYellow = Color(0xFFFCE205);
  static const Color neonPurple = Color(0xFFBD00FF);
  static const Color neonGreen = Color(0xFF00FF9F);

  // Text
  static const Color textPrimary = Color(0xFFE0F7FA);
  static const Color textSecondary = Color(0xFF607D8B);
  static const Color textDisabled = Color(0xFF37474F);

  // Borders / glows
  static const Color borderCyan = Color(0xFF00F0FF);
  static const Color borderPink = Color(0xFFFF003C);
}

class CyberpunkTheme {
  static ThemeData get theme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: CyberpunkColors.background,
      colorScheme: const ColorScheme.dark(
        primary: CyberpunkColors.neonCyan,
        secondary: CyberpunkColors.neonPink,
        surface: CyberpunkColors.surface,
        onPrimary: CyberpunkColors.background,
        onSecondary: CyberpunkColors.background,
        onSurface: CyberpunkColors.textPrimary,
      ),
      textTheme: GoogleFonts.rajdhaniTextTheme().copyWith(
        displayLarge: GoogleFonts.orbitron(
          fontSize: 48,
          fontWeight: FontWeight.w900,
          color: CyberpunkColors.neonCyan,
          letterSpacing: 4,
        ),
        displayMedium: GoogleFonts.orbitron(
          fontSize: 32,
          fontWeight: FontWeight.w700,
          color: CyberpunkColors.neonCyan,
          letterSpacing: 2,
        ),
        displaySmall: GoogleFonts.orbitron(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: CyberpunkColors.textPrimary,
          letterSpacing: 1.5,
        ),
        headlineMedium: GoogleFonts.orbitron(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: CyberpunkColors.textPrimary,
          letterSpacing: 1,
        ),
        titleLarge: GoogleFonts.rajdhani(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: CyberpunkColors.textPrimary,
          letterSpacing: 1,
        ),
        bodyLarge: GoogleFonts.rajdhani(
          fontSize: 16,
          color: CyberpunkColors.textPrimary,
          letterSpacing: 0.5,
        ),
        bodyMedium: GoogleFonts.rajdhani(
          fontSize: 14,
          color: CyberpunkColors.textSecondary,
          letterSpacing: 0.3,
        ),
        labelLarge: GoogleFonts.orbitron(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          letterSpacing: 2,
          color: CyberpunkColors.neonCyan,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Color(0xFF080E14),
        selectedItemColor: CyberpunkColors.neonCyan,
        unselectedItemColor: CyberpunkColors.textSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        color: CyberpunkColors.cardBg,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Color(0xFF1A3040), width: 1),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: CyberpunkColors.surfaceVariant,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: CyberpunkColors.borderCyan, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF1A3040), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: CyberpunkColors.neonCyan, width: 1.5),
        ),
        labelStyle: GoogleFonts.rajdhani(color: CyberpunkColors.textSecondary),
        hintStyle: GoogleFonts.rajdhani(color: CyberpunkColors.textDisabled),
      ),
      iconTheme: const IconThemeData(color: CyberpunkColors.neonCyan),
      dividerColor: const Color(0xFF1A3040),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return CyberpunkColors.neonCyan;
          return CyberpunkColors.textSecondary;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return CyberpunkColors.neonCyan.withOpacity(0.3);
          return CyberpunkColors.surfaceVariant;
        }),
      ),
    );
  }
}

// Reusable glow box decoration
BoxDecoration cyberpunkCardDecoration({
  Color borderColor = CyberpunkColors.neonCyan,
  double glowRadius = 6,
  double borderRadius = 12,
}) {
  return BoxDecoration(
    color: CyberpunkColors.cardBg,
    borderRadius: BorderRadius.circular(borderRadius),
    border: Border.all(color: borderColor.withOpacity(0.6), width: 1),
    boxShadow: [
      BoxShadow(
        color: borderColor.withOpacity(0.15),
        blurRadius: glowRadius,
        spreadRadius: 1,
      ),
    ],
  );
}

// Neon glow text shadow
List<Shadow> neonGlow(Color color) {
  return [
    Shadow(color: color.withOpacity(0.8), blurRadius: 8),
    Shadow(color: color.withOpacity(0.4), blurRadius: 20),
  ];
}
