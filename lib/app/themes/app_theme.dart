import 'package:flutter/material.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';

class AppTheme {
  static const Color primaryColor = Color(0xFFE0E5EC);
  static const Color accentColor = Color(0xFFBCAAA4);
  static const Color textColor = Color(0xFF373A40);

  static final NeumorphicThemeData themeData = NeumorphicThemeData(
    baseColor: primaryColor,
    lightSource: LightSource.topLeft,
    accentColor: accentColor,
    depth: 8,
    intensity: 0.6,
    boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(12)),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        color: textColor,
        fontWeight: FontWeight.bold,
      ),
      bodyLarge: TextStyle(
        color: textColor,
      ),
    ),
    iconTheme: const IconThemeData(
      color: textColor,
      size: 24,
    ),
  );
}
