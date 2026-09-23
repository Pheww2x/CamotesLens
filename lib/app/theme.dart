// lib/app/theme.dart
// ---------------------------------------------------------------------------
// Premium Material 3 theme for CamotesLens.
// Lush emerald & lime agricultural palette with modern Google Fonts typography.
// ---------------------------------------------------------------------------

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Semantic brand colors and reusable design tokens.
class AppColors {
  AppColors._();

  // Primary greens
  static const Color primary = Color(0xFF0D6B3F);
  static const Color primaryDark = Color(0xFF084528);
  static const Color primaryLight = Color(0xFF15803D);
  static const Color emeraldVivid = Color(0xFF10B981);
  static const Color emeraldMint = Color(0xFF34D399);
  static const Color emeraldLight = Color(0xFFD1FAE5);
  static const Color emeraldSubtle = Color(0xFFE8F8F0);

  // Accent & functional
  static const Color limeAccent = Color(0xFF84CC16);
  static const Color amberAccent = Color(0xFFF59E0B);
  static const Color amberLight = Color(0xFFFEF3C7);
  static const Color error = Color(0xFFEF4444);
  static const Color errorLight = Color(0xFFFEE2E2);

  // Neutrals
  static const Color background = Color(0xFFF4F9F5);
  static const Color surface = Colors.white;
  static const Color surfaceSubtle = Color(0xFFF8FCF9);
  static const Color borderLight = Color(0xFFE2E8F0);
  static const Color borderEmerald = Color(0xFFA7F3D0);

  // Text
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF475569);
  static const Color textTertiary = Color(0xFF94A3B8);

  // Premium Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF0D6B3F), Color(0xFF10B981)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient heroGradient = LinearGradient(
    colors: [Color(0xFF063B21), Color(0xFF0D6B3F), Color(0xFF059669)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient barGradient = LinearGradient(
    colors: [Color(0xFF0D6B3F), Color(0xFF10B981), Color(0xFF84CC16)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const LinearGradient cardGlowGradient = LinearGradient(
    colors: [Color(0x1810B981), Color(0x0410B981)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

class AppTheme {
  AppTheme._();

  static ThemeData get light {
    final baseTextTheme = GoogleFonts.interTextTheme();

    const ColorScheme scheme = ColorScheme(
      brightness: Brightness.light,
      primary: AppColors.primary,
      onPrimary: Colors.white,
      primaryContainer: AppColors.emeraldLight,
      onPrimaryContainer: AppColors.primaryDark,
      secondary: AppColors.emeraldVivid,
      onSecondary: Colors.white,
      secondaryContainer: AppColors.emeraldSubtle,
      onSecondaryContainer: AppColors.primaryDark,
      tertiary: AppColors.limeAccent,
      onTertiary: Colors.black,
      error: AppColors.error,
      onError: Colors.white,
      errorContainer: AppColors.errorLight,
      onErrorContainer: Color(0xFF7F1D1D),
      surface: AppColors.surface,
      onSurface: AppColors.textPrimary,
      surfaceContainerHighest: Color(0xFFE2E8F0),
      outline: Color(0xFFCBD5E1),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.background,
      textTheme: baseTextTheme.copyWith(
        displayLarge: GoogleFonts.outfit(
          fontSize: 32,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
          letterSpacing: -0.5,
        ),
        displayMedium: GoogleFonts.outfit(
          fontSize: 26,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
          letterSpacing: -0.3,
        ),
        titleLarge: GoogleFonts.outfit(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        titleMedium: GoogleFonts.outfit(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        bodyLarge: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: AppColors.textPrimary,
          height: 1.5,
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: AppColors.textSecondary,
          height: 1.4,
        ),
        labelLarge: GoogleFonts.inter(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.3,
        ),
      ),

      // AppBar
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.outfit(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.white,
          letterSpacing: 0.2,
        ),
      ),

      // Cards
      cardTheme: CardTheme(
        color: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Color(0xFFE9EFE9), width: 1),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),

      // Elevated buttons
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 2,
          shadowColor: AppColors.primary.withValues(alpha: 0.35),
          minimumSize: const Size.fromHeight(54),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: GoogleFonts.outfit(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
        ),
      ),

      // Outlined buttons
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary, width: 1.5),
          minimumSize: const Size.fromHeight(54),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: GoogleFonts.outfit(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
        ),
      ),

      // Text buttons
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          textStyle: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Input fields
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.borderLight),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.borderLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.emeraldVivid, width: 2),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      ),

      // Progress indicators
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.emeraldVivid,
        linearTrackColor: AppColors.emeraldSubtle,
      ),

      // Chips
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.emeraldSubtle,
        labelStyle: GoogleFonts.inter(
          color: AppColors.primaryDark,
          fontWeight: FontWeight.w500,
          fontSize: 13,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: const BorderSide(color: AppColors.borderEmerald, width: 1),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      ),

      // Divider
      dividerTheme: const DividerThemeData(
        thickness: 1,
        color: Color(0xFFF1F5F9),
        space: 24,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Shared spacing / layout constants
// ---------------------------------------------------------------------------
class AppSpacing {
  AppSpacing._();

  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
}
