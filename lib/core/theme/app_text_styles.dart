import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTextStyles {
  static TextStyle get heading1 => GoogleFonts.cairo(
        fontSize: 28,
        fontWeight: FontWeight.bold,
      );

  static TextStyle get heading2 => GoogleFonts.cairo(
        fontSize: 24,
        fontWeight: FontWeight.w600,
      );

  static TextStyle get heading3 => GoogleFonts.cairo(
        fontSize: 20,
        fontWeight: FontWeight.w600,
      );

  static TextStyle get bodyLarge => GoogleFonts.cairo(
        fontSize: 16,
        fontWeight: FontWeight.normal,
      );

  static TextStyle get bodyMedium => GoogleFonts.cairo(
        fontSize: 14,
        fontWeight: FontWeight.normal,
      );

  static TextStyle get caption => GoogleFonts.cairo(
        fontSize: 12,
        fontWeight: FontWeight.w400,
      );

  static TextStyle get priceStyle => GoogleFonts.cairo(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: AppColors.priceGreen,
      );
}
