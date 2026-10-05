import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTypography {
  static TextStyle displayLarge(bool isDark) => GoogleFonts.poppins(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
      );

  static TextStyle titleLarge(bool isDark) => GoogleFonts.poppins(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
      );

  static TextStyle bodyMedium(bool isDark) => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.normal,
        color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
      );

  static TextStyle skuMono(bool isDark) => GoogleFonts.jetBrainsMono(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: isDark ? AppColors.accentTeal : AppColors.primary,
      );
}
