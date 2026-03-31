import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class UsersStatisticsSection extends StatelessWidget {
  const UsersStatisticsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                '3,240',
                'إجمالي الأعضاء',
                Icons.people_alt_rounded,
                AppColors.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                '2,850',
                'أعضاء نشطين',
                Icons.check_circle_rounded,
                Colors.greenAccent,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                '140',
                'أعضاء جدد',
                Icons.person_add_alt_1_rounded,
                Colors.blueAccent,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                '45',
                'أعضاء محظورين',
                Icons.block_flipped,
                AppColors.error,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(String value, String label, IconData icon, Color accentColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: accentColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: accentColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: AppTextStyles.h2.copyWith(fontSize: 18, color: AppColors.textPrimary),
                ),
                Text(
                  label,
                  style: AppTextStyles.caption.copyWith(fontSize: 10, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
