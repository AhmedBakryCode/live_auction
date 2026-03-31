import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import 'stat_card.dart';
import '../../../core/utils/mock_data.dart';

class StatCardsSection extends StatelessWidget {
  const StatCardsSection({super.key});

  @override
  Widget build(BuildContext context) {
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
          value: MockData.stats['totalAuctions'].toString(),
          icon: Icons.gavel_rounded,
          color: AppColors.primary,
        ),
        StatCard(
          title: 'إجمالي المزايدات',
          value: MockData.stats['totalBids'].toString(),
          icon: Icons.local_offer_rounded,
          color: AppColors.secondary,
        ),
        StatCard(
          title: 'المزادات النشطة',
          value: MockData.stats['activeAuctions'].toString(),
          icon: Icons.bolt_rounded,
          color: AppColors.warm,
        ),
        StatCard(
          title: 'الإيرادات',
          value: MockData.stats['revenue'].toString(),
          icon: Icons.account_balance_wallet_rounded,
          color: AppColors.success,
        ),
      ],
    );
  }
}
