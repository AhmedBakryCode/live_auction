import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class StatisticsSection extends StatelessWidget {
  const StatisticsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> stats = [
      {'label': 'إجمالي المزادات', 'value': '1,250', 'icon': Icons.gavel_rounded, 'color': AppColors.primary},
      {'label': 'مزادات نشطة', 'value': '430', 'icon': Icons.bolt_rounded, 'color': Colors.greenAccent},
      {'label': 'إجمالي المزايدات', 'value': '8,900', 'icon': Icons.trending_up_rounded, 'color': Colors.blueAccent},
      {'label': 'قيمة المبيعات', 'value': '\$45K', 'icon': Icons.account_balance_wallet_outlined, 'color': AppColors.secondary},
    ];

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
                    Icon(stat['icon'], color: stat['color'], size: 20),
                    const Icon(Icons.north_east_rounded, color: Colors.greenAccent, size: 14),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(stat['value'], style: AppTextStyles.h2),
                    Text(stat['label'], style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
