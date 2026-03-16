import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import '../network/dio_client.dart';
import '../network/api_service.dart';
import 'socket_service.dart';
import 'notification_service.dart';
import '../../features/auctions/presentation/bloc/auction_bloc.dart';
import '../../features/auctions/presentation/bloc/bidding_bloc.dart';
import '../../features/auctions/presentation/bloc/bid_history_bloc.dart';
import '../../features/wallet/presentation/bloc/wallet_bloc.dart';
import '../../features/watchlist/presentation/bloc/watchlist_bloc.dart';
import '../../features/notifications/presentation/bloc/notifications_bloc.dart';
import '../../features/leaderboard/presentation/bloc/leaderboard_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // External
  sl.registerLazySingleton(() => Dio());

  // Core
  sl.registerLazySingleton(() => DioClient(sl()));
  sl.registerLazySingleton<ApiService>(() => ApiServiceImpl(sl()));
  sl.registerLazySingleton(() => SocketService());
  sl.registerLazySingleton(() => NotificationService());

  // Features - Auctions
  sl.registerFactory(() => AuctionBloc());
  sl.registerFactory(() => BiddingBloc());
  sl.registerFactory(() => BidHistoryBloc());

  // Features - Wallet
  sl.registerFactory(() => WalletBloc());

  // Features - Watchlist
  sl.registerFactory(() => WatchlistBloc());

  // Features - Notifications
  sl.registerFactory(() => NotificationsBloc());

  // Features - Leaderboard
  sl.registerFactory(() => LeaderboardBloc());
}
