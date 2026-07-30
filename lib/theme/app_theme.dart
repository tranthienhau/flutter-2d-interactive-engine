import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Design tokens lifted verbatim from the Google Stitch design system
/// (design/DESIGN.md). Kept in one place so every screen inherits the same
/// bright, rounded, preschool look.
class AppColors {
  static const background = Color(0xFFF6F4FD);
  static const surface = Color(0xFFFFFFFF);
  static const surfaceAlt = Color(0xFFEFEBFB);

  static const accent = Color(0xFF6B4EFF);
  static const accentTint = Color(0xFFE7E1FF);
  static const accentPressed = Color(0xFF5A3FE0);

  static const support = Color(0xFFFFB020);
  static const supportTint = Color(0xFFFFF1D6);

  static const textPrimary = Color(0xFF1A1530);
  static const textSecondary = Color(0xFF5B5473);
  static const textTertiary = Color(0xFF938CAD);

  static const border = Color(0xFFE6E1F2);
  static const success = Color(0xFF16A34A);
  static const warning = Color(0xFFD97706);
  static const danger = Color(0xFFDC2626);
}

/// Radius tokens (card 20, control 14, input 12, pill 999).
class AppRadius {
  static const card = 20.0;
  static const control = 14.0;
  static const input = 12.0;
  static const pill = 999.0;
}

class AppShadows {
  static const soft = <BoxShadow>[
    BoxShadow(color: Color(0x0A000000), blurRadius: 2, offset: Offset(0, 1)),
    BoxShadow(color: Color(0x0F000000), blurRadius: 24, offset: Offset(0, 8)),
  ];
}

class AppTheme {
  static ThemeData light() {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.accent,
        primary: AppColors.accent,
        surface: AppColors.surface,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: AppColors.background,
    );

    final textTheme = GoogleFonts.baloo2TextTheme(base.textTheme).apply(
      bodyColor: AppColors.textPrimary,
      displayColor: AppColors.textPrimary,
    );

    return base.copyWith(
      textTheme: textTheme,
      splashFactory: InkRipple.splashFactory,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
    );
  }
}

/// Reusable text styles that map to the DESIGN.md type scale.
class AppText {
  static TextStyle display = GoogleFonts.baloo2(
    fontSize: 30,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.4,
    color: AppColors.textPrimary,
    height: 1.15,
  );
  static TextStyle title = GoogleFonts.baloo2(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );
  static TextStyle body = GoogleFonts.baloo2(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
  );
  static TextStyle label = GoogleFonts.baloo2(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );
  static TextStyle caption = GoogleFonts.baloo2(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
  );
}
