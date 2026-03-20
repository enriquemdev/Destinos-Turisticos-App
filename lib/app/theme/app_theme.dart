import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Semantic color tokens for the app.
abstract final class AppColors {
  // Primary – tropical teal/emerald
  static const Color primary = Color(0xFF00897B);
  static const Color primaryDark = Color(0xFF00695C);
  static const Color primaryLight = Color(0xFF4DB6AC);

  // Accent – warm amber/gold
  static const Color accent = Color(0xFFFFA000);

  // Surfaces
  static const Color surfaceLight = Color(0xFFF5F5F5);
  static const Color surfaceDark = Color(0xFF121212);
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color cardDark = Color(0xFF1E1E1E);

  // On-surface
  static const Color onSurfaceLight = Color(0xFF1A1A1A);
  static const Color onSurfaceDark = Color(0xFFF0F0F0);
}

abstract final class AppTheme {
  AppTheme._();

  static TextTheme _buildTextTheme(Color bodyColor, Color displayColor) {
    return GoogleFonts.outfitTextTheme(
      TextTheme(
        displayLarge: TextStyle(
          fontFamily: GoogleFonts.outfit().fontFamily,
          fontSize: 57,
          fontWeight: FontWeight.w700,
          color: displayColor,
        ),
        displayMedium: TextStyle(
          fontFamily: GoogleFonts.outfit().fontFamily,
          fontSize: 45,
          fontWeight: FontWeight.w700,
          color: displayColor,
        ),
        headlineLarge: TextStyle(
          fontFamily: GoogleFonts.outfit().fontFamily,
          fontSize: 32,
          fontWeight: FontWeight.w700,
          color: displayColor,
        ),
        headlineMedium: TextStyle(
          fontFamily: GoogleFonts.outfit().fontFamily,
          fontSize: 28,
          fontWeight: FontWeight.w600,
          color: displayColor,
        ),
        headlineSmall: TextStyle(
          fontFamily: GoogleFonts.outfit().fontFamily,
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: displayColor,
        ),
        titleLarge: TextStyle(
          fontFamily: GoogleFonts.outfit().fontFamily,
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: displayColor,
        ),
        titleMedium: TextStyle(
          fontFamily: GoogleFonts.outfit().fontFamily,
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: bodyColor,
        ),
        titleSmall: TextStyle(
          fontFamily: GoogleFonts.outfit().fontFamily,
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: bodyColor,
        ),
        bodyLarge: GoogleFonts.inter(fontSize: 16, color: bodyColor),
        bodyMedium: GoogleFonts.inter(fontSize: 14, color: bodyColor),
        bodySmall: GoogleFonts.inter(
          fontSize: 12,
          color: bodyColor.withAlpha(180),
        ),
        labelLarge: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: bodyColor,
        ),
        labelMedium: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: bodyColor,
        ),
        labelSmall: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: bodyColor.withAlpha(200),
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  static ThemeData get light => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          brightness: Brightness.light,
        ).copyWith(
          primary: AppColors.primary,
          secondary: AppColors.accent,
          surface: AppColors.surfaceLight,
          onSurface: AppColors.onSurfaceLight,
        ),
        scaffoldBackgroundColor: AppColors.surfaceLight,
        textTheme: _buildTextTheme(
          AppColors.onSurfaceLight,
          AppColors.onSurfaceLight,
        ),
        appBarTheme: AppBarTheme(
          centerTitle: false,
          elevation: 0,
          scrolledUnderElevation: 0,
          backgroundColor: Colors.transparent,
          titleTextStyle: GoogleFonts.outfit(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: AppColors.onSurfaceLight,
          ),
          iconTheme: const IconThemeData(color: AppColors.onSurfaceLight),
        ),
        cardTheme: CardThemeData(
          elevation: 0,
          color: AppColors.cardLight,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          clipBehavior: Clip.antiAlias,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
        chipTheme: ChipThemeData(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          labelStyle: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 4,
          shape: StadiumBorder(),
        ),
      );

  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          brightness: Brightness.dark,
        ).copyWith(
          primary: AppColors.primaryLight,
          secondary: AppColors.accent,
          surface: AppColors.surfaceDark,
          onSurface: AppColors.onSurfaceDark,
        ),
        scaffoldBackgroundColor: AppColors.surfaceDark,
        textTheme: _buildTextTheme(
          AppColors.onSurfaceDark,
          AppColors.onSurfaceDark,
        ),
        appBarTheme: AppBarTheme(
          centerTitle: false,
          elevation: 0,
          scrolledUnderElevation: 0,
          backgroundColor: Colors.transparent,
          titleTextStyle: GoogleFonts.outfit(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: AppColors.onSurfaceDark,
          ),
          iconTheme: const IconThemeData(color: AppColors.onSurfaceDark),
        ),
        cardTheme: CardThemeData(
          elevation: 0,
          color: AppColors.cardDark,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          clipBehavior: Clip.antiAlias,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF2A2A2A),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide:
                const BorderSide(color: AppColors.primaryLight, width: 1.5),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
        chipTheme: ChipThemeData(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          labelStyle: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: AppColors.primaryLight,
          foregroundColor: Colors.white,
          elevation: 4,
          shape: StadiumBorder(),
        ),
      );
}
