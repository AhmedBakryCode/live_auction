import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../routes/app_routes.dart';
import 'package:provider/provider.dart';
import '../../notifications/providers/notifications_provider.dart';

class DashboardHeader extends StatelessWidget implements PreferredSizeWidget {
  const DashboardHeader({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(70);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.surface,
      elevation: 0,
      centerTitle: false,
      leading: Builder(
        builder: (context) => IconButton(
          icon: const Icon(Icons.menu_rounded, color: AppColors.textPrimary),
          onPressed: () => Scaffold.of(context).openDrawer(),
        ),
      ),
      title: Text('لوحة التحكم', style: AppTextStyles.h2),
      actions: [
        Consumer<NotificationsProvider>(
          builder: (context, notifProvider, _) {
            final hasUnread = notifProvider.unreadCount > 0;
            return Stack(
              alignment: Alignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.notifications_none_rounded, color: AppColors.textSecondary, size: 22),
                  onPressed: () {
                    if (ModalRoute.of(context)?.settings.name != AppRoutes.notifications) {
                      Navigator.pushNamed(context, AppRoutes.notifications);
                    }
                  },
                ),
                if (hasUnread)
                  Positioned(
                    right: 12,
                    top: 12,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppColors.secondary,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: () {
            if (ModalRoute.of(context)?.settings.name != AppRoutes.profile) {
              Navigator.pushNamed(context, AppRoutes.profile);
            }
          },
          child: const CircleAvatar(
            radius: 16,
            backgroundColor: AppColors.card,
            child: Icon(Icons.person_outline_rounded, size: 18, color: AppColors.textPrimary),
          ),
        ),
        const SizedBox(width: 16),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(color: AppColors.border, height: 1),
      ),
    );
  }
}
