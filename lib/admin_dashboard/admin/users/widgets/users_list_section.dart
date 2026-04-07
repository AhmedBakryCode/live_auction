import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/users_provider.dart';
import 'user_card.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class UsersListSection extends StatefulWidget {
  const UsersListSection({super.key});

  @override
  State<UsersListSection> createState() => _UsersListSectionState();
}

class _UsersListSectionState extends State<UsersListSection> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) {
        context.read<UsersProvider>().loadUsers();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final usersProvider = context.watch<UsersProvider>();
    final users = usersProvider.users;
    final pagination = usersProvider.pagination;

    if (usersProvider.isLoading && users.isEmpty) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    }

    if (usersProvider.errorMessage != null && users.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline_rounded, color: AppColors.error, size: 60),
            const SizedBox(height: 16),
            Text(usersProvider.errorMessage!, style: AppTextStyles.body1.copyWith(color: AppColors.error)),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => usersProvider.loadUsers(),
              child: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      );
    }

    if (users.isEmpty) {
      return  Center(
        child: Text('لا يوجد مستخدمين حالياً', style: AppTextStyles.body1),
      );
    }

    return Column(
      children: [
        Expanded(
          child: RefreshIndicator(
            onRefresh: () => usersProvider.loadUsers(),
            color: AppColors.primary,
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              physics: const BouncingScrollPhysics(),
              itemCount: users.length,
              itemBuilder: (context, index) => UserCard(user: users[index]),
            ),
          ),
        ),
        
        // Pagination Controls
        if (pagination != null)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              border: const Border(top: BorderSide(color: AppColors.border)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _PaginationButton(
                  onPressed: pagination.prevPageUrl != null
                      ? () => usersProvider.loadUsers(page: pagination.currentPage - 1)
                      : null,
                  icon: Icons.arrow_back_ios_new_rounded,
                  label: 'السابق',
                ),
                if (pagination.from != null && pagination.to != null)
                  Text(
                    'عرض ${pagination.from} - ${pagination.to} من ${pagination.total}',
                    style: AppTextStyles.caption.copyWith(fontSize: 10, color: AppColors.textExtraSecondary),
                  ),
                Text(
                  'صفحة ${pagination.currentPage} من ${pagination.lastPage}',
                  style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.bold),
                ),
                _PaginationButton(
                  onPressed: pagination.nextPageUrl != null
                      ? () => usersProvider.loadUsers(page: pagination.currentPage + 1)
                      : null,
                  icon: Icons.arrow_forward_ios_rounded,
                  label: 'التالي',
                  isNext: true,
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _PaginationButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final IconData icon;
  final String label;
  final bool isNext;

  const _PaginationButton({
    required this.onPressed,
    required this.icon,
    required this.label,
    this.isNext = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: onPressed != null ? AppColors.primary : AppColors.textExtraSecondary,
      ),
      icon: isNext ? Text(label, style: const TextStyle(fontWeight: FontWeight.bold)) : Icon(icon, size: 14),
      label: isNext ? Icon(icon, size: 14) : Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
    );
  }
}
