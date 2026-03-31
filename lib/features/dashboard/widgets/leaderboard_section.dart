import 'package:flutter/material.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/section_header.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class LeaderboardSection extends StatelessWidget {
  const LeaderboardSection({super.key});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(title: 'المتصدرون'),
          _buildItem('1', 'أحمد محمد', 'الأكثر فوزاً', Icons.emoji_events_rounded, AppColors.primary),
          _buildItem('2', 'سارة علي', 'أعلى المزايدات', Icons.star_rounded, AppColors.secondary),
          _buildItem('3', 'خالد عبدالله', 'الأكثر نشاطاً', Icons.local_fire_department_rounded, AppColors.error),
        ],
      ),
    );
  }

  Widget _buildItem(String rank, String name, String subtitle, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.background.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Text(rank, style: AppTextStyles.body1Bold.copyWith(color: color)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: AppTextStyles.body1Bold),
                Text(subtitle, style: AppTextStyles.caption.copyWith(fontSize: 12)),
              ],
            ),
          ),
          Icon(icon, color: color, size: 24),
        ],
      ),
    );
  }
}
