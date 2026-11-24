import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  const AppTheme._();

  // Claymorphic Core Palette
  static const Color clayCanvas = Color(0xFFFCF8FF); // Soft Lavender Tint
  static const Color clayCard = Color(0xFFFFFFFF);
  static const Color clayBorder = Color(0xFFE0E7FF); // Soft Indigo-Tinted Border
  static const Color clayBorderSubtle = Color(0xFFF1F5F9);
  
  static const Color primaryIndigo = Color(0xFF4F46E5); // Indigo 600
  static const Color primaryIndigoLight = Color(0xFFEEF2FF); // Indigo 50
  static const Color accentOrange = Color(0xFFEA580C); // Warm Orange 600
  static const Color accentOrangeLight = Color(0xFFFFF7ED); // Orange 50
  
  static const Color textPrimary = Color(0xFF0F172A); // Slate 900
  static const Color textSecondary = Color(0xFF475569); // Slate 600
  static const Color textMuted = Color(0xFF94A3B8); // Slate 400

  static const Color successGreen = Color(0xFF10B981); // Emerald 500
  static const Color successGreenLight = Color(0xFFECFDF5);
  static const Color warningAmber = Color(0xFFF59E0B); // Amber 500
  static const Color dangerRed = Color(0xFFEF4444); // Red 500
  static const Color dangerRedLight = Color(0xFFFEF2F2);

  // Backward compatibility aliases
  static const Color primaryTeal = primaryIndigo;
  static const Color primaryDark = textPrimary;
  static const Color secondaryAmber = warningAmber;
  static const Color warningOrange = accentOrange;
  static const Color surfaceBg = clayCanvas;
  static const Color buddyBubbleBg = Color(0xFFF3F4F6);
  static const Color cardBorder = clayBorder;
  static const Color darkCanvas = clayCanvas;
  static const Color darkCard = clayCard;
  static const Color darkBorder = clayBorder;

  static ThemeData light() {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryIndigo,
        brightness: Brightness.light,
        primary: primaryIndigo,
        secondary: accentOrange,
        surface: clayCard,
        surfaceContainerLowest: clayCanvas,
      ),
      scaffoldBackgroundColor: clayCanvas,
    );

    final fontFamily = GoogleFonts.plusJakartaSans().fontFamily;
    return base.copyWith(
      textTheme: base.textTheme.apply(
        fontFamily: fontFamily,
        bodyColor: textPrimary,
        displayColor: textPrimary,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: textPrimary,
        elevation: 0,
        scrolledUnderElevation: 2,
        shadowColor: const Color(0xFF1E1B4B).withValues(alpha: 0.05),
        centerTitle: false,
        titleTextStyle: GoogleFonts.plusJakartaSans(
          fontSize: 18,
          fontWeight: FontWeight.w800,
          color: textPrimary,
        ),
        iconTheme: const IconThemeData(color: textPrimary),
      ),
      cardTheme: CardThemeData(
        color: clayCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
          side: const BorderSide(
            color: clayBorder,
            width: 1.5,
          ),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: clayBorder, width: 2),
        ),
        titleTextStyle: GoogleFonts.plusJakartaSans(
          fontSize: 18,
          fontWeight: FontWeight.w800,
          color: textPrimary,
        ),
        contentTextStyle: GoogleFonts.plusJakartaSans(
          fontSize: 13.5,
          color: textSecondary,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintStyle: const TextStyle(color: textMuted, fontSize: 13),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: clayBorder, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: clayBorder, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: primaryIndigo, width: 2.0),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryIndigo,
          foregroundColor: Colors.white,
          minimumSize: const Size(0, 48),
          elevation: 2,
          shadowColor: primaryIndigo.withValues(alpha: 0.35),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w700,
            fontSize: 14.5,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryIndigo,
          side: const BorderSide(color: clayBorder, width: 1.8),
          minimumSize: const Size(0, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w700,
            fontSize: 14.5,
          ),
        ),
      ),
    );
  }

  static ThemeData dark() => light(); // Maintain consistent claymorphic aesthetic
}
