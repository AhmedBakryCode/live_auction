import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../models/user_model.dart';
import '../screens/user_details_screen.dart';
import '../providers/users_provider.dart';
import 'package:intl/intl.dart';

class UserCard extends StatelessWidget {
  final UserModel user;
  const UserCard({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => UserDetailsScreen(userId: user.id),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
        ),
        child: Column(
          children: [
            Row(
              children: [
                // 1. Avatar with Verification Badge
                Stack(
                  children: [
                    ClipOval(
                      child: Container(
                        width: 60,
                        height: 60,
                        color: AppColors.background,
                        child: user.fullProfileImageUrl.isNotEmpty
                            ? Image.network(
                                user.fullProfileImageUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => 
                                    const Icon(Icons.person, color: AppColors.textSecondary, size: 30),
                              )
                            : const Icon(Icons.person, color: AppColors.textSecondary, size: 30),
                      ),
                    ),
                    if (user.emailVerifiedAt != null)
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: const BoxDecoration(
                            color: AppColors.success,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.check, color: Colors.white, size: 12),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 16),
                
                // 2. Name & Role
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.fullName.isNotEmpty ? user.fullName : 'بدون اسم',
                        style: AppTextStyles.h3.copyWith(fontSize: 17),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          user.role.toUpperCase(),
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // 3. Status/ID
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('#${user.id}', style: AppTextStyles.caption),
                    const SizedBox(height: 4),
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert_rounded, color: AppColors.textSecondary, size: 22),
                      color: AppColors.surface,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      onSelected: (value) async {
                        if (value == 'delete') {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              backgroundColor: AppColors.surface,
                              title: const Text('تأكيد الحذف', style: TextStyle(fontFamily: 'Cairo')),
                              content: const Text('هل أنت متأكد أنك تريد حذف هذا المستخدم؟', style: TextStyle(fontFamily: 'Cairo')),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx, false),
                                  child: const Text('إلغاء', style: TextStyle(color: AppColors.textSecondary, fontFamily: 'Cairo')),
                                ),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.error, foregroundColor: Colors.white),
                                  onPressed: () => Navigator.pop(ctx, true),
                                  child: const Text('حذف', style: TextStyle(fontFamily: 'Cairo')),
                                ),
                              ],
                            ),
                          );

                          if (confirm == true && context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('جاري الحذف...', style: TextStyle(fontFamily: 'Cairo')),
                                duration: Duration(seconds: 1),
                              ),
                            );

                            final success = await context.read<UsersProvider>().deleteUser(user.id);
                            
                            if (!context.mounted) return;
                            
                            ScaffoldMessenger.of(context).hideCurrentSnackBar();

                            if (success) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('تم حذف المستخدم بنجاح', style: TextStyle(fontFamily: 'Cairo', color: Colors.white)),
                                  backgroundColor: AppColors.success,
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(context.read<UsersProvider>().errorMessage ?? 'فشل الحذف', style: const TextStyle(fontFamily: 'Cairo', color: Colors.white)),
                                  backgroundColor: AppColors.error,
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            }
                          }
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete_outline_rounded, color: AppColors.error, size: 20),
                              SizedBox(width: 8),
                              Text('حذف العضو', style: TextStyle(color: AppColors.error, fontFamily: 'Cairo')),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(color: AppColors.border, height: 1),
            const SizedBox(height: 16),
            
            // 4. Contact & Location Info
            _buildInfoRow(Icons.email_outlined, user.email),
            if (user.phone != null && user.phone!.isNotEmpty)
              _buildInfoRow(Icons.phone_outlined, user.phone!),
            if (user.address != null && user.address!.isNotEmpty)
              _buildInfoRow(Icons.location_on_outlined, user.address!),
            
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'تاريخ الإنضمام: ${DateFormat('yyyy-MM-dd', 'en_US').format(user.createdAt)}',
                  style: AppTextStyles.caption.copyWith(fontSize: 10),
                ),
                Text(
                  'آخر تحديث: ${DateFormat('yyyy-MM-dd', 'en_US').format(user.updatedAt)}',
                  style: AppTextStyles.caption.copyWith(fontSize: 10),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.textSecondary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: AppTextStyles.body2.copyWith(fontSize: 12),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
