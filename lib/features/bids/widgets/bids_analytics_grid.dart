import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../providers/bids_provider.dart';
import '../models/user_bid_model.dart';

class BidsAnalyticsGrid extends StatelessWidget {
  const BidsAnalyticsGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<BidsProvider>(
      builder: (context, provider, child) {
        final bids = List<UserBidModel>.from(provider.userBids);

        // 1. Top 3 Bids
        bids.sort((a, b) => b.amount.compareTo(a.amount));
        final topBids = bids.take(3).map((b) => {
          'label': 'مزاد #${b.auctionId}',
          'value': '\$${b.amount.toStringAsFixed(1)}'
        }).toList();

        // 2. Recent Bids
        List<UserBidModel> recentBidsSource = List.from(bids);
        recentBidsSource.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        final recentBids = recentBidsSource.take(3).map((b) {
          final dateParts = b.createdAt.split(' ');
          final timeStr = dateParts.length > 1 ? dateParts.last : b.createdAt;
          return {
            'label': timeStr,
            'value': '\$${b.amount.toStringAsFixed(1)}'
          };
        }).toList();

        // 3. Most Active Users
        final userCounts = <int, int>{};
        for (var b in bids) {
          userCounts[b.userId] = (userCounts[b.userId] ?? 0) + 1;
        }
        var sortedUsers = userCounts.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));
        final activeUsers = sortedUsers.take(3).map((e) => {
          'label': 'مستخدم #${e.key}',
          'value': '${e.value} مزايدة'
        }).toList();

        // 4. Hot Auctions
        final auctionCounts = <int, int>{};
        for (var b in bids) {
          auctionCounts[b.auctionId] = (auctionCounts[b.auctionId] ?? 0) + 1;
        }
        var sortedAuctions = auctionCounts.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));
        final hotAuctions = sortedAuctions.take(3).map((e) => {
          'label': 'مزاد #${e.key}',
          'value': '${e.value} مزايدة'
        }).toList();

        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 1,
          mainAxisSpacing: 16,
          children: [
            _buildAnalyticsCard(
              'أعلى المزادات',
              Icons.trending_up_rounded,
              AppColors.primary,
              topBids.isEmpty ? [{'label': 'لا توجد بيانات', 'value': '-'}] : topBids,
            ),
            _buildAnalyticsCard(
              'أحدث المزايدات',
              Icons.access_time_rounded,
              Colors.greenAccent,
              recentBids.isEmpty ? [{'label': 'لا توجد بيانات', 'value': '-'}] : recentBids,
            ),
            _buildAnalyticsCard(
              'الأكثر نشاطا',
              Icons.emoji_events_rounded,
              Colors.purpleAccent,
              activeUsers.isEmpty ? [{'label': 'لا توجد بيانات', 'value': '-'}] : activeUsers,
            ),
            _buildAnalyticsCard(
              'المزادات الساخنة',
              Icons.local_fire_department_rounded,
              Colors.orangeAccent,
              hotAuctions.isEmpty ? [{'label': 'لا توجد بيانات', 'value': '-'}] : hotAuctions,
            ),
          ],
        );
      },
    );
  }

  Widget _buildAnalyticsCard(String title, IconData icon, Color color, List<Map<String, String>> items) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Text(title, style: AppTextStyles.body1Bold),
            ],
          ),
          const SizedBox(height: 20),
          ...items.map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(item['label']!, style: AppTextStyles.body2),
                Text(item['value']!, style: AppTextStyles.body1Bold.copyWith(color: color, fontSize: 13)),
              ],
            ),
          )),
        ],
      ),
    );
  }
}
