import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../models/user_model.dart';
import '../providers/users_provider.dart';

class UserDetailsScreen extends StatefulWidget {
  final int userId;
  const UserDetailsScreen({super.key, required this.userId});

  @override
  State<UserDetailsScreen> createState() => _UserDetailsScreenState();
}

class _UserDetailsScreenState extends State<UserDetailsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) {
        context.read<UsersProvider>().fetchUserDetails(widget.userId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<UsersProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('تفاصيل العضو', style: AppTextStyles.h2),
        centerTitle: true,
        actions: [
          if (provider.selectedUser != null)
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error),
              onPressed: () => _confirmDelete(context, provider),
            ),
          if (provider.selectedUser != null)
            IconButton(
              icon: const Icon(Icons.refresh_rounded, color: AppColors.textSecondary),
              onPressed: () => context.read<UsersProvider>().fetchUserDetails(widget.userId),
            ),
        ],
      ),
      body: _buildBody(provider),
    );
  }

  Widget _buildBody(UsersProvider provider) {
    // Loading state
    if (provider.isLoadingDetails) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: AppColors.primary),
            SizedBox(height: 16),
            Text('جاري تحميل بيانات العضو...', style: TextStyle(color: AppColors.textSecondary, fontFamily: 'Cairo')),
          ],
        ),
      );
    }

    // Error state
    if (provider.detailsErrorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.person_off_rounded, color: AppColors.error, size: 64),
              ),
              const SizedBox(height: 24),
              Text(
                provider.detailsErrorMessage!,
                style: AppTextStyles.h3.copyWith(color: AppColors.error),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => context.read<UsersProvider>().fetchUserDetails(widget.userId),
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('إعادة المحاولة', style: TextStyle(fontFamily: 'Cairo')),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // No data
    if (provider.selectedUser == null) {
      return const Center(child: Text('لا توجد بيانات', style: TextStyle(color: AppColors.textSecondary)));
    }

    return _buildUserDetails(provider.selectedUser!);
  }

  Widget _buildUserDetails(UserModel user) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── 1. Profile Header ───────────────────────────────────────────
          _buildProfileHeader(user),
          const SizedBox(height: 24),

          // ── 2. Personal Info ────────────────────────────────────────────
          _buildSection(
            title: 'المعلومات الشخصية',
            icon: Icons.person_rounded,
            children: [
              _buildInfoTile('الاسم الأول', user.firstName ?? '—', Icons.badge_outlined),
              _buildInfoTile('الاسم الأخير', user.lastName ?? '—', Icons.badge_outlined),
              _buildInfoTile('الدور', user.role.toUpperCase(), Icons.shield_outlined, valueColor: AppColors.primary),
              _buildInfoTile('رقم العضو', '#${user.id}', Icons.tag_rounded),
            ],
          ),
          const SizedBox(height: 16),

          // ── 3. Contact Info ─────────────────────────────────────────────
          _buildSection(
            title: 'معلومات التواصل',
            icon: Icons.contact_mail_rounded,
            children: [
              _buildInfoTile(
                'البريد الإلكتروني',
                user.email,
                Icons.email_outlined,
                copyable: true,
                trailing: user.emailVerifiedAt != null
                    ? _verifiedBadge()
                    : _unverifiedBadge(),
              ),
              if (user.phone != null && user.phone!.isNotEmpty)
                _buildInfoTile('رقم الهاتف', user.phone!, Icons.phone_outlined, copyable: true),
              if (user.address != null && user.address!.isNotEmpty)
                _buildInfoTile('العنوان', user.address!, Icons.location_on_outlined),
            ],
          ),
          const SizedBox(height: 16),

          // ── 4. Date Info ────────────────────────────────────────────────
          _buildSection(
            title: 'تواريخ الحساب',
            icon: Icons.calendar_month_rounded,
            children: [
              _buildInfoTile(
                'تاريخ الإنضمام',
                DateFormat('dd MMMM yyyy - hh:mm a', 'en_US').format(user.createdAt),
                Icons.calendar_today_outlined,
              ),
              _buildInfoTile(
                'آخر تحديث',
                DateFormat('dd MMMM yyyy - hh:mm a', 'en_US').format(user.updatedAt),
                Icons.update_rounded,
              ),
              if (user.emailVerifiedAt != null)
                _buildInfoTile(
                  'تاريخ التحقق من البريد',
                  DateFormat('dd MMMM yyyy', 'en_US').format(user.emailVerifiedAt!),
                  Icons.verified_rounded,
                  valueColor: AppColors.success,
                ),
            ],
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(UserModel user) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          // Avatar
          Stack(
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.background,
                  border: Border.all(color: AppColors.primary, width: 2),
                ),
                child: ClipOval(
                  child: user.fullProfileImageUrl.isNotEmpty
                      ? Image.network(
                          user.fullProfileImageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Icon(
                            Icons.person, color: AppColors.textSecondary, size: 50,
                          ),
                        )
                      : const Icon(Icons.person, color: AppColors.textSecondary, size: 50),
                ),
              ),
              if (user.emailVerifiedAt != null)
                Positioned(
                  right: 2,
                  bottom: 2,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(color: AppColors.success, shape: BoxShape.circle),
                    child: const Icon(Icons.check, color: Colors.white, size: 14),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            user.fullName.isNotEmpty ? user.fullName : 'بدون اسم',
            style: AppTextStyles.h2,
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
            ),
            child: Text(
              user.role.toUpperCase(),
              style: AppTextStyles.caption.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            user.email,
            style: AppTextStyles.body2,
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: AppColors.primary, size: 18),
                ),
                const SizedBox(width: 10),
                Text(title, style: AppTextStyles.h3),
              ],
            ),
          ),
          const Divider(color: AppColors.border, height: 1),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoTile(
    String label,
    String value,
    IconData icon, {
    bool copyable = false,
    Color? valueColor,
    Widget? trailing,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Icon(icon, color: AppColors.textSecondary, size: 18),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AppTextStyles.caption),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: AppTextStyles.body2.copyWith(
                    color: valueColor ?? AppColors.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          if (trailing != null) trailing,
          if (copyable)
            GestureDetector(
              onTap: () {
                Clipboard.setData(ClipboardData(text: value));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('تم نسخ "$value"', style: const TextStyle(fontFamily: 'Cairo')),
                    backgroundColor: AppColors.success,
                    duration: const Duration(seconds: 2),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                );
              },
              child: const Icon(Icons.copy_rounded, color: AppColors.textSecondary, size: 18),
            ),
        ],
      ),
    );
  }

  Widget _verifiedBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.verified_rounded, color: AppColors.success, size: 12),
          const SizedBox(width: 4),
          Text('موثّق', style: AppTextStyles.caption.copyWith(color: AppColors.success, fontSize: 10)),
        ],
      ),
    );
  }

  Widget _unverifiedBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.warning_rounded, color: AppColors.warning, size: 12),
          const SizedBox(width: 4),
          Text('غير موثّق', style: AppTextStyles.caption.copyWith(color: AppColors.warning, fontSize: 10)),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, UsersProvider provider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text('تأكيد الحذف', style: AppTextStyles.h3),
        content: Text(
          'هل أنت متأكد أنك تريد حذف هذا المستخدم نهائياً؟ لا يمكن التراجع عن هذا الإجراء.',
          style: AppTextStyles.body2,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('إلغاء', style: TextStyle(color: AppColors.textSecondary, fontFamily: 'Cairo')),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () async {
              Navigator.pop(ctx); // Close dialog

              // Show quick loading snackbar
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('جاري الحذف...', style: TextStyle(fontFamily: 'Cairo')),
                  duration: Duration(seconds: 1),
                ),
              );

              final success = await provider.deleteUser(widget.userId);

              if (!mounted) return;

              ScaffoldMessenger.of(context).hideCurrentSnackBar();

              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('تم حذف المستخدم بنجاح', style: TextStyle(fontFamily: 'Cairo', color: Colors.white)),
                    backgroundColor: AppColors.success,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
                Navigator.pop(context); // Go back to users list
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(provider.errorMessage ?? 'فشل الحذف', style: const TextStyle(fontFamily: 'Cairo', color: Colors.white)),
                    backgroundColor: AppColors.error,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            child: const Text('حذف', style: TextStyle(fontFamily: 'Cairo')),
          ),
        ],
      ),
    );
  }
}
