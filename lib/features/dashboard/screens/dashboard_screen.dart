import 'package:flutter/material.dart';
import '../widgets/sidebar_widget.dart';
import '../widgets/dashboard_header.dart';
import '../widgets/stat_cards_section.dart';
import '../widgets/charts_section.dart';
import '../widgets/latest_bids_table.dart';
import '../widgets/wallet_overview_section.dart';
import '../widgets/notifications_section.dart';
import '../widgets/leaderboard_section.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: const Drawer(
        width: 300,
        child: SidebarWidget(),
      ),
      appBar: const DashboardHeader(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('لوحة التحكم', style: AppTextStyles.h1),
                    const SizedBox(height: 4),
                    Text('أهلاً بك، إليك ملخص النشاط اليوم', style: AppTextStyles.body2),
                  ],
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: const Icon(Icons.filter_list_rounded, color: AppColors.textSecondary, size: 20),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const StatCardsSection(),
            const SizedBox(height: 24),
            const ChartsSection(),
            const SizedBox(height: 24),
            const WalletOverviewSection(),
            const SizedBox(height: 24),
            const LatestBidsTable(),
            const SizedBox(height: 24),
            const LeaderboardSection(),
            const SizedBox(height: 24),
            const NotificationsSection(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
