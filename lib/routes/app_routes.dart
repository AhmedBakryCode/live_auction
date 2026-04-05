import 'package:flutter/material.dart';
import '../features/dashboard/screens/dashboard_screen.dart';
import '../features/auctions/screens/create_auction_screen.dart';
import '../features/auctions/screens/auctions_screen.dart';
import '../features/auctions/screens/paid_auctions_screen.dart';
import '../features/auctions/screens/reposted_auctions_screen.dart';
import '../features/auctions/screens/closed_auctions_screen.dart';
import '../features/auctions/screens/upcoming_auctions_screen.dart';
import '../features/auctions/screens/active_auctions_screen.dart';
import '../features/auctions/screens/filter_auctions_screen.dart';
import '../features/auctions/screens/search_auctions_screen.dart';
import '../features/users/screens/users_screen.dart';
import '../features/users/screens/create_user_screen.dart';
import '../features/bids/screens/bids_history_screen.dart';
import '../features/wallet/screens/wallet_screen.dart';
import '../features/leaderboard/screens/leaderboard_screen.dart';
import '../features/auth/screens/register_screen.dart';
import '../features/auth/screens/profile_screen.dart';

import '../features/auth/screens/login_screen.dart';

class AppRoutes {
  static const String dashboard = '/';
  static const String login = '/login';
  static const String createAuction = '/create-auction';
  static const String auctions = '/auctions';
  static const String paidAuctions = '/paid-auctions';
  static const String repostedAuctions = '/reposted-auctions';
  static const String closedAuctions = '/closed-auctions';
  static const String upcomingAuctions = '/upcoming-auctions';
  static const String activeAuctions = '/active-auctions';
  static const String filterAuctions = '/filter-auctions';
  static const String searchAuctions = '/search-auctions';
  static const String users = '/users';
  static const String createUser = '/create-user';
  static const String bidsHistory = '/bids-history';
  static const String wallet = '/wallet';
  static const String leaderboard = '/leaderboard';
  static const String register = '/register';
  static const String profile = '/profile';

  static Map<String, WidgetBuilder> get routes => {
    dashboard: (context) => const DashboardScreen(),
    login: (context) => const LoginScreen(),

    createAuction: (context) => const CreateAuctionScreen(),
    auctions: (context) => const AuctionsAdminScreen(),
    paidAuctions: (context) => const PaidAuctionsScreen(),
    repostedAuctions: (context) => const RepostedAuctionsScreen(),
    closedAuctions: (context) => const ClosedAuctionsScreen(),
    upcomingAuctions: (context) => const UpcomingAuctionsScreen(),
    activeAuctions: (context) => const ActiveAuctionsScreen(),
    filterAuctions: (context) => const FilterAuctionsScreen(),
    searchAuctions: (context) => const SearchAuctionsScreen(),
    users: (context) => const UsersAdminScreen(),
    createUser: (context) => const CreateUserScreen(),
    bidsHistory: (context) => const BidsHistoryScreen(),
    wallet: (context) => const WalletAdminScreen(),
    leaderboard: (context) => const LeaderboardScreen(),
    register: (context) => const RegisterScreen(),
    profile: (context) => const ProfileScreen(),
  };
}
