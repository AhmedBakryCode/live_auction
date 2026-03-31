import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../routes/app_routes.dart';

class SidebarWidget extends StatelessWidget {
  const SidebarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(24, 60, 24, 32),
            decoration: BoxDecoration(
              color: AppColors.background.withValues(alpha: 0.3),
              border: const Border(bottom: BorderSide(color: AppColors.border)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.gavel_rounded, color: AppColors.primary, size: 28),
                ),
                const SizedBox(width: 16),
                Text('مزادات موبايل', style: AppTextStyles.h1.copyWith(color: AppColors.primary)),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              children: [
                _buildMenuItem(context, 'الرئيسية', Icons.grid_view_rounded, AppRoutes.dashboard),
                _buildMenuItem(context, 'المزادات', Icons.gavel_rounded, AppRoutes.auctions),
                _buildMenuItem(context, 'إنشاء مزاد', Icons.add_box_outlined, AppRoutes.createAuction),
                _buildMenuItem(context, 'المستخدمون', Icons.people_alt_outlined, AppRoutes.users),
                _buildMenuItem(context, 'المزايدات', Icons.history_rounded, AppRoutes.bidsHistory),
                _buildMenuItem(context, 'المحفظة', Icons.account_balance_wallet_outlined, AppRoutes.wallet),
                _buildMenuItem(context, 'الإشعارات', Icons.notifications_none_rounded, ''),
                _buildMenuItem(context, 'المتصدرون', Icons.emoji_events_outlined, AppRoutes.leaderboard),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20.0),
                  child: Divider(color: AppColors.border),
                ),
                _buildMenuItem(context, 'الإعدادات', Icons.settings_outlined, ''),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 20,
                    backgroundColor: AppColors.primary,
                    child: Icon(Icons.person_rounded, color: Colors.black, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('أحمد بكري', style: AppTextStyles.body1Bold),
                        Text('admin@live.com', style: AppTextStyles.caption),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(BuildContext context, String title, IconData icon, String route) {
    String? currentRoute = ModalRoute.of(context)?.settings.name;
    bool selected = (route.isNotEmpty && currentRoute == route);

    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      child: ListTile(
        leading: Icon(icon, color: selected ? AppColors.primary : AppColors.textSecondary, size: 22),
        title: Text(
          title,
          style: AppTextStyles.body1.copyWith(
            color: selected ? AppColors.primary : AppColors.textSecondary,
            fontWeight: selected ? FontWeight.bold : FontWeight.w500,
          ),
        ),
        selected: selected,
        selectedTileColor: AppColors.primary.withValues(alpha: 0.1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        onTap: () {
          if (route.isNotEmpty && currentRoute != route) {
            Navigator.pushReplacementNamed(context, route);
          }
        },
      ),
    );
  }
}
