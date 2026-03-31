import 'package:flutter/material.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/section_header.dart';
import '../../../core/widgets/app_table.dart';
import '../../../core/widgets/app_badge.dart';
import '../../../core/utils/mock_data.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class LatestBidsTable extends StatelessWidget {
  const LatestBidsTable({super.key});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(24.0),
            child: SectionHeader(
              title: 'أحدث المزايدات',
              actionText: 'عرض الكل',
            ),
          ),
          AppTable(
            headers: const ['المزاد', 'المستخدم', 'المبلغ', 'الوقت', 'الحالة'],
            rows: MockData.latestBids.map((b) => [
              Text(b['auction']!.toString(), style: AppTextStyles.body1Bold),
              Text(b['user']!.toString(), style: AppTextStyles.body2),
              Text(b['amount']!.toString(), style: AppTextStyles.body1Bold.copyWith(color: AppColors.primary)),
              Text(b['time']!.toString(), style: AppTextStyles.caption),
              AppBadge(
                text: b['status']!.toString(),
                color: b['status'] == 'فائز' ? AppColors.success : AppColors.error,
              ),
            ]).toList(),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
