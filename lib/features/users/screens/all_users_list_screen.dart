import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../widgets/users_list_section.dart';

class AllUsersListScreen extends StatelessWidget {
  const AllUsersListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('قائمة كافة المستخدمين', style: AppTextStyles.h2),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add_alt_1_outlined, color: AppColors.primary),
            onPressed: () {},
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Internal Search Bar
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
              child: _buildSearchBar(),
            ),

            // The Clean List
            const Expanded(
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
