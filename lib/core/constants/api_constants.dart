class ApiConstants {
  static const String baseUrl = 'https://api.live-auction.com/v1'; // Replace with real URL
  static const String socketUrl = 'https://socket.live-auction.com';
  
  // Auth Endpoints
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String logout = '/auth/logout';
  
  // Auction Endpoints
  static const String activeAuctions = '/auctions/active';
  static const String auctionDetails = '/auctions/';
  static const String placeBid = '/auctions/bid';
  
  // Wallet Endpoints
  static const String walletBalance = '/wallet/balance';
  static const String transactions = '/wallet/transactions';
}
