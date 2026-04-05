import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import 'stat_card.dart';
import '../providers/dashboard_provider.dart';

class StatCardsSection extends StatelessWidget {
  const StatCardsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final stats = context.watch<DashboardProvider>().stats;
    
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.0,
      children: [
        StatCard(
          title: 'إجمالي المزادات',
          value: stats.totalAuctions.toString(),
          icon: Icons.gavel_rounded,
          color: AppColors.primary,
        ),
        StatCard(
          title: 'المزادات النشطة',
          value: stats.activeAuctions.toString(),
          icon: Icons.bolt_rounded,
          color: AppColors.warm,
        ),
        StatCard(
          title: 'المزادات المغلقة',
          value: stats.closedAuctions.toString(),
          icon: Icons.lock_clock_rounded,
          color: AppColors.error,
        ),
        StatCard(
          title: 'المزادات المعاد نشرها',
          value: stats.repostedAuctions.toString(),
          icon: Icons.replay_rounded,
          color: AppColors.secondary,
        ),
        StatCard(
          title: 'إجمالي المستخدمين',
          value: stats.totalUsers.toString(),
          icon: Icons.people_alt_rounded,
          color: AppColors.primary,
        ),
        StatCard(
          title: 'إجمالي المشاركين',
          value: stats.totalParticipants.toString(),
          icon: Icons.person_search_rounded,
          color: AppColors.warm,
        ),
        StatCard(
          title: 'إجمالي المزايدات',
          value: stats.totalBids.toString(),
          icon: Icons.local_offer_rounded,
          color: AppColors.secondary,
        ),
        StatCard(
          title: 'إيرادات الاسترداد',
          value: stats.refundRevenue.toString(),
          icon: Icons.account_balance_wallet_rounded,
          color: AppColors.success,
        ),
      ],
    );
  }
}
