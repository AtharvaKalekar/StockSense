import 'package:flutter/material.dart';

class AppColors {

  // Aliases for theme consistency
  static const Color accentTeal = Color(0xFF06B6D4);
  static const Color darkTextSecondary = Color(0xFF94A3B8);
  static const Color lightTextSecondary = Color(0xFF64748B);
  static const Color warning = Color(0xFFF59E0B);
  static const Color info = Color(0xFF3B82F6);

  // Stitch Primary & Accent Palette
  static const Color primary = Color(0xFF2563EB); // Royal Electric Blue
  static const Color primaryDark = Color(0xFF1D4ED8);
  static const Color primaryIndigo = Color(0xFF4F46E5);
  static const Color primaryTeal = Color(0xFF06B6D4); // Neon Cyan / Teal Accent

  // Background & Surfaces
  static const Color lightBackground = Color(0xFFF1F5F9); // Crisp Slate Grey/White
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightBorder = Color(0xFFE2E8F0);
  static const Color lightSubtext = Color(0xFF64748B);
  static const Color lightTextPrimary = Color(0xFF0F172A);

  // Scanner Dark Theme Surfaces
  static const Color darkBackground = Color(0xFF0B132B); // Deep Dark Navy
  static const Color darkSurface = Color(0xFF1C2541);
  static const Color darkCard = Color(0xFF1C2541);
  static const Color darkBorder = Color(0xFF3A506B);
  static const Color darkSubtext = Color(0xFF94A3B8);
  static const Color darkTextPrimary = Color(0xFFF8FAFC);

  // Status Colors (Stitch Badges)
  static const Color accentSuccess = Color(0xFF10B981); // Emerald Green (In Stock / Optimal)
  static const Color accentWarning = Color(0xFFF59E0B); // Amber Warning (Low Stock)
  static const Color errorRed = Color(0xFFEF4444);     // Crimson Red (Critical Alert / Stockout)
  static const Color infoBlue = Color(0xFF3B82F6);

  static const Color stockInStock = Color(0xFF10B981);
  static const Color stockLow = Color(0xFFF59E0B);
  static const Color stockCritical = Color(0xFFEF4444);
  static const Color stockOutOfStock = Color(0xFFEF4444);

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF2563EB), Color(0xFF06B6D4)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
