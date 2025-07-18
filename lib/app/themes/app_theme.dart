import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';

class AppTheme {
  static final NeumorphicThemeData lightTheme = NeumorphicThemeData(
    baseColor: const Color(0xFFE0E5EC),
    lightSource: LightSource.topLeft,
    accentColor: const Color(0xFFBCAAA4),
    depth: 8,
    intensity: 0.6,
    boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(12)),
    textTheme: const TextTheme(
      titleLarge: TextStyle(
        color: Color(0xFF373A40),
        fontWeight: FontWeight.bold,
      ),
      bodyLarge: TextStyle(
        color: Color(0xFF373A40),
      ),
       titleMedium: TextStyle(
        color: Color(0xFF373A40),
        fontWeight: FontWeight.bold,
      ),
    ),
    iconTheme: const IconThemeData(
      color: Color(0xFF373A40),
      size: 24,
    ),
  );

  static final NeumorphicThemeData darkTheme = NeumorphicThemeData.dark(
    baseColor: const Color(0xFF373A40),
    lightSource: LightSource.topLeft,
    accentColor: const Color(0xFFBCAAA4),
    depth: 4,
    intensity: 0.5,
     boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(12)),
     textTheme: const TextTheme(
      titleLarge: TextStyle(
        color: Color(0xFFE0E5EC),
        fontWeight: FontWeight.bold,
      ),
      bodyLarge: TextStyle(
        color: Color(0xFFE0E5EC),
      ),
      titleMedium: TextStyle(
        color: Color(0xFFE0E5EC),
        fontWeight: FontWeight.bold,
      ),
    ),
    iconTheme: const IconThemeData(
      color: Color(0xFFE0E5EC),
      size: 24,
    ),
  );
}
