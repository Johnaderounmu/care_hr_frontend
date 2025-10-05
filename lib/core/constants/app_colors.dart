import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors
  static const Color primary = Color(0xFF11A4D4);
  static const Color secondary = Color(0xFF078836);

  // Background Colors
  static const Color backgroundLight = Color(0xFFF6F8F8);
  static const Color backgroundDark = Color(0xFF101D22);

  // Text Colors
  static const Color textLight = Color(0xFF101D22);
  static const Color textDark = Color(0xFFF6F8F8);

  // Subtle Colors
  static const Color subtleLight = Color(0xFFE3E9E9);
  static const Color subtleDark = Color(0xFF1B2C32);

  // Border Colors
  static const Color borderLight = Color(0xFFCFE1E7);
  static const Color borderDark = Color(0xFF2D4A55);

  // Muted Colors
  static const Color mutedLight = Color(0xFF6B7F86);
  static const Color mutedDark = Color(0xFF9CB0B6);

  // Placeholder Colors
  static const Color placeholderLight = Color(0xFF6B7F86);
  static const Color placeholderDark = Color(0xFF9CB0B6);

  // Status Colors
  static const Color success = Color(0xFF078836);
  static const Color warning = Color(0xFFFF9800);
  static const Color error = Color(0xFFE53935);
  static const Color info = Color(0xFF2196F3);

  // Accent Colors
  static const Color accentSuccess = Color(0xFF078836);
  static const Color accentWarning = Color(0xFFFF9800);
  static const Color accentError = Color(0xFFE53935);
  static const Color accentInfo = Color(0xFF11A4D4);

  // Neutral Colors
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color transparent = Color(0x00000000);

  // Gradient Colors
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, Color(0xFF0D8BB8)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient successGradient = LinearGradient(
    colors: [success, Color(0xFF056A2A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Chart Colors
  static const List<Color> chartColors = [
    primary,
    success,
    warning,
    error,
    info,
    Color(0xFF9C27B0),
    Color(0xFFFF5722),
    Color(0xFF607D8B),
  ];
}
