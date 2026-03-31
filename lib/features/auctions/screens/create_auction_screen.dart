import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/section_header.dart';
import '../../dashboard/widgets/sidebar_widget.dart';

class CreateAuctionScreen extends StatelessWidget {
  const CreateAuctionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: const Drawer(width: 300, child: SidebarWidget()),
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu_rounded, color: AppColors.textPrimary),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: Text('إنشاء مزاد جديد', style: AppTextStyles.h2),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: AppColors.border, height: 1),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
        child: Column(
          children: [
            AppCard(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SectionHeader(title: 'بيانات المنتج'),
                  _buildField('اسم المنتج', 'مثال: ساعة رولكس أصلية'),
                  const SizedBox(height: 20),
                  _buildField('الوصف التفصيلي', 'أدخل تفاصيل حالة المنتج...', maxLines: 4),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(child: _buildField('السعر المبدئي', '\$ 0.00')),
                      const SizedBox(width: 16),
                      Expanded(child: _buildField('الزيادة الدنيا', '\$ 0.00')),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(child: _buildField('تاريخ البدء', '15/03/2026', icon: Icons.calendar_today_rounded)),
                      const SizedBox(width: 16),
                      Expanded(child: _buildField('تاريخ الانتهاء', '20/03/2026', icon: Icons.calendar_today_rounded)),
                    ],
                  ),
                  const SizedBox(height: 32),
                  const SectionHeader(title: 'الصورة الرئيسية'),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    decoration: BoxDecoration(
                      color: AppColors.background.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border, style: BorderStyle.solid),
                    ),
                    child: Column(
                      children: [
                        const Icon(Icons.add_a_photo_outlined, size: 40, color: AppColors.primary),
                        const SizedBox(height: 12),
                        Text('انقر أو اسحب الصورة هنا', style: AppTextStyles.body1Bold),
                        Text('JPG, PNG بحد أقصى 5 ميجابايت', style: AppTextStyles.caption),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.black,
                        textStyle: AppTextStyles.h3.copyWith(fontWeight: FontWeight.bold),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 0,
                      ),
                      onPressed: () {},
                      child: const Text('بدء المزاد الآن'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField(String label, String hint, {int maxLines = 1, IconData? icon}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.body1Bold.copyWith(fontSize: 13)),
        const SizedBox(height: 8),
        TextField(
          maxLines: maxLines,
          style: AppTextStyles.body1,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTextStyles.body2.copyWith(color: AppColors.textSecondary.withValues(alpha: 0.5)),
            prefixIcon: icon != null ? Icon(icon, size: 18, color: AppColors.primary) : null,
            filled: true,
            fillColor: AppColors.background,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary, width: 1)),
          ),
        ),
      ],
    );
  }
}
