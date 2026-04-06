import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import '../network/dio_client.dart';
import '../network/api_service.dart';
import 'socket_service.dart';
import 'notification_service.dart';
import 'local_storage_service.dart';
import '../../features/auctions/presentation/bloc/auction_bloc.dart';
import '../../features/auctions/domain/repositories/auction_repository.dart';
import '../../features/auctions/data/repositories/auction_repository_impl.dart';
import '../../features/auctions/data/datasources/auction_remote_datasource.dart';
import '../../features/auctions/presentation/bloc/bidding_bloc.dart';
import '../../features/auctions/presentation/bloc/bid_history_bloc.dart';
import '../../features/wallet/presentation/bloc/wallet_bloc.dart';
import '../../features/wallet/domain/repositories/wallet_repository.dart';
import '../../features/wallet/data/repositories/wallet_repository_impl.dart';
import '../../features/wallet/data/datasources/wallet_remote_datasource.dart';
import '../../features/watchlist/presentation/bloc/watchlist_bloc.dart';
import '../../features/watchlist/domain/repositories/watchlist_repository.dart';
import '../../features/watchlist/data/repositories/watchlist_repository_impl.dart';
import '../../features/watchlist/data/datasources/watchlist_remote_datasource.dart';
import '../../features/notifications/presentation/bloc/notifications_bloc.dart';
import '../../features/notifications/domain/repositories/notification_repository.dart';
import '../../features/notifications/data/repositories/notification_repository_impl.dart';
import '../../features/notifications/data/datasources/notification_remote_datasource.dart';
import '../../features/user_stats/presentation/bloc/user_stats_bloc.dart';
import '../../features/user_stats/domain/repositories/user_stats_repository.dart';
import '../../features/user_stats/data/repositories/user_stats_repository_impl.dart';
import '../../features/user_stats/data/datasources/user_stats_remote_datasource.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../../features/profile/presentation/bloc/profile_bloc.dart';
import '../../features/profile/domain/repositories/profile_repository.dart';
import '../../features/profile/data/repositories/profile_repository_impl.dart';
import '../../features/profile/data/datasources/profile_remote_datasource.dart';
import '../../features/leaderboard/presentation/bloc/leaderboard_bloc.dart';
import '../../features/leaderboard/domain/repositories/leaderboard_repository.dart';
import '../../features/leaderboard/data/repositories/leaderboard_repository_impl.dart';
import '../../features/leaderboard/data/datasources/leaderboard_remote_datasource.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // External
  sl.registerLazySingleton(() => Dio());

  // Core
  sl.registerLazySingleton(() => DioClient(sl(), sl()));
  sl.registerLazySingleton<ApiService>(() => ApiServiceImpl(sl()));
  sl.registerLazySingleton(() => SocketService());
  sl.registerLazySingleton(() => NotificationService());

  sl.registerLazySingleton<LocalStorageService>(
    () => LocalStorageServiceImpl(),
  );

  // Auth
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(sl<DioClient>().dio),
  );
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(sl(), sl()),
  );
  sl.registerFactory(() => AuthBloc(authRepository: sl()));

  // Features - Auctions
  sl.registerLazySingleton<AuctionRemoteDataSource>(
    () => AuctionRemoteDataSourceImpl(sl<DioClient>().dio),
  );
  sl.registerLazySingleton<AuctionRepository>(
    () => AuctionRepositoryImpl(sl()),
  );
  sl.registerFactory(() => AuctionBloc(repository: sl()));
  sl.registerFactory(() => BiddingBloc());
  sl.registerFactory(() => BidHistoryBloc(repository: sl()));

  // Features - Wallet
  sl.registerLazySingleton<WalletRemoteDataSource>(
    () => WalletRemoteDataSourceImpl(sl<DioClient>().dio),
  );
  sl.registerLazySingleton<WalletRepository>(() => WalletRepositoryImpl(sl()));
  sl.registerFactory(() => WalletBloc(sl()));

  // Features - Watchlist
  sl.registerLazySingleton<WatchlistRemoteDataSource>(
    () => WatchlistRemoteDataSourceImpl(sl<DioClient>().dio),
  );
  sl.registerLazySingleton<WatchlistRepository>(
    () => WatchlistRepositoryImpl(sl()),
  );
  sl.registerFactory(() => WatchlistBloc(repository: sl()));

  // Features - Notifications
  sl.registerLazySingleton<NotificationRemoteDataSource>(
    () => NotificationRemoteDataSourceImpl(sl<DioClient>().dio),
  );
  sl.registerLazySingleton<NotificationRepository>(
    () => NotificationRepositoryImpl(sl()),
  );
  sl.registerFactory(() => NotificationsBloc(sl()));

  // Features - User Stats
  sl.registerLazySingleton<UserStatsRemoteDataSource>(
    () => UserStatsRemoteDataSourceImpl(sl<DioClient>().dio),
  );
  sl.registerLazySingleton<UserStatsRepository>(
    () => UserStatsRepositoryImpl(sl()),
  );
  sl.registerFactory(() => UserStatsBloc(sl()));

  // Features - Profile
  sl.registerLazySingleton<ProfileRemoteDataSource>(
    () => ProfileRemoteDataSourceImpl(sl<DioClient>().dio),
  );
  sl.registerLazySingleton<ProfileRepository>(
    () => ProfileRepositoryImpl(sl()),
  );
  sl.registerFactory(() => ProfileBloc(sl()));

  // Features - Leaderboard
  sl.registerLazySingleton<LeaderboardRemoteDataSource>(
    () => LeaderboardRemoteDataSourceImpl(sl<DioClient>().dio),
  );
  sl.registerLazySingleton<LeaderboardRepository>(
    () => LeaderboardRepositoryImpl(sl()),
  );
  sl.registerFactory(() => LeaderboardBloc(sl()));
}
