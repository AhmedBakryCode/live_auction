import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../dashboard/widgets/dashboard_header.dart';
import '../widgets/bids_stats_grid.dart';
import '../widgets/bids_filters_section.dart';
import '../widgets/bids_table_section.dart';
import '../widgets/bids_analytics_grid.dart';
import '../../dashboard/widgets/sidebar_widget.dart';

class BidsHistoryScreen extends StatelessWidget {
  const BidsHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: const Drawer(
        width: 300,
        child: SidebarWidget(),
      ),
      appBar: const DashboardHeader(),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Page Header with Breadcrumbs/Title
              _buildPageHeader(),
              
              const SizedBox(height: 24),

              // 2. Statistics Grid
              const BidsStatsGrid(),

              const SizedBox(height: 24),

              // 3. Advanced Filters
              const BidsFiltersSection(),

              const SizedBox(height: 24),

              // 4. Bids History Table
              const BidsTableSection(),

              const SizedBox(height: 24),

              // 5. Analytical Summary Grid (Bottom)
              const BidsAnalyticsGrid(),
              
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPageHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(Icons.history_rounded, color: AppColors.primary, size: 28),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('سجل المزايدات', style: AppTextStyles.h1.copyWith(fontSize: 22)),
              Text(
                'تتبع جميع عمليات المزايدة والنشاط على المنصة',
                style: AppTextStyles.body2.copyWith(color: AppColors.textSecondary, fontSize: 11),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        _buildHeaderActions(),
      ],
    );
  }

  Widget _buildHeaderActions() {
    return Row(
      children: [
        _buildIconBtn(Icons.download_rounded),
        const SizedBox(width: 8),
        _buildIconBtn(Icons.print_rounded),
      ],
    );
  }

  Widget _buildIconBtn(IconData icon) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: IconButton(
        onPressed: () {},
        icon: Icon(icon, color: AppColors.textSecondary, size: 20),
      ),
    );
  }
}
