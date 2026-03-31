import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'core/theme/app_colors.dart';
import 'routes/app_routes.dart';

void main() {
  runApp(const LiveAuctionAdminApp());
}

class LiveAuctionAdminApp extends StatelessWidget {
  const LiveAuctionAdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'لوحة إدارة المزادات',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        primaryColor: AppColors.primary,
        scaffoldBackgroundColor: AppColors.background,
        cardColor: AppColors.card,
        dividerColor: AppColors.border,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.primary,
          secondary: AppColors.secondary,
          surface: AppColors.surface,
          background: AppColors.background,
          error: AppColors.error,
        ),
        textTheme: GoogleFonts.cairoTextTheme().apply(
          bodyColor: AppColors.textPrimary,
          displayColor: AppColors.textPrimary,
        ),
      ),
      initialRoute: '/',
      routes: AppRoutes.routes,
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: child!,
        );
      },
    );
  }
}