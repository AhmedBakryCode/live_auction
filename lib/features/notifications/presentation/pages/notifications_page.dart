import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../bloc/notifications_bloc.dart';



class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: context.read<NotificationsBloc>()..add(LoadNotifications()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('الإشعارات'),
          actions: [
            TextButton(
              onPressed: () {},
              child: const Text('تحديد الكل كمقروء'),
            ),
          ],
        ),
        body: BlocBuilder<NotificationsBloc, NotificationsState>(
          builder: (context, state) {
            if (state is NotificationsLoading) {
              return const LoadingIndicator();
            } else if (state is NotificationsError) {
              return ErrorView(
                message: state.message,
                onRetry: () => context.read<NotificationsBloc>().add(LoadNotifications()),
              );
            } else if (state is NotificationsLoaded) {
              if (state.notifications.isEmpty) {
                return const EmptyStateWidget(
                  message: 'سنقوم بتنبيهك عند حدوث أي نشاط مهم.',
                  icon: Icons.notifications_none_rounded,
                );
              }
              return RefreshIndicator(
                onRefresh: () async => context.read<NotificationsBloc>().add(LoadNotifications()),
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: state.notifications.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final notification = state.notifications[index];
                    return _buildNotificationItem(context, notification);
                  },
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildNotificationItem(BuildContext context, Map<String, dynamic> notification) {
    final bool isRead = notification['isRead'] ?? true;
    final type = notification['type'] as NotificationType;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isRead ? Colors.transparent : AppColors.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isRead 
            ? (isDark ? Colors.white10 : Colors.grey[200]!) 
            : AppColors.primary.withOpacity(0.2)
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildIconContainer(type),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      notification['title'],
                      style: AppTextStyles.bodyLarge.copyWith(
                        fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
                        color: AppColors.getPrimaryText(context),
                      ),
                    ),
                    if (!isRead)
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  notification['body'],
                  style: AppTextStyles.bodyMedium.copyWith(color: AppColors.getSecondaryText(context)),
                ),
                const SizedBox(height: 8),
                Text(
                  notification['time'], 
                  style: AppTextStyles.caption.copyWith(color: AppColors.getSecondaryText(context)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIconContainer(NotificationType type) {
    IconData icon;
    Color color;

    switch (type) {
      case NotificationType.won:
        icon = Icons.emoji_events;
        color = Colors.amber;
        break;
      case NotificationType.outbid:
        icon = Icons.warning_amber_rounded;
        color = Colors.red;
        break;
      case NotificationType.endingSoon:
        icon = Icons.timer_outlined;
        color = Colors.orange;
        break;
      case NotificationType.news:
        icon = Icons.campaign_outlined;
        color = AppColors.primary;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: color, size: 24),
    );
  }
}
