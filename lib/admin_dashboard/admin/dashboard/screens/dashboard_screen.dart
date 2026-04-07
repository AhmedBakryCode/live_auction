import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/dashboard_provider.dart';
import '../widgets/sidebar_widget.dart';
import '../widgets/dashboard_header.dart';
import '../widgets/stat_cards_section.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) {
        context.read<DashboardProvider>().loadDashboard();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final dashboardProvider = context.watch<DashboardProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: const Drawer(
        width: 300,
        child: SidebarWidget(),
      ),
      appBar: const DashboardHeader(),
      body: Builder(
        builder: (context) {
          if (dashboardProvider.isLoading && dashboardProvider.stats.totalAuctions == 0) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }

          if (dashboardProvider.errorMessage != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline_rounded, color: AppColors.error, size: 80),
                    const SizedBox(height: 16),
                    Text(
                      dashboardProvider.errorMessage!,
                      style: AppTextStyles.h3.copyWith(color: AppColors.error),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () => dashboardProvider.loadDashboard(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text('إعادة المحاولة', style: AppTextStyles.h3.copyWith(color: Colors.white)),
                    ),
                  ],
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => dashboardProvider.loadDashboard(),
            color: AppColors.primary,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('مرحباً بك مجدداً 👋', style: AppTextStyles.h2),
                          const SizedBox(height: 4),
                          Text('إليك ملخص النشاط اليوم', style: AppTextStyles.body2.copyWith(color: AppColors.textSecondary)),
                        ],
                      ),
                      GestureDetector(
                        onTap: () => dashboardProvider.loadDashboard(),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.card,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Icon(
                            dashboardProvider.isLoading ? Icons.sync : Icons.refresh_rounded, 
                            color: AppColors.textSecondary, 
                            size: 20
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (dashboardProvider.isLoading)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12.0),
                      child: LinearProgressIndicator(
                        backgroundColor: AppColors.border,
                        valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                        borderRadius: BorderRadius.all(Radius.circular(4)),
                      ),
                    ),
                  const SizedBox(height: 24),
                  
                  // Mobile Native Stat Cards Section
                  const StatCardsSection(),
                  
                  const SizedBox(height: 24),
                ],
              ),
            ),
          );
        }
      ),
    );
  }
}
