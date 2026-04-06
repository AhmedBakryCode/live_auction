import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'app_router.dart';
import 'customer_dashboard/core/theme/app_theme.dart';
import 'customer_dashboard/core/services/service_locator.dart';
import 'customer_dashboard/core/services/socket_service.dart';
import 'customer_dashboard/features/auctions/presentation/bloc/auction_bloc.dart';
import 'customer_dashboard/features/auctions/presentation/bloc/bidding_bloc.dart';
import 'customer_dashboard/features/auctions/presentation/bloc/bid_history_bloc.dart';
import 'customer_dashboard/features/wallet/presentation/bloc/wallet_bloc.dart';
import 'customer_dashboard/features/watchlist/presentation/bloc/watchlist_bloc.dart';
import 'customer_dashboard/features/notifications/presentation/bloc/notifications_bloc.dart';
import 'customer_dashboard/features/user_stats/presentation/bloc/user_stats_bloc.dart';
import 'customer_dashboard/features/profile/presentation/bloc/profile_bloc.dart';
import 'customer_dashboard/features/auth/presentation/bloc/auth_bloc.dart';

class LiveAuctionApp extends StatelessWidget {
  const LiveAuctionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [Provider<SocketService>(create: (_) => sl<SocketService>())],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => sl<AuthBloc>()..add(CheckAuthStatus()),
          ),
          BlocProvider(create: (context) => sl<AuctionBloc>()),
          BlocProvider(create: (context) => sl<BiddingBloc>()),
          BlocProvider(create: (context) => sl<BidHistoryBloc>()),
          BlocProvider(create: (context) => sl<WalletBloc>()),
          BlocProvider(create: (context) => sl<WatchlistBloc>()),
          BlocProvider(create: (context) => sl<NotificationsBloc>()),
          BlocProvider(create: (context) => sl<UserStatsBloc>()),
          BlocProvider(create: (context) => sl<ProfileBloc>()),
        ],
        child: MaterialApp(
          title: 'مزاد لايف',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeMode.system,
          onGenerateRoute: AppRouter.onGenerateRoute,
          initialRoute: AppRouter.authWrapper,
          locale: const Locale('ar', 'EG'),
          supportedLocales: const [Locale('ar', 'EG'), Locale('en', 'US')],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
        ),
      ),
    );
  }
}
