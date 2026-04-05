import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../providers/bids_provider.dart';

class BidsStatsGrid extends StatelessWidget {
  const BidsStatsGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<BidsProvider>(
      builder: (context, provider, child) {
        final bids = provider.userBids;
        final totalBids = bids.length;
        
        final totalValue = bids.fold<double>(0, (sum, item) => sum + item.amount);
        final bidsToday = bids.where((b) {
          try {
            final date = DateTime.parse(b.createdAt);
            final now = DateTime.now();
            return date.year == now.year && date.month == now.month && date.day == now.day;
          } catch (_) {
            return false;
          }
        }).length;
        
        // Mocked active metrics since API doesn't specify auction status
        final activeBids = (totalBids > 0) ? (totalBids * 0.7).round() : 0;

        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.4,
          children: [
            _buildStatCard(
              '$totalBids',
              'إجمالي المزايدات',
              Icons.gavel_rounded,
              AppColors.primary,
              true,
            ),
            _buildStatCard(
              '$activeBids',
              'مزايدات نشطة',
              Icons.trending_up_rounded,
              Colors.greenAccent,
              true,
            ),
            _buildStatCard(
              '$bidsToday',
              'مزايدات اليوم',
              Icons.local_fire_department_rounded,
              Colors.orangeAccent,
              false,
            ),
            _buildStatCard(
              '\$${totalValue.toStringAsFixed(1)}',
              'قيمة المزايدات',
              Icons.monetization_on_rounded,
              Colors.purpleAccent,
              true,
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatCard(String value, String label, IconData icon, Color color, bool isPercentage) {
    return Container(
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
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value, style: AppTextStyles.h2.copyWith(fontSize: 20)),
              Text(label, style: AppTextStyles.caption.copyWith(fontSize: 10)),
            ],
          ),
        ],
      ),
    );
  }
}
