import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../auctions/presentation/pages/auctions_home_page.dart';
import '../../../watchlist/presentation/pages/watchlist_page.dart';
import '../../../wallet/presentation/pages/wallet_page.dart';
import '../../../notifications/presentation/pages/notifications_page.dart';
import '../../../notifications/presentation/bloc/notifications_bloc.dart';
import '../../../notifications/data/models/notification_model.dart';
import '../../../user_stats/presentation/pages/user_stats_page.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/services/socket_service.dart';

class CustomerDashboardPage extends StatefulWidget {
  const CustomerDashboardPage({super.key});

  @override
  State<CustomerDashboardPage> createState() => _CustomerDashboardPageState();
}

class _CustomerDashboardPageState extends State<CustomerDashboardPage> {
  int _currentIndex = 0;
  late SocketService _socketService;

  final List<Widget> _pages = [
    const AuctionsHomePage(),
    const WatchlistPage(),
    const WalletPage(),
    const NotificationsPage(),
    const UserStatsPage(),
  ];

  @override
  void initState() {
    super.initState();
    _socketService = context.read<SocketService>();
    _socketService.init();
    _socketService.connect();
    _setupSocketListeners();
  }

  @override
  void dispose() {
    _socketService.disconnect();
    super.dispose();
  }

  void _setupSocketListeners() {
    // Listen for general notifications
    _socketService.onNotification((data) {
      _handleRealTimeNotification(data);
    });

    // Listen for auction won
    _socketService.onAuctionWon((data) {
      _handleRealTimeNotification({
        'type': 'App\\Notifications\\AuctionWon',
        'data': {'message': 'Congratulations! You won an auction!'},
        ...data,
      });
    });

    // Listen for outbid
    _socketService.onOutbid((data) {
      _handleRealTimeNotification({
        'type': 'App\\Notifications\\Outbid',
        'data': {'message': 'You have been outbid on an auction!'},
        ...data,
      });
    });

    // Listen for auction ending soon
    _socketService.onAuctionEndingSoon((data) {
      _handleRealTimeNotification({
        'type': 'App\\Notifications\\AuctionEndingSoon',
        'data': {'message': 'An auction you are watching is ending soon!'},
        ...data,
      });
    });
  }

  void _handleRealTimeNotification(dynamic data) {
    if (!mounted) return;

    final notification = NotificationModel.fromJson({
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'type': data['type'] ?? 'App\\Notifications\\General',
      'notifiable_type': data['notifiable_type'] ?? 'App\\Models\\User',
      'notifiable_id': data['notifiable_id'] ?? 0,
      'data': data['data'] ?? {'message': 'New notification'},
      'read_at': null,
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    });

    context.read<NotificationsBloc>().add(
      ReceiveRealTimeNotification(notification),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          type: BottomNavigationBarType.fixed,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.textSecondary,
          showUnselectedLabels: true,
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
          unselectedLabelStyle: const TextStyle(fontSize: 12),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'الرئيسية',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.favorite_border),
              activeIcon: Icon(Icons.favorite),
              label: 'المتابعة',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.account_balance_wallet_outlined),
              activeIcon: Icon(Icons.account_balance_wallet),
              label: 'المحفظة',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.notifications_outlined),
              activeIcon: Icon(Icons.notifications),
              label: 'التنبيهات',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart_outlined),
              activeIcon: Icon(Icons.bar_chart),
              label: 'إحصائياتي',
            ),
          ],
        ),
      ),
    );
  }
}
