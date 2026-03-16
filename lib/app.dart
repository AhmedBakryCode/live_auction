import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/services/service_locator.dart';
import 'features/auctions/presentation/bloc/auction_bloc.dart';
import 'features/auctions/presentation/bloc/bidding_bloc.dart';
import 'features/auctions/presentation/bloc/bid_history_bloc.dart';
import 'features/wallet/presentation/bloc/wallet_bloc.dart';
import 'features/watchlist/presentation/bloc/watchlist_bloc.dart';
import 'features/notifications/presentation/bloc/notifications_bloc.dart';
import 'features/leaderboard/presentation/bloc/leaderboard_bloc.dart';

class LiveAuctionApp extends StatelessWidget {
  const LiveAuctionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => sl<AuctionBloc>()),
        BlocProvider(create: (context) => sl<BiddingBloc>()),
        BlocProvider(create: (context) => sl<BidHistoryBloc>()),
        BlocProvider(create: (context) => sl<WalletBloc>()),
        BlocProvider(create: (context) => sl<WatchlistBloc>()),
        BlocProvider(create: (context) => sl<NotificationsBloc>()),
        BlocProvider(create: (context) => sl<LeaderboardBloc>()),
      ],
      child: MaterialApp(
        title: 'مزاد لايف',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        onGenerateRoute: AppRouter.onGenerateRoute,
        initialRoute: AppRouter.dashboard,
        locale: const Locale('ar', 'EG'),
        supportedLocales: const [
          Locale('ar', 'EG'),
          Locale('en', 'US'),
        ],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
      ),
    );
  }
}


