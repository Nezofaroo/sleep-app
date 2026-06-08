import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';




class NeumorphicColors {

  static const Color background  = Color(0xFFF0F2F5);
  static const Color surface     = Color(0xFFF0F2F5);


  static const Color shadowDark  = Color(0xFFC8CACD);
  static const Color shadowLight = Color(0xFFFFFFFF);


  static const Color coral       = Color(0xFFFF7F50);
  static const Color coralLight  = Color(0xFFFFB08C);
  static const Color coralDark   = Color(0xFFE06030);


  static const Color textPrimary   = Color(0xFF3D3D5C);
  static const Color textSecondary = Color(0xFF8E8E9A);
  static const Color textDisabled  = Color(0xFFBEBECB);
  static const Color white         = Color(0xFFFFFFFF);


  static const Color chartBg    = Color(0xFFE8EAF0);
  static const Color divider    = Color(0xFFDEE0E6);
}






BoxDecoration neumorphicRaised({
  double radius = 16,
  Color? color,
}) {
  final bg = color ?? NeumorphicColors.background;
  return BoxDecoration(
    color: bg,
    borderRadius: BorderRadius.circular(radius),
    boxShadow: const [
      BoxShadow(
        color: NeumorphicColors.shadowDark,
        offset: Offset(6, 6),
        blurRadius: 14,
        spreadRadius: 1,
      ),
      BoxShadow(
        color: NeumorphicColors.shadowLight,
        offset: Offset(-6, -6),
        blurRadius: 14,
        spreadRadius: 1,
      ),
    ],
  );
}


BoxDecoration neumorphicPressed({double radius = 16, Color? color}) {
  final bg = color ?? NeumorphicColors.background;
  return BoxDecoration(
    color: bg,
    borderRadius: BorderRadius.circular(radius),
    boxShadow: const [
      BoxShadow(
        color: NeumorphicColors.shadowDark,
        offset: Offset(-4, -4),
        blurRadius: 10,
        spreadRadius: 1,
      ),
      BoxShadow(
        color: NeumorphicColors.shadowLight,
        offset: Offset(4, 4),
        blurRadius: 10,
        spreadRadius: 1,
      ),
    ],
  );
}


BoxDecoration coralButtonDecoration({double radius = 50}) {
  return BoxDecoration(
    gradient: const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFFFF9B72), Color(0xFFFF6A30)],
    ),
    borderRadius: BorderRadius.circular(radius),
    boxShadow: [
      BoxShadow(
        color: NeumorphicColors.coral.withOpacity(0.40),
        offset: const Offset(4, 8),
        blurRadius: 16,
      ),
      const BoxShadow(
        color: NeumorphicColors.shadowLight,
        offset: Offset(-3, -3),
        blurRadius: 8,
      ),
    ],
  );
}


BoxDecoration outlineCoralDecoration({double radius = 50}) {
  return BoxDecoration(
    color: NeumorphicColors.background,
    borderRadius: BorderRadius.circular(radius),
    border: Border.all(color: NeumorphicColors.coral, width: 1.5),
    boxShadow: const [
      BoxShadow(
        color: NeumorphicColors.shadowDark,
        offset: Offset(4, 4),
        blurRadius: 10,
      ),
      BoxShadow(
        color: NeumorphicColors.shadowLight,
        offset: Offset(-4, -4),
        blurRadius: 10,
      ),
    ],
  );
}




class NeumorphicTheme {
  static ThemeData get theme {
    final base = GoogleFonts.montserrat();
    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: NeumorphicColors.background,
      colorScheme: const ColorScheme.light(
        primary: NeumorphicColors.coral,
        secondary: NeumorphicColors.coralLight,
        surface: NeumorphicColors.surface,
        onPrimary: NeumorphicColors.white,
        onSecondary: NeumorphicColors.white,
        onSurface: NeumorphicColors.textPrimary,
      ),
      textTheme: GoogleFonts.montserratTextTheme().copyWith(
        displayLarge: GoogleFonts.montserrat(
          fontSize: 48, fontWeight: FontWeight.w800,
          color: NeumorphicColors.textPrimary,
        ),
        displayMedium: GoogleFonts.montserrat(
          fontSize: 32, fontWeight: FontWeight.w700,
          color: NeumorphicColors.textPrimary,
        ),
        displaySmall: GoogleFonts.montserrat(
          fontSize: 24, fontWeight: FontWeight.w700,
          color: NeumorphicColors.textPrimary,
        ),
        headlineMedium: GoogleFonts.montserrat(
          fontSize: 20, fontWeight: FontWeight.w600,
          color: NeumorphicColors.textPrimary,
        ),
        titleLarge: GoogleFonts.montserrat(
          fontSize: 17, fontWeight: FontWeight.w600,
          color: NeumorphicColors.textPrimary,
        ),
        bodyLarge: GoogleFonts.montserrat(
          fontSize: 15, fontWeight: FontWeight.w400,
          color: NeumorphicColors.textPrimary,
        ),
        bodyMedium: GoogleFonts.montserrat(
          fontSize: 13, fontWeight: FontWeight.w400,
          color: NeumorphicColors.textSecondary,
        ),
        labelLarge: GoogleFonts.montserrat(
          fontSize: 13, fontWeight: FontWeight.w600,
          color: NeumorphicColors.white,
          letterSpacing: 0.5,
        ),
      ),
      cardTheme: CardThemeData(
        color: NeumorphicColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: NeumorphicColors.background,
        selectedItemColor: NeumorphicColors.coral,
        unselectedItemColor: NeumorphicColors.textSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: TextStyle(
          fontWeight: FontWeight.w600, fontSize: 10,
        ),
        unselectedLabelStyle: TextStyle(fontSize: 10),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: NeumorphicColors.background,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: NeumorphicColors.coral, width: 1.5),
        ),
        labelStyle: base.copyWith(color: NeumorphicColors.textSecondary),
        hintStyle: base.copyWith(color: NeumorphicColors.textDisabled),
      ),
      iconTheme: const IconThemeData(color: NeumorphicColors.coral),
      dividerColor: NeumorphicColors.divider,
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((s) =>
            s.contains(WidgetState.selected)
                ? NeumorphicColors.coral
                : NeumorphicColors.white),
        trackColor: WidgetStateProperty.resolveWith((s) =>
            s.contains(WidgetState.selected)
                ? NeumorphicColors.coral.withOpacity(0.4)
                : NeumorphicColors.shadowDark),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: NeumorphicColors.coral,
        linearTrackColor: NeumorphicColors.chartBg,
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: NeumorphicColors.coral,
        inactiveTrackColor: NeumorphicColors.chartBg,
        thumbColor: NeumorphicColors.coral,
        overlayColor: NeumorphicColors.coral.withOpacity(0.15),
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 9),
        trackHeight: 4,
      ),
    );
  }
}
