import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DarkVelvetTheme {
  static ThemeData get theme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xFF12121A),
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFF4A8EC0),
        secondary: Color(0xFFD4A84B),
        surface: Color(0xFF1A1D25),
        onPrimary: Color(0xFFF5F1E9),
        onSecondary: Color(0xFF12121A),
        onSurface: Color(0xFFF5F1E9),
      ),
      textTheme: GoogleFonts.montserratTextTheme(ThemeData.dark().textTheme).copyWith(
        displayLarge: GoogleFonts.montserrat(
            fontSize: 48, fontWeight: FontWeight.w800, color: const Color(0xFFF5F1E9)),
        displayMedium: GoogleFonts.montserrat(
            fontSize: 32, fontWeight: FontWeight.w700, color: const Color(0xFFF5F1E9)),
        titleLarge: GoogleFonts.montserrat(
            fontSize: 17, fontWeight: FontWeight.w600, color: const Color(0xFFF5F1E9)),
        bodyLarge: GoogleFonts.montserrat(
            fontSize: 15, color: const Color(0xFFF5F1E9)),
        bodyMedium: GoogleFonts.montserrat(
            fontSize: 13, color: const Color(0xFF8B97B0)),
        labelLarge: GoogleFonts.montserrat(
            fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFFF5F1E9)),
      ),
      cardTheme: CardThemeData(
        color: const Color(0xFF1F2330),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFF2A3248), width: 0.5),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Color(0xFF12121A),
        selectedItemColor: Color(0xFFD4A84B),
        unselectedItemColor: Color(0xFF8B97B0),
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      dividerColor: const Color(0xFF252A38),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((s) =>
            s.contains(WidgetState.selected)
                ? const Color(0xFFF5F1E9)
                : const Color(0xFF8B97B0)),
        trackColor: WidgetStateProperty.resolveWith((s) =>
            s.contains(WidgetState.selected)
                ? const Color(0xFF4A8EC0)
                : const Color(0xFF252A38)),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: const Color(0xFF4A8EC0),
        inactiveTrackColor: const Color(0xFF1A2535),
        thumbColor: const Color(0xFF4A8EC0),
        overlayColor: const Color(0xFF4A8EC0).withValues(alpha: 0.15),
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 9),
        trackHeight: 4,
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: Color(0xFF4A8EC0),
        linearTrackColor: Color(0xFF1A2535),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF1F2330),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF2A3248), width: 0.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF2A3248), width: 0.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF4A8EC0), width: 1.5),
        ),
      ),
    );
  }
}
