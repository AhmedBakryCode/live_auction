class ApiConstants {
  static const String baseUrl =
      'http://192.168.1.32:8000/api'; // Replace with real URL
  static const String socketUrl = 'https://socket.live-auction.com';

  // Auth Endpoints
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String logout = '/auth/logout';

  // Auction Endpoints
  static const String activeAuctions = '/auctions/active';
  static const String upcomingAuctions = '/auctions/upcoming';
  static const String closedAuctions = '/auctions/closed';
  static const String repostedAuctions = '/auctions/reposted';
  static const String paidAuctions = '/auctions/paid';
  static const String auctionDetails = '/auctions/';
  static String joinAuction(int id) => '/auctions/join/$id';
  static const String bids = '/bids';
  static String auctionBids(int id) => '/auctions/$id/bids';

  // Wallet Endpoints
  static const String walletGet = '/wallet-get';
  static const String walletTransactions = '/wallet/transactions';
  static const String deposit = '/payments/deposit';

  // Paymob Integration Constants
  static const int paymobCardIntegrationId = 5586726;
  static const int paymobWalletIntegrationId = 5593210;
  static const int paymobCardIframeId = 33333;

  // Leaderboard Endpoints
  static const String userStats = '/user-stats';
  static const String leaderboard = '/leaderboard';

  // Profile Endpoints
  static const String profile = '/profile';
  static const String updateProfile = '/profile';
  static const String changePassword = '/profile/change-password';

  // Notification Endpoints
  static const String notifications = '/notifications';
  static String markNotificationAsRead(String id) => '/notifications/$id/read';
  static const String markAllNotificationsAsRead = '/notifications/read-all';

  // User Bids Endpoints (Watchlist)
  static const String userBids = '/user/participated-auctions';
  static String auctionById(int id) => '/auctions/$id';
}
