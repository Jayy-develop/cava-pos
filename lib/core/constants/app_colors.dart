import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary Cafe Palette: Warm Roast Coffee & Amber Bronze
  static const Color primary = Color(0xFFD97706); // Amber 600
  static const Color primaryDark = Color(0xFFB45309); // Amber 700
  static const Color primaryLight = Color(0xFFFDE68A); // Amber 200
  static const Color primarySoft = Color(0xFFFEF3C7); // Amber 100

  // Status Accents
  static const Color accent = Color(0xFF059669); // Emerald 600 (Paid / Selesai)
  static const Color accentSoft = Color(0xFFD1FAE5); // Emerald 100
  static const Color warning = Color(0xFFD97706); // Amber Warning
  static const Color warningSoft = Color(0xFFFEF3C7);
  static const Color danger = Color(0xFFDC2626); // Red 600 (Void / Dibatalkan)
  static const Color dangerSoft = Color(0xFFFEE2E2);
  static const Color info = Color(0xFF2563EB); // Blue 600 (Dine-in / Reserved)
  static const Color infoSoft = Color(0xFFDBEAFE);

  // Light Palette (Cerah - Default Modern Cafe)
  static const Color lightBackground = Color(0xFFF8FAFC); // Clean crisp canvas
  static const Color lightSurface = Color(0xFFFFFFFF); // Pure white cards
  static const Color lightSurfaceLight = Color(0xFFF1F5F9); // Light slate hover/pills
  static const Color lightBorder = Color(0xFFE2E8F0);
  static const Color lightBorderSubtle = Color(0xFFF1F5F9);
  static const Color lightTextPrimary = Color(0xFF0F172A); // Deep slate text
  static const Color lightTextSecondary = Color(0xFF475569); // Slate 600
  static const Color lightTextMuted = Color(0xFF94A3B8); // Slate 400

  // Dark Palette (Opsional untuk shift malam)
  static const Color darkBackground = Color(0xFF0F172A);
  static const Color darkSurface = Color(0xFF1E293B);
  static const Color darkSurfaceLight = Color(0xFF334155);
  static const Color darkBorder = Color(0xFF334155);
  static const Color darkTextPrimary = Color(0xFFF8FAFC);
  static const Color darkTextSecondary = Color(0xFF94A3B8);
  static const Color darkTextMuted = Color(0xFF64748B);

  // Fallback / standard aliases (defaulting to clean light)
  static const Color background = lightBackground;
  static const Color surface = lightSurface;
  static const Color surfaceLight = lightSurfaceLight;
  static const Color cardBackground = lightSurface;
  static const Color textPrimary = lightTextPrimary;
  static const Color textSecondary = lightTextSecondary;
  static const Color textMuted = lightTextMuted;
  static const Color border = lightBorder;
  static const Color borderSubtle = lightBorderSubtle;
}
