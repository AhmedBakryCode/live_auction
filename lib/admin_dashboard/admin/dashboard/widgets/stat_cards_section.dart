import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../providers/dashboard_provider.dart';

class StatCardsSection extends StatelessWidget {
  const StatCardsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final stats = context.watch<DashboardProvider>().stats;
    
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 0.95,
      children: [
        _buildMobileStatCard(
          title: 'إجمالي المزادات',
          value: stats.totalAuctions.toString(),
          icon: Icons.gavel_rounded,
          color: AppColors.primary,
        ),
        _buildMobileStatCard(
          title: 'المزادات النشطة',
          value: stats.activeAuctions.toString(),
          icon: Icons.bolt_rounded,
          color: AppColors.warm,
        ),
        _buildMobileStatCard(
          title: 'المزادات المغلقة',
          value: stats.closedAuctions.toString(),
          icon: Icons.lock_clock_rounded,
          color: AppColors.error,
        ),
        _buildMobileStatCard(
          title: 'إيرادات الاسترداد',
          value: '${stats.refundRevenue} ر.س',
          icon: Icons.account_balance_wallet_rounded,
          color: AppColors.success,
        ),
        _buildMobileStatCard(
          title: 'إجمالي المزايدات',
          value: stats.totalBids.toString(),
          icon: Icons.local_offer_rounded,
          color: AppColors.secondary,
        ),
        _buildMobileStatCard(
          title: 'المستخدمين',
          value: stats.totalUsers.toString(),
          icon: Icons.people_alt_rounded,
          color: AppColors.primary,
        ),
      ],
    );
  }

  Widget _buildMobileStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const Spacer(),
          Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
              fontFamily: 'Cairo',
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
              fontFamily: 'Cairo',
            ),
          ),
        ],
      ),
    );
  }
}
