// THEME LOCK: dark — source: user prompt (#121212, Netflix-inspired dark)
// Scaffold.backgroundColor = AppTheme.backgroundDark — ALL screens

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Brand colors
  static const Color primary = Color(0xFF2563EB);
  static const Color primaryLight = Color(0xFF3B82F6);
  static const Color primaryContainer = Color(0xFF1D4ED8);
  static const Color accent = Color(0xFFF59E0B);
  static const Color accentLight = Color(0xFFFBBF24);

  // Status colors
  static const Color success = Color(0xFF16A34A);
  static const Color successSurface = Color(0xFF14532D);
  static const Color warning = Color(0xFFD97706);
  static const Color warningSurface = Color(0xFF78350F);
  static const Color error = Color(0xFFDC2626);
  static const Color errorSurface = Color(0xFF7F1D1D);

  // Dark surfaces
  static const Color backgroundDark = Color(0xFF121212);
  static const Color surfaceDark = Color(0xFF1E1E1E);
  static const Color surfaceVariantDark = Color(0xFF2A2A2A);
  static const Color surfaceElevated = Color(0xFF333333);
  static const Color onSurfaceDark = Color(0xFFE6E6E6);
  static const Color onSurfaceMuted = Color(0xFF9CA3AF);
  static const Color outlineDark = Color(0xFF374151);
  static const Color outlineVariantDark = Color(0xFF1F2937);

  // Light surfaces
  static const Color backgroundLight = Color(0xFFF8FAFC);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceVariantLight = Color(0xFFF1F5F9);
  static const Color onSurfaceLight = Color(0xFF111827);
  static const Color onSurfaceMutedLight = Color(0xFF6B7280);
  static const Color outlineLight = Color(0xFFE2E8F0);

  static ThemeData get darkTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: backgroundDark,
        colorScheme: const ColorScheme.dark(
          primary: primary,
          onPrimary: Colors.white,
          primaryContainer: primaryContainer,
          onPrimaryContainer: Color(0xFFDBEAFE),
          secondary: accent,
          onSecondary: Color(0xFF1A1200),
          surface: surfaceDark,
          onSurface: onSurfaceDark,
          surfaceContainerHighest: surfaceVariantDark,
          onSurfaceVariant: onSurfaceMuted,
          error: error,
          onError: Colors.white,
          outline: outlineDark,
          outlineVariant: outlineVariantDark,
        ),
        textTheme: GoogleFonts.poppinsTextTheme(
          const TextTheme(
            displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.w700, color: onSurfaceDark),
            displayMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: onSurfaceDark),
            headlineLarge: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: onSurfaceDark),
            headlineMedium: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: onSurfaceDark),
            headlineSmall: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: onSurfaceDark),
            titleLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: onSurfaceDark),
            titleMedium: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: onSurfaceDark),
            titleSmall: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: onSurfaceDark),
            bodyLarge: TextStyle(fontSize: 15, fontWeight: FontWeight.w400, color: onSurfaceDark),
            bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: onSurfaceDark),
            bodySmall: TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: onSurfaceMuted),
            labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: onSurfaceDark),
            labelMedium: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: onSurfaceDark, letterSpacing: 0.2),
            labelSmall: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: onSurfaceMuted, letterSpacing: 0.3),
          ),
        ),
        appBarTheme: AppBarThemeData(
          backgroundColor: backgroundDark,
          elevation: 0,
          scrolledUnderElevation: 0,
          titleTextStyle: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700, color: onSurfaceDark),
          iconTheme: const IconThemeData(color: onSurfaceDark),
        ),
        cardTheme: CardThemeData(
          color: surfaceDark,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          margin: EdgeInsets.zero,
        ),
        inputDecorationTheme: InputDecorationThemeData(
          filled: true,
          fillColor: surfaceVariantDark,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: outlineDark, width: 1)),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: outlineDark, width: 1)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: primary, width: 2)),
          errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: error, width: 1)),
          focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: error, width: 2)),
          labelStyle: const TextStyle(color: onSurfaceMuted, fontSize: 14),
          hintStyle: const TextStyle(color: onSurfaceMuted, fontSize: 14),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primary,
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
            textStyle: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600),
          ),
        ),
        chipTheme: ChipThemeData(
          backgroundColor: surfaceVariantDark,
          selectedColor: primary.withAlpha(51),
          labelStyle: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500, color: onSurfaceDark),
          side: const BorderSide(color: outlineDark),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        dividerTheme: const DividerThemeData(color: outlineVariantDark, thickness: 1, space: 0),
        bottomSheetTheme: const BottomSheetThemeData(
          backgroundColor: surfaceDark,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
        ),
      );

  static ThemeData get lightTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        scaffoldBackgroundColor: backgroundLight,
        colorScheme: const ColorScheme.light(
          primary: primary,
          onPrimary: Colors.white,
          primaryContainer: Color(0xFFDBEAFE),
          onPrimaryContainer: Color(0xFF1E3A8A),
          secondary: accent,
          onSecondary: Colors.white,
          surface: surfaceLight,
          onSurface: onSurfaceLight,
          surfaceContainerHighest: surfaceVariantLight,
          onSurfaceVariant: onSurfaceMutedLight,
          error: error,
          onError: Colors.white,
          outline: outlineLight,
          outlineVariant: Color(0xFFF1F5F9),
        ),
        textTheme: GoogleFonts.poppinsTextTheme(
          const TextTheme(
            displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.w700, color: onSurfaceLight),
            headlineLarge: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: onSurfaceLight),
            headlineMedium: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: onSurfaceLight),
            titleLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: onSurfaceLight),
            bodyLarge: TextStyle(fontSize: 15, fontWeight: FontWeight.w400, color: onSurfaceLight),
            bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: onSurfaceLight),
            bodySmall: TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: onSurfaceMutedLight),
          ),
        ),
        appBarTheme: AppBarThemeData(
          backgroundColor: surfaceLight,
          elevation: 0,
          scrolledUnderElevation: 1,
          titleTextStyle: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700, color: onSurfaceLight),
          iconTheme: const IconThemeData(color: onSurfaceLight),
        ),
        cardTheme: CardThemeData(
          color: surfaceLight,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          margin: EdgeInsets.zero,
        ),
        inputDecorationTheme: InputDecorationThemeData(
          filled: true,
          fillColor: surfaceVariantLight,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: outlineLight, width: 1)),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: outlineLight, width: 1)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: primary, width: 2)),
          labelStyle: const TextStyle(color: onSurfaceMutedLight, fontSize: 14),
          hintStyle: const TextStyle(color: onSurfaceMutedLight, fontSize: 14),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primary,
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
            textStyle: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600),
          ),
        ),
      );
}
