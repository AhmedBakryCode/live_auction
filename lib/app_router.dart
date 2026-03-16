import 'package:flutter/material.dart';
import 'features/customer_dashboard/presentation/pages/customer_dashboard_page.dart';
import 'features/auctions/presentation/pages/all_auctions_page.dart';
import 'features/auctions/presentation/pages/auction_details_page.dart';
import 'features/auctions/presentation/pages/live_bidding_page.dart';
import 'features/auctions/presentation/pages/bid_history_page.dart';
import 'features/profile/presentation/pages/profile_page.dart';
import 'features/profile/presentation/pages/edit_profile_page.dart';
import 'features/auctions/domain/entities/auction.dart';

class AppRouter {
  static const String dashboard = '/';
  static const String allAuctions = '/all-auctions';
  static const String auctionDetails = '/auction-details';
  static const String liveBidding = '/live-bidding';
  static const String bidHistory = '/bid-history';
  static const String profile = '/profile';
  static const String editProfile = '/edit-profile';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case dashboard:
        return MaterialPageRoute(builder: (_) => const CustomerDashboardPage());
      case allAuctions:
        return MaterialPageRoute(builder: (_) => const AllAuctionsPage());
      case auctionDetails:
        final auction = settings.arguments as Auction;
        return MaterialPageRoute(builder: (_) => AuctionDetailsPage(auction: auction));
      case liveBidding:
        final auction = settings.arguments as Auction;
        return MaterialPageRoute(builder: (_) => LiveBiddingPage(auction: auction));
      case bidHistory:
        final auction = settings.arguments as Auction;
        return MaterialPageRoute(builder: (_) => BidHistoryPage(auction: auction));
      case profile:
        return MaterialPageRoute(builder: (_) => const ProfilePage());
      case editProfile:
        return MaterialPageRoute(builder: (_) => const EditProfilePage());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('No route defined for ${settings.name}')),
          ),
        );
    }
  }
}

