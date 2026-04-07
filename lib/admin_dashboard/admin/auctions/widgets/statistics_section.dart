import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auctions_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class StatisticsSection extends StatelessWidget {
  const StatisticsSection({super.key});

  /// Formats a double price value to a short readable string (e.g. 45000 → $45K)
  String _formatPrice(double value) {
    if (value >= 1000000) {
      return '\$${(value / 1000000).toStringAsFixed(1)}M';
    } else if (value >= 1000) {
      return '\$${(value / 1000).toStringAsFixed(1)}K';
    }
    return '\$${value.toStringAsFixed(0)}';
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuctionsProvider>(
      builder: (context, provider, _) {
        final auctions = provider.auctions;

        final int total = auctions.length;
        final int active =
            auctions.where((a) => a.status == 'active').length;
        final int closed = auctions
            .where((a) => a.status == 'closed' || a.status == 'paid')
            .length;
        final double salesValue = auctions
            .where((a) => a.status == 'closed' || a.status == 'paid')
            .fold(0.0, (sum, a) => sum + (a.currentPrice ?? a.startPrice));

        final List<Map<String, dynamic>> stats = [
          {
            'label': 'إجمالي المزادات',
            'value': total.toString(),
            'icon': Icons.gavel_rounded,
            'color': AppColors.primary,
          },
          {
            'label': 'مزادات نشطة',
            'value': active.toString(),
            'icon': Icons.bolt_rounded,
            'color': Colors.greenAccent,
          },
          {
            'label': 'مزادات منتهية',
            'value': closed.toString(),
            'icon': Icons.check_circle_outline_rounded,
            'color': Colors.blueAccent,
          },
          {
            'label': 'قيمة المبيعات',
            'value': salesValue > 0 ? _formatPrice(salesValue) : '\$0',
            'icon': Icons.account_balance_wallet_outlined,
            'color': AppColors.secondary,
          },
        ];

        // Show skeleton cards while loading with no data yet
        if (provider.isLoading && auctions.isEmpty) {
          return _buildSkeletonCards();
        }

        return SizedBox(
          height: 110,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            scrollDirection: Axis.horizontal,
            itemCount: stats.length,
            separatorBuilder: (context, index) => const SizedBox(width: 16),
            itemBuilder: (context, index) {
              final stat = stats[index];
              return Container(
                width: 160,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Icon(stat['icon'],
                            color: stat['color'] as Color, size: 20),
                        Icon(
                          Icons.north_east_rounded,
                          color: Colors.greenAccent,
                          size: 14,
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(stat['value'] as String,
                            style: AppTextStyles.h2),
                        Text(
                          stat['label'] as String,
                          style: AppTextStyles.caption
                              .copyWith(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildSkeletonCards() {
    return SizedBox(
      height: 110,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        scrollDirection: Axis.horizontal,
        itemCount: 4,
        separatorBuilder: (_, _) => const SizedBox(width: 16),
        itemBuilder: (_, _) => Container(
          width: 160,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                  width: 20, height: 20, color: AppColors.border),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                      width: 60, height: 16, color: AppColors.border),
                  const SizedBox(height: 4),
                  Container(
                      width: 100, height: 12, color: AppColors.border),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
