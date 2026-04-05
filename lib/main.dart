import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_colors.dart';
import 'routes/app_routes.dart';
import 'features/users/providers/users_provider.dart';
import 'features/dashboard/providers/dashboard_provider.dart';
import 'features/bids/providers/bids_provider.dart';

import 'core/services/token_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final bool hasToken = await TokenManager.hasToken();
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UsersProvider()),
        ChangeNotifierProvider(create: (_) => DashboardProvider()),
        ChangeNotifierProvider(create: (_) => BidsProvider()),
      ],
      child: LiveAuctionAdminApp(initialRoute: hasToken ? AppRoutes.dashboard : AppRoutes.login),
    ),
  );
}

class LiveAuctionAdminApp extends StatelessWidget {
  final String initialRoute;
  const LiveAuctionAdminApp({super.key, required this.initialRoute});

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
          error: AppColors.error,
        ),
        textTheme: GoogleFonts.cairoTextTheme().apply(
          bodyColor: AppColors.textPrimary,
          displayColor: AppColors.textPrimary,
        ),
      ),
      initialRoute: initialRoute,
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