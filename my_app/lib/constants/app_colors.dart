import 'package:flutter/material.dart';

/// Common color and gradient definitions for the Mahal Spot Owner Profile.
class AppColors {
  AppColors._();

  static const Color background = Color(0xFFF2F2F2);
  static const Color cardBackground = Colors.white;
  static const Color softShadow = Color(0x26000000);

  static const Color textPrimary = Color(0xFF1F1F1F);
  static const Color textSecondary = Color(0xFF6B6B6B);
  static const Color verifiedBadge = Color(0xFF1E88E5);
  static const Color pending = Colors.orange;
  static const Color confirmed = Colors.green;
  static const Color cancelled = Colors.red;

  static const Color gradientStart = Colors.orange;
  static const Color gradientEnd = Colors.deepOrange;

  static const Gradient primaryGradient = LinearGradient(
    colors: [gradientStart, gradientEnd],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
