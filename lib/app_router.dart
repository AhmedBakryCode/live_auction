import 'package:flutter/material.dart';
import 'customer_dashboard/features/customer_dashboard/presentation/pages/customer_dashboard_page.dart';
import 'customer_dashboard/features/auctions/presentation/pages/all_auctions_page.dart';
import 'customer_dashboard/features/auctions/presentation/pages/auction_details_page.dart';
import 'customer_dashboard/features/auctions/presentation/pages/live_bidding_page.dart';
import 'customer_dashboard/features/auctions/presentation/pages/bid_history_page.dart';
import 'customer_dashboard/features/profile/presentation/pages/profile_page.dart';
import 'customer_dashboard/features/profile/presentation/pages/edit_profile_page.dart';
import 'customer_dashboard/features/auth/presentation/pages/login_page.dart';
import 'customer_dashboard/features/auth/presentation/pages/auth_wrapper.dart';
import 'customer_dashboard/features/auctions/domain/entities/auction.dart';
import 'customer_dashboard/features/wallet/presentation/pages/paymob_iframe_screen.dart';
import 'customer_dashboard/features/wallet/presentation/pages/wallet_page.dart';

class AppRouter {
  static const String authWrapper = '/auth-wrapper';
  static const String dashboard = '/';
  static const String login = '/login';
  static const String allAuctions = '/all-auctions';
  static const String auctionDetails = '/auction-details';
  static const String liveBidding = '/live-bidding';
  static const String bidHistory = '/bid-history';
  static const String profile = '/profile';
  static const String wallet = '/wallet';
  static const String editProfile = '/edit-profile';
  static const String paymentWebView = '/payment-webview';
  static const String paymentWebViewInApp = '/payment-webview-inapp';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case authWrapper:
        return MaterialPageRoute(builder: (_) => const AuthWrapper());
      case dashboard:
        return MaterialPageRoute(builder: (_) => const CustomerDashboardPage());
      case login:
        return MaterialPageRoute(builder: (_) => const LoginPage());
      case allAuctions:
        return MaterialPageRoute(builder: (_) => const AllAuctionsPage());
      case auctionDetails:
        final args = settings.arguments;
        late final Auction auction;
        late final bool isAlreadyJoined;

        if (args is Map) {
          auction = args['auction'] as Auction;
          isAlreadyJoined = args['isAlreadyJoined'] as bool? ?? false;
        } else {
          auction = args as Auction;
          isAlreadyJoined = false;
        }

        return MaterialPageRoute(
          builder: (_) => AuctionDetailsPage(
            auction: auction,
            isAlreadyJoined: isAlreadyJoined,
          ),
        );
      case liveBidding:
        final auction = settings.arguments as Auction;
        return MaterialPageRoute(
          builder: (_) => LiveBiddingPage(auction: auction),
        );
      case bidHistory:
        final auction = settings.arguments as Auction;
        return MaterialPageRoute(
          builder: (_) => BidHistoryPage(auction: auction),
        );
      case profile:
        return MaterialPageRoute(builder: (_) => const ProfilePage());
      case wallet:
        return MaterialPageRoute(builder: (_) => const WalletPage());
      case editProfile:
        return MaterialPageRoute(builder: (_) => const EditProfilePage());
      case paymentWebView:
        final url = settings.arguments as String?;
        if (url == null || url.isEmpty) {
          return MaterialPageRoute(
            builder: (_) => Scaffold(
              appBar: AppBar(title: const Text('Error')),
              body: const Center(child: Text('Invalid payment URL')),
            ),
          );
        }
        return MaterialPageRoute(
          builder: (_) => PaymobIframeScreen(paymentUrl: url),
        );
      case paymentWebViewInApp:
        final url = settings.arguments as String?;
        if (url == null || url.isEmpty) {
          return MaterialPageRoute(
            builder: (_) => Scaffold(
              appBar: AppBar(title: const Text('Error')),
              body: const Center(child: Text('Invalid payment URL')),
            ),
          );
        }
        return MaterialPageRoute(
          builder: (_) => PaymobIframeScreen(paymentUrl: url),
        );
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('No route defined for ${settings.name}')),
          ),
        );
    }
  }
}
