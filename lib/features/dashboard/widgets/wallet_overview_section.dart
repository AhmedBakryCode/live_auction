import 'package:flutter/material.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/section_header.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_colors.dart';

class WalletOverviewSection extends StatelessWidget {
  const WalletOverviewSection({super.key});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(title: 'المحفظة الرقمية'),
          Container(
            padding: const EdgeInsets.all(28),
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary,
                  AppColors.primary.withValues(alpha: 0.8),
                  AppColors.secondary,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('الرصيد الكلي', style: AppTextStyles.body1.copyWith(color: Colors.black87, fontWeight: FontWeight.w600)),
                    const Icon(Icons.wallet_rounded, color: Colors.black54, size: 24),
                  ],
                ),
                const SizedBox(height: 12),
                Text('\$84,250.00', style: AppTextStyles.h1.copyWith(color: Colors.black, fontSize: 36, letterSpacing: 1)),
                const SizedBox(height: 12),
                Text('**** **** **** 4250', style: AppTextStyles.body2.copyWith(color: Colors.black45, letterSpacing: 2)),
              ],
            ),
          ),
          const SizedBox(height: 28),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildFlow('إيداعات', '\$12,400', Icons.south_west_rounded, AppColors.success),
              _buildFlow('سحوبات', '\$3,120', Icons.north_east_rounded, AppColors.error),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFlow(String label, String amount, IconData icon, Color color) {
    return Expanded(
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
              border: Border.all(color: color.withValues(alpha: 0.2)),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: AppTextStyles.body2),
              Text(amount, style: AppTextStyles.body1Bold),
            ],
          ),
        ],
      ),
    );
  }
}
