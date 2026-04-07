class AppConfig {
  // ─── Base URL ─────────────────────────────────────────────────────────────
  // Change this to your server's base URL. All repositories use this constant.
  static const String baseUrl = 'http://192.168.1.32:8000';

  // ─── API Prefixes ─────────────────────────────────────────────────────────
  static const String authPrefix = '$baseUrl/api/auth';
  static const String adminPrefix = '$baseUrl/api/admin';
  static const String apiPrefix = '$baseUrl/api';

  // ─── Endpoints ────────────────────────────────────────────────────────────
  static const String loginEndpoint = '$authPrefix/login';
  static const String registerEndpoint = '$authPrefix/register';
  static const String meEndpoint = '$authPrefix/me';
  static const String logoutEndpoint = '$authPrefix/logout';
  static const String refreshTokenEndpoint = '$authPrefix/refresh-token';
  static const String updateProfileEndpoint = '$apiPrefix/profile';

  static const String dashboardEndpoint = '$adminPrefix/dashboard';
  static const String adminUsersEndpoint = '$adminPrefix/users';

  static const String auctionsEndpoint = '$apiPrefix/auctions';
  static const String leaderboardEndpoint = '$apiPrefix/leaderboard';
  static const String notificationsEndpoint = '$apiPrefix/notifications';
  static const String unreadNotificationsEndpoint = '$apiPrefix/notifications/unread';
  static const String readAllNotificationsEndpoint = '$apiPrefix/notifications/read-all';
  static const String paymentsDepositEndpoint = '$apiPrefix/payments/deposit';
  static const String walletGetEndpoint = '$apiPrefix/wallet-get';
  static const String walletDeleteEndpoint = '$apiPrefix/wallet';
  static const String walletTransactionsEndpoint = '$apiPrefix/wallet/transactions';

  // ─── Timeouts ─────────────────────────────────────────────────────────────
  static const Duration defaultTimeout = Duration(seconds: 15);
  static const Duration uploadTimeout = Duration(seconds: 30);
}
