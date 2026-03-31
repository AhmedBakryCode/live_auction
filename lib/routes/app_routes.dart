import 'package:flutter/material.dart';
import '../features/dashboard/screens/dashboard_screen.dart';
import '../features/auctions/screens/create_auction_screen.dart';
import '../features/auctions/screens/auctions_screen.dart';
import '../features/users/screens/users_screen.dart';
import '../features/users/screens/all_users_list_screen.dart';
import '../features/bids/screens/bids_history_screen.dart';
import '../features/wallet/screens/wallet_screen.dart';
import '../features/leaderboard/screens/leaderboard_screen.dart';

class AppRoutes {
  static const String dashboard = '/';
  static const String createAuction = '/create-auction';
  static const String auctions = '/auctions';
  static const String users = '/users';
  static const String allUsersList = '/all-users-list';
  static const String bidsHistory = '/bids-history';
  static const String wallet = '/wallet';
  static const String leaderboard = '/leaderboard';
  static Map<String, WidgetBuilder> get routes => {
        dashboard: (context) => const DashboardScreen(),
        createAuction: (context) => const CreateAuctionScreen(),
        auctions: (context) => const AuctionsAdminScreen(),
        users: (context) => const UsersAdminScreen(),
        allUsersList: (context) => const AllUsersListScreen(),
        bidsHistory: (context) => const BidsHistoryScreen(),
        wallet: (context) => const WalletAdminScreen(),
        leaderboard: (context) => const LeaderboardScreen(),
      };
}
