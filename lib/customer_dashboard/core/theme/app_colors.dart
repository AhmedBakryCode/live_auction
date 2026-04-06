import 'package:flutter/material.dart';

class AppColors {
  // Primary & Secondary
  static const Color primary = Color(0xFF6200EE);
  static const Color primaryVariant = Color(0xFF3700B3);
  static const Color secondary = Color(0xFF03DAC6);
  
  // Background & Surface
  static const Color background = Color(0xFFF5F5F5);
  static const Color surface = Colors.white;
  static const Color error = Color(0xFFB00020);
  
  // Text Colors
  static const Color textPrimary = Color(0xFF1D1B20);
  static const Color textSecondary = Color(0xFF49454F);
  static const Color textPrimaryDark = Color(0xFFE6E1E5);
  static const Color textSecondaryDark = Color(0xFFCAC4D0);
  static const Color textWhite = Colors.white;
  
  // Auction specific
  static const Color liveBadge = Color(0xFFFF0000);
  static const Color priceGreen = Color(0xFF4CAF50);
  static const Color timerOrange = Color(0xFFFF9800);
  
  // Dark Mode colors
  static const Color darkBackground = Color(0xFF1D1B20);
  static const Color darkSurface = Color(0xFF2B2930);

  // Adaptive Helpers
  static Color getPrimaryText(BuildContext context) =>
      Theme.of(context).brightness == Brightness.light ? textPrimary : textPrimaryDark;
      
  static Color getSecondaryText(BuildContext context) =>
      Theme.of(context).brightness == Brightness.light ? textSecondary : textSecondaryDark;

  static Color getContainerColor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.light ? Colors.grey[100]! : darkSurface;
}
