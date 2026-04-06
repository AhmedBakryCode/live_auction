import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTextStyles {
  static TextStyle get heading1 => const TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    fontFamily: 'Cairo',
  );

  static TextStyle get heading2 => const TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    fontFamily: 'Cairo',
  );

  static TextStyle get heading3 => const TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    fontFamily: 'Cairo',
  );

  static TextStyle get bodyLarge => const TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    fontFamily: 'Cairo',
  );

  static TextStyle get bodyMedium => const TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    fontFamily: 'Cairo',
  );

  static TextStyle get caption => const TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    fontFamily: 'Cairo',
  );

  static TextStyle get priceStyle => TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    fontFamily: 'Cairo',
    color: AppColors.priceGreen,
  );
}
