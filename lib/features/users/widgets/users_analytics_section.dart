import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class UsersAnalyticsSection extends StatelessWidget {
  const UsersAnalyticsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('إحصائيات الأدوار', style: AppTextStyles.h3),
                    Text('توزيع المستخدمين حسب الصلاحية', style: AppTextStyles.caption.copyWith(fontSize: 10)),
                  ],
                ),
                const Icon(Icons.pie_chart_outline_rounded, color: AppColors.primary, size: 28),
              ],
            ),
            const SizedBox(height: 24),
            _buildRoleRow('بائع (Sellers)', 0.65, Colors.blueAccent),
            const SizedBox(height: 18),
            _buildRoleRow('مشرف (Moderators)', 0.15, AppColors.primary),
            const SizedBox(height: 18),
            _buildRoleRow('مستخدم (Buyers)', 0.85, Colors.greenAccent),
          ],
        ),
    );
    }

  Widget _buildRoleRow(String label, double progress, Color color) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: AppTextStyles.body2.copyWith(color: AppColors.textPrimary, fontSize: 13)),
            Text('${(progress * 100).toInt()}%', style: AppTextStyles.body1Bold.copyWith(color: color, fontSize: 13)),
          ],
        ),
        const SizedBox(height: 8),
        Stack(
          children: [
            Container(
              height: 8,
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            FractionallySizedBox(
              widthFactor: progress,
              child: Container(
                height: 8,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [color.withOpacity(0.5), color],
                  ),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(color: color.withOpacity(0.3), blurRadius: 4, offset: const Offset(0, 2)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
