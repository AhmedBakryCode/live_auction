import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'admin_dashboard/admin/auctions/providers/auctions_provider.dart';
import 'admin_dashboard/admin/bids/providers/bids_provider.dart';
import 'admin_dashboard/admin/dashboard/providers/dashboard_provider.dart';
import 'admin_dashboard/admin/leaderboard/providers/leaderboard_provider.dart';
import 'admin_dashboard/admin/notifications/providers/notifications_provider.dart';
import 'admin_dashboard/admin/users/providers/users_provider.dart';
import 'admin_dashboard/admin/wallet/providers/payments_provider.dart';
import 'admin_dashboard/admin/wallet/providers/wallet_provider.dart';
import 'admin_dashboard/core/network/api_helper.dart';
import 'admin_dashboard/core/services/token_manager.dart';
import 'admin_dashboard/core/theme/app_colors.dart';
import 'admin_dashboard/routes/app_routes.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final navigatorKey = GlobalKey<NavigatorState>();
  ApiHelper.navigatorKey = navigatorKey;

  final bool hasToken = await TokenManager.hasToken();
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UsersProvider()),
        ChangeNotifierProvider(create: (_) => DashboardProvider()),
        ChangeNotifierProvider(create: (_) => BidsProvider()),
        ChangeNotifierProvider(create: (_) => NotificationsProvider()),
        ChangeNotifierProvider(create: (_) => PaymentsProvider()),
        ChangeNotifierProvider(create: (_) => LeaderboardProvider()),
        ChangeNotifierProvider(create: (_) => AuctionsProvider()),
        ChangeNotifierProvider(create: (_) => WalletProvider()),
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
      navigatorKey: ApiHelper.navigatorKey,
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