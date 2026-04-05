import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../routes/app_routes.dart';
import '../widgets/users_list_section.dart';
import '../../dashboard/widgets/dashboard_header.dart';
import '../../dashboard/widgets/sidebar_widget.dart';
import '../providers/users_provider.dart';

class UsersAdminScreen extends StatefulWidget {
  const UsersAdminScreen({super.key});

  @override
  State<UsersAdminScreen> createState() => _UsersAdminScreenState();
}

class _UsersAdminScreenState extends State<UsersAdminScreen> {
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
    
    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: Drawer(
        width: 300,
        child: SidebarWidget(),
      ),
      appBar: const DashboardHeader(),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. Page Header & Summary
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('إدارة الأعضاء', style: AppTextStyles.h1.copyWith(fontSize: 26)),
                      if (usersProvider.pagination != null)
                        Text(
                          'إجمالي المستخدمين المسجلين: ${usersProvider.pagination!.total}',
                          style: AppTextStyles.body2,
                        )
                      else
                        Text('جاري تحميل بيانات المستخدمين...', style: AppTextStyles.body2),
                    ],
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => Navigator.pushNamed(context, AppRoutes.createUser),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.add_rounded, color: Colors.black, size: 20),
                          const SizedBox(width: 8),
                          Text('إضافة عضو', style: AppTextStyles.body1Bold.copyWith(color: Colors.black, fontSize: 13)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: () => usersProvider.loadUsers(),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Icon(
                        usersProvider.isLoading ? Icons.sync : Icons.refresh_rounded, 
                        color: AppColors.textSecondary, 
                        size: 20
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // 2. Internal Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _buildSearchBar(),
            ),

            const SizedBox(height: 16),

            if (usersProvider.isLoading && usersProvider.users.isEmpty)
              Expanded(
                child: Center(child: CircularProgressIndicator(color: AppColors.primary))
              )
            else if (usersProvider.errorMessage != null && usersProvider.users.isEmpty)
              Expanded(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline_rounded, color: AppColors.error, size: 80),
                        const SizedBox(height: 16),
                        Text(
                          usersProvider.errorMessage!,
                          style: AppTextStyles.h3.copyWith(color: AppColors.error),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: () => usersProvider.loadUsers(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text('إعادة المحاولة'),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else
              // 3. The Real Dynamic List
              Expanded(
                child: UsersListSection(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      height: 55,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: const Row(
        children: [
          Icon(Icons.search_rounded, color: AppColors.textSecondary, size: 22),
          SizedBox(width: 12),
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'ابحث عن اسم، بريد أو هاتف...',
                hintStyle: TextStyle(color: AppColors.textSecondary, fontSize: 13, fontFamily: 'Cairo'),
                border: InputBorder.none,
              ),
            ),
          ),
          Icon(Icons.tune_rounded, color: AppColors.primary, size: 22),
        ],
      ),
    );
  }
}
