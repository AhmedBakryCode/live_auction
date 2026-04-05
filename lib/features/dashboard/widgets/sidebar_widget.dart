import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../routes/app_routes.dart';
import '../../auth/repositories/auth_repository.dart';

class SidebarWidget extends StatefulWidget {
  const SidebarWidget({super.key});

  @override
  State<SidebarWidget> createState() => _SidebarWidgetState();
}

class _SidebarWidgetState extends State<SidebarWidget> {
  final _authRepository = AuthRepository();
  bool _isLoggingOut = false;

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'تأكيد تسجيل الخروج',
          style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'هل أنت متأكد أنك تريد تسجيل الخروج؟',
          style: TextStyle(fontFamily: 'Cairo'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text(
              'إلغاء',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontFamily: 'Cairo',
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'تسجيل الخروج',
              style: TextStyle(color: Colors.white, fontFamily: 'Cairo'),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _isLoggingOut = true);

    try {
      final message = await _authRepository.logout();
      if (mounted) {
        Navigator.of(context).pop(); // Close drawer
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message, style: const TextStyle(fontFamily: 'Cairo')),
            backgroundColor: Colors.green,
          ),
        );
        // Navigate to dashboard root and clear stack
        Navigator.of(
          context,
        ).pushNamedAndRemoveUntil(AppRoutes.login, (route) => false);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              e.toString().replaceAll('Exception: ', ''),
              style: const TextStyle(fontFamily: 'Cairo'),
            ),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoggingOut = false);
    }
  }

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
                  child: const Icon(
                    Icons.gavel_rounded,
                    color: AppColors.primary,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  'مزادات موبايل',
                  style: AppTextStyles.h1.copyWith(color: AppColors.primary),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              children: [
                _buildMenuItem(
                  context,
                  'الرئيسية',
                  Icons.grid_view_rounded,
                  AppRoutes.dashboard,
                ),
                _buildMenuItem(
                  context,
                  'المزادات',
                  Icons.gavel_rounded,
                  AppRoutes.auctions,
                ),
                _buildMenuItem(
                  context,
                  'المزادات المدفوعة',
                  Icons.monetization_on_outlined,
                  AppRoutes.paidAuctions,
                ),
                _buildMenuItem(
                  context,
                  'المزادات المعاد نشرها',
                  Icons.replay_circle_filled_outlined,
                  AppRoutes.repostedAuctions,
                ),
                _buildMenuItem(
                  context,
                  'المزادات المغلقة',
                  Icons.lock_clock_outlined,
                  AppRoutes.closedAuctions,
                ),
                _buildMenuItem(
                  context,
                  'المزادات القادمة',
                  Icons.upcoming_outlined,
                  AppRoutes.upcomingAuctions,
                ),
                _buildMenuItem(
                  context,
                  'المزادات النشطة',
                  Icons.local_fire_department_outlined,
                  AppRoutes.activeAuctions,
                ),
                _buildMenuItem(
                  context,
                  'البحث عن المزادات',
                  Icons.search_rounded,
                  AppRoutes.searchAuctions,
                ),
                _buildMenuItem(
                  context,
                  'بحث متقدم',
                  Icons.tune_rounded,
                  AppRoutes.filterAuctions,
                ),
                _buildMenuItem(
                  context,
                  'إنشاء مزاد',
                  Icons.add_box_outlined,
                  AppRoutes.createAuction,
                ),
                _buildMenuItem(
                  context,
                  'المستخدمون',
                  Icons.people_alt_outlined,
                  AppRoutes.users,
                ),
                _buildMenuItem(
                  context,
                  'تسجيل مستخدم جديد',
                  Icons.person_add_outlined,
                  AppRoutes.register,
                ),
                _buildMenuItem(
                  context,
                  'المزايدات',
                  Icons.history_rounded,
                  AppRoutes.bidsHistory,
                ),
                _buildMenuItem(
                  context,
                  'المحفظة',
                  Icons.account_balance_wallet_outlined,
                  AppRoutes.wallet,
                ),
                _buildMenuItem(
                  context,
                  'الإشعارات',
                  Icons.notifications_none_rounded,
                  '',
                ),
                _buildMenuItem(
                  context,
                  'المتصدرون',
                  Icons.emoji_events_outlined,
                  AppRoutes.leaderboard,
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20.0),
                  child: Divider(color: AppColors.border),
                ),
                _buildMenuItem(
                  context,
                  'الملف الشخصي',
                  Icons.account_circle_outlined,
                  AppRoutes.profile,
                ),
                _buildMenuItem(
                  context,
                  'الإعدادات',
                  Icons.settings_outlined,
                  '',
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            child: Container(
              padding: const EdgeInsets.all(14),
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
                    child: Icon(
                      Icons.person_rounded,
                      color: Colors.black,
                      size: 20,
                    ),
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
                  _isLoggingOut
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.error,
                          ),
                        )
                      : IconButton(
                          tooltip: 'تسجيل الخروج',
                          icon: const Icon(
                            Icons.logout_rounded,
                            color: AppColors.error,
                            size: 22,
                          ),
                          onPressed: _logout,
                        ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context,
    String title,
    IconData icon,
    String route,
  ) {
    String? currentRoute = ModalRoute.of(context)?.settings.name;
    bool selected = (route.isNotEmpty && currentRoute == route);

    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      child: ListTile(
        leading: Icon(
          icon,
          color: selected ? AppColors.primary : AppColors.textSecondary,
          size: 22,
        ),
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
