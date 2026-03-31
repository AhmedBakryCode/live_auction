import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../routes/app_routes.dart';
import '../widgets/users_statistics_section.dart';
import '../widgets/users_analytics_section.dart';
import '../../dashboard/widgets/dashboard_header.dart';
import '../../dashboard/widgets/sidebar_widget.dart';

class UsersAdminScreen extends StatelessWidget {
  const UsersAdminScreen({super.key});

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
              // 1. Page Header
              Text('إدارة الأعضاء', style: AppTextStyles.h1.copyWith(fontSize: 26)),
              Text('نظرة عامة على نشاط وإحصائيات المستخدمين', style: AppTextStyles.body2),
              
              const SizedBox(height: 32),

              // 2. Stats Section (The compact row you liked)
              const UsersStatisticsSection(),

              const SizedBox(height: 32),

              // 3. Main Actions Row (The "Proper" Buttons)
              Row(
                children: [
                  // Button: Add New User
                  Expanded(
                    child: _buildActionButton(
                      onTap: () {}, // Action for adding
                      label: 'إضافة عضو',
                      icon: Icons.person_add_rounded,
                      color: AppColors.primary,
                      isPrimary: true,
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Button: View Full List
                  Expanded(
                    child: _buildActionButton(
                      onTap: () => Navigator.pushNamed(context, AppRoutes.allUsersList),
                      label: 'قائمة المستخدمين',
                      icon: Icons.format_list_bulleted_rounded,
                      color: AppColors.card,
                      isPrimary: false,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // 4. Analytics Section
              const UsersAnalyticsSection(),

              const SizedBox(height: 32),

              // 5. Secondary Quick Links (Simplified)
              Text('روابط مفيدة', style: AppTextStyles.h2),
              const SizedBox(height: 16),
              _buildSecondaryLink(Icons.verified_user_rounded, 'طلبات توثيق الحسابات', '5 طلبات جديدة معلقة'),
              const SizedBox(height: 12),
              _buildSecondaryLink(Icons.bug_report_rounded, 'بلاغات الشكاوي', '2 بلاغ لم يتم قراءته'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required VoidCallback onTap,
    required String label,
    required IconData icon,
    required Color color,
    required bool isPrimary,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        height: 110,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
          border: isPrimary ? null : Border.all(color: AppColors.border),
          boxShadow: isPrimary ? [
            BoxShadow(
              color: color.withOpacity(0.2),
              blurRadius: 15,
              offset: const Offset(0, 8),
            )
          ] : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isPrimary ? Colors.black.withOpacity(0.1) : AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: isPrimary ? Colors.black : AppColors.primary, size: 26),
            ),
            const SizedBox(height: 12),
            Text(
              label,
              style: AppTextStyles.body1Bold.copyWith(
                color: isPrimary ? Colors.black : AppColors.textPrimary,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSecondaryLink(IconData icon, String title, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.body1Bold),
                Text(subtitle, style: AppTextStyles.caption.copyWith(fontSize: 11)),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios_rounded, color: AppColors.textSecondary, size: 14),
        ],
      ),
    );
  }
}
