import 'package:flutter/material.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/section_header.dart';
import '../../../core/widgets/app_table.dart';
import '../../../core/widgets/app_badge.dart';
import '../../../core/utils/mock_data.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class AuctionsManagementTable extends StatelessWidget {
  const AuctionsManagementTable({super.key});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(title: 'إدارة المزادات', onActionPressed: () {}, actionText: 'عرض الكل'),
          AppTable(
            headers: const ['المنتج', 'السعر المبدئي', 'أعلى مزايد', 'الحالة', 'الوقت المتبقي', 'المزايدات'],
            rows: MockData.auctions.map((a) => [
              Text(a['product']!.toString(), style: AppTextStyles.body1Bold),
              Text(a['startPrice']!.toString(), style: AppTextStyles.body1),
              Text(a['topBidder']!.toString(), style: AppTextStyles.body1),
              AppBadge(
                text: a['status']!.toString(),
                color: a['status'] == 'نشط' ? AppColors.success : AppColors.textSecondary,
              ),
              Text(a['timeRemaining']!.toString(), style: AppTextStyles.body2),
              Text(a['bids']!.toString(), style: AppTextStyles.body1Bold),
            ]).toList(),
          ),
        ],
      ),
    );
  }
}
