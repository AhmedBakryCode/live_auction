import 'package:flutter/material.dart';
import '../admin/dashboard/screens/dashboard_screen.dart';
import '../admin/auctions/screens/create_auction_screen.dart';
import '../admin/auctions/screens/auctions_screen.dart';
import '../admin/users/screens/users_screen.dart';
import '../admin/users/screens/create_user_screen.dart';
import '../admin/bids/screens/bids_history_screen.dart';
import '../admin/wallet/screens/wallet_screen.dart';
import '../admin/leaderboard/screens/leaderboard_screen.dart';
import '../admin/auth/screens/register_screen.dart';
import '../admin/auth/screens/profile_screen.dart';
import '../admin/auth/screens/login_screen.dart';
import '../admin/notifications/screens/notifications_screen.dart';

class AppRoutes {
  static const String dashboard = '/';
  static const String login = '/login';
  static const String createAuction = '/create-auction';
  static const String auctions = '/auctions';
  static const String users = '/users';
  static const String createUser = '/create-user';
  static const String bidsHistory = '/bids-history';
  static const String wallet = '/wallet';
  static const String leaderboard = '/leaderboard';
  static const String register = '/register';
  static const String profile = '/profile';
  static const String notifications = '/notifications';

  static Map<String, WidgetBuilder> get routes => {
    dashboard: (context) => const DashboardScreen(),
    login: (context) => const LoginScreen(),
    createAuction: (context) => const CreateAuctionScreen(),
    auctions: (context) => const AuctionsAdminScreen(),
    users: (context) => const UsersAdminScreen(),
    createUser: (context) => const CreateUserScreen(),
    bidsHistory: (context) => const BidsHistoryScreen(),
    wallet: (context) => const WalletAdminScreen(),
    leaderboard: (context) => const LeaderboardScreen(),
    register: (context) => const RegisterScreen(),
    profile: (context) => const ProfileScreen(),
    notifications: (context) => const NotificationsScreen(),
  };
}
