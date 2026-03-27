import 'package:flutter/material.dart';

class AppColors {
  // Primary color
  static const Color primary = Color(0xFFE23661);
  
  // Background colors
  static const Color backgroundLight = Color(0xFFFBF8F9);
  static const Color backgroundDark = Color(0xFF211115);
  
  // Surface colors
  static const Color surfaceLight = Color(0xFFFBF8F9);
  static const Color surfaceDark = Color(0xFF2C1A1F);
  
  // On-surface colors (text on surfaces)
  static const Color onSurfaceLight = Color(0xFF1B0E11);
  static const Color onSurfaceDark = Color(0xFFE6D1D6);
  
  // On-surface variant colors (secondary text)
  static const Color onSurfaceVariantLight = Color(0xFF955062);
  static const Color onSurfaceVariantDark = Color(0xFFCFA0AB);

  // Legacy colors (for backward compatibility)
  static const Color primaryPink = primary;
  static const Color softPinkBg = backgroundLight;
  static const Color accentPink = primary;
  static const Color textDark = onSurfaceLight;
  static const Color textMuted = onSurfaceVariantLight;
  static const Color textLight = Color(0xFFFFFFFF);

  // Glassmorphism specific
  static const Color glassWhite = Color.fromRGBO(255, 255, 255, 0.6);
  static const Color glassBorder = Color.fromRGBO(255, 255, 255, 0.4);
  
  static const List<Color> glassGradient = [
    Color.fromRGBO(255, 255, 255, 0.7),
    Color.fromRGBO(255, 255, 255, 0.3),
  ];
}
