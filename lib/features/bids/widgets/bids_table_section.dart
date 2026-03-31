import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_table.dart';
import '../../../core/widgets/app_badge.dart';
import '../../../core/utils/mock_data.dart';

class BidsTableSection extends StatelessWidget {
  const BidsTableSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Table Header/Title
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('قائمة المزايدات', style: AppTextStyles.h2),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      Text('عرض ١-٥ من ١٢٤', style: AppTextStyles.caption),
                      const SizedBox(width: 8),
                      const Icon(Icons.keyboard_arrow_down_rounded, size: 16, color: AppColors.textSecondary),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // The Table
          AppTable(
            headers: const ['المزاد', 'المستخدم', 'المبلغ', 'الوقت', 'الترتيب', 'حالة المزاد', 'الإجراءات'],
            rows: MockData.bidsHistory.map((bid) => [
              // Auction Column
              Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(bid['image'] as String, width: 40, height: 40, fit: BoxFit.cover),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(bid['auction'] as String, style: AppTextStyles.body1Bold.copyWith(fontSize: 13)),
                      Text(bid['id'] as String, style: AppTextStyles.caption.copyWith(fontSize: 11)),
                    ],
                  ),
                ],
              ),
              // User Column
              Row(
                children: [
                  CircleAvatar(
                    radius: 12,
                    backgroundImage: NetworkImage(bid['userAvatar'] as String),
                  ),
                  const SizedBox(width: 8),
                  Text(bid['user'] as String, style: AppTextStyles.body2),
                ],
              ),
              // Amount Column
              Text(bid['amount'] as String, style: AppTextStyles.body1Bold.copyWith(color: AppColors.primary)),
              // Time Column
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(bid['time'] as String, style: AppTextStyles.body2),
                  Text(bid['date'] as String, style: AppTextStyles.caption.copyWith(fontSize: 10)),
                ],
              ),
              // Rank Column
              _buildRankBadge(bid['rank'] as String, bid['rankIcon'] as String),
              // Status Column
              _buildStatusBadge(bid['status'] as String, bid['statusIcon'] as String, bid['statusColor'] as String),
              // Actions Column
              Row(
                children: [
                  _buildTableAction(Icons.visibility_outlined, Colors.blue),
                  _buildTableAction(Icons.trending_up_rounded, Colors.green),
                  _buildTableAction(Icons.flag_outlined, Colors.red),
                ],
              ),
            ]).toList(),
          ),

          // Pagination Footer
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _buildPageBtn(Icons.chevron_right_rounded, false),
                const SizedBox(width: 8),
                _buildPageBtnText('١', true),
                const SizedBox(width: 8),
                _buildPageBtnText('٢', false),
                const SizedBox(width: 8),
                _buildPageBtnText('٣', false),
                const SizedBox(width: 8),
                _buildPageBtn(Icons.chevron_left_rounded, false),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRankBadge(String label, String iconName) {
    IconData icon;
    Color color;
    switch (iconName) {
      case 'crown': icon = Icons.workspace_premium_rounded; color = AppColors.primary; break;
      case 'medal': icon = Icons.emoji_events_rounded; color = Colors.blueAccent; break;
      case 'award': icon = Icons.military_tech_rounded; color = Colors.greenAccent; break;
      default: icon = Icons.star_rounded; color = Colors.grey;
    }

    return AppBadge(
      text: label,
      color: color,
    );
  }

  Widget _buildStatusBadge(String label, String iconName, String colorName) {
    Color color = AppColors.primary;
    if (colorName == 'green') color = Colors.greenAccent;
    if (colorName == 'orange') color = Colors.orangeAccent;
    if (colorName == 'red') color = AppColors.error;

    return AppBadge(
      text: label,
      color: color,
    );
  }

  Widget _buildTableAction(IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(left: 4),
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, color: color, size: 16),
    );
  }

  Widget _buildPageBtn(IconData icon, bool active) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: active ? AppColors.primary : AppColors.background,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: active ? AppColors.primary : AppColors.border),
      ),
      child: Icon(icon, color: active ? Colors.black : AppColors.textSecondary, size: 18),
    );
  }

  Widget _buildPageBtnText(String text, bool active) {
    return Container(
      width: 32,
      height: 32,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: active ? AppColors.primary : AppColors.background,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: active ? AppColors.primary : AppColors.border),
      ),
      child: Text(text, style: TextStyle(
        color: active ? Colors.black : AppColors.textSecondary,
        fontWeight: FontWeight.bold,
        fontSize: 12,
        fontFamily: 'Cairo',
      )),
    );
  }
}
