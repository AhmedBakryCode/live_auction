import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class BidsStatsGrid extends StatelessWidget {
  const BidsStatsGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.4,
      children: [
        _buildStatCard(
          '٢,٤٥٦',
          'إجمالي المزايدات',
          Icons.gavel_rounded,
          AppColors.primary,
          '+15%',
          true,
        ),
        _buildStatCard(
          '١,٨٩٢',
          'مزايدات نشطة',
          Icons.trending_up_rounded,
          Colors.greenAccent,
          '+8%',
          true,
        ),
        _buildStatCard(
          '٤٥٦',
          'مزايدات اليوم',
          Icons.local_fire_department_rounded,
          Colors.orangeAccent,
          '١٢',
          false,
        ),
        _buildStatCard(
          '\$٣٢٤.٥ك',
          'قيمة المزايدات',
          Icons.monetization_on_rounded,
          Colors.purpleAccent,
          '+12%',
          true,
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String value,
    String label,
    IconData icon,
    Color color,
    String trend,
    bool isPercentage,
  ) {
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
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isPercentage ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  trend,
                  style: TextStyle(
                    color: isPercentage ? Colors.greenAccent : Colors.orangeAccent,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
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
