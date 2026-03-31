import 'package:flutter/material.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/section_header.dart';
import '../../../core/utils/mock_data.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class NotificationsSection extends StatelessWidget {
  const NotificationsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(title: 'الإشعارات الحديثة', actionText: 'عرض الكل'),
          ...MockData.notifications.map((n) => Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.background.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                  child: Icon(
                    n['type'] == 'bid' ? Icons.gavel_rounded : n['type'] == 'user' ? Icons.person_add_rounded : Icons.info_outline_rounded,
                    color: AppColors.primary,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(n['title']!, style: AppTextStyles.body1Bold.copyWith(fontSize: 13)),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          const Icon(Icons.access_time_rounded, size: 12, color: AppColors.textSecondary),
                          const SizedBox(width: 4),
                          Text(n['time']!, style: AppTextStyles.caption),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }
}
