import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/section_header.dart';
import '../widgets/statistics_section.dart';
import '../widgets/filters_section.dart';
import '../widgets/auctions_list_section.dart';
import '../widgets/finished_auctions_section.dart';
import '../../dashboard/widgets/dashboard_header.dart';
import '../../dashboard/widgets/sidebar_widget.dart';

class AuctionsAdminScreen extends StatelessWidget {
  const AuctionsAdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: const Drawer(
        width: 300,
        child: SidebarWidget(),
      ),
      appBar: const DashboardHeader(), // Reusing the clean header from dashboard
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            // Future API refresh logic
          },
          color: AppColors.primary,
          child: CustomScrollView(
            slivers: [
              const SliverPadding(
                padding: EdgeInsets.fromLTRB(20, 24, 20, 0),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('إدارة المزادات', style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                        fontFamily: 'Cairo',
                      )),
                      SizedBox(height: 4),
                      Text('تحكم في كافة المزادات النشطة والمنتهية', style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                        fontFamily: 'Cairo',
                      )),
                    ],
                  ),
                ),
              ),
              
              // Statistics Section
              const SliverPadding(
                padding: EdgeInsets.symmetric(vertical: 24),
                sliver: SliverToBoxAdapter(
                  child: StatisticsSection(),
                ),
              ),

              // Filters Section
              const SliverToBoxAdapter(
                child: FiltersSection(),
              ),

              // Recent Finished Auctions (Horizontal)
              const SliverPadding(
                padding: EdgeInsets.symmetric(vertical: 24),
                sliver: SliverToBoxAdapter(
                  child: FinishedAuctionsSection(),
                ),
              ),

              // All Auctions List
              const SliverPadding(
                padding: EdgeInsets.fromLTRB(20, 0, 20, 20),
                sliver: SliverToBoxAdapter(
                  child: SectionHeader(
                    title: 'قائمة المزادات',
                    actionText: 'إضافة مزاد',
                  ),
                ),
              ),
              
              const AuctionsListSection(),
              const SliverToBoxAdapter(
                child: SizedBox(height: 40),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
