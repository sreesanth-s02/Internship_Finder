import 'package:flutter/material.dart';

class AppColors {
  // Primary branding colors
  static const Color primaryBlue = Color(0xFF0D47A1); // deep blue for navbar
  static const Color gradientBlue = Color(0xFF1976D2); // lighter gradient tone
  static const Color accentOrange = Color(0xFFFF8C42); // buttons / highlights

  // Backgrounds
  static const Color backgroundWhite = Color(0xFFFFFFFF);
  static const Color lightGray = Color(0xFFF4F6FA);
  static const Color footerBlue = Color(0xFF0B1B3A);

  // New: Card background color
  static const Color primaryCard = Color(0xFF1B1F30); // matches your HTML card

  // Text colors
  static const Color textPrimary = Color(0xFF1E293B); // dark navy gray
  static const Color textSecondary = Color(0xFF64748B); // lighter gray
  static const Color textWhite = Color(0xFFFFFFFF);

  // Shadows and borders
  static const Color shadowColor = Color(0x1F000000); // black12 equivalent
  static const Color borderColor = Color(0xFFE2E8F0);

  // Gradients (for hero backgrounds, sections)
  static const LinearGradient blueGradient = LinearGradient(
    colors: [primaryBlue, gradientBlue],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Utility colors for error/success states
  static const Color success = Color(0xFF22C55E);
  static const Color error = Color(0xFFEF4444);

  // example addition inside lib/theme/app_colors.dart
static const Color darkCard = Color(0xFF153E88);

  // ignore: prefer_typing_uninitialized_variables
  static var primaryBlueDark; // adjust to match your theme

}
