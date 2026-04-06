import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class HelpCenterPage extends StatelessWidget {
  const HelpCenterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('مركز المساعدة')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 24),
            _buildSection(
              context,
              'عن التطبيق',
              'مزاد لايف هو تطبيق مزادات إلكترونية يتيح للمستخدمين المشاركة في مزادات مباشرة على مختلف المنتجات. يمكنك الانضمام للمزادات والمزايدة على المنتجات التي تريدها بشكل سهل ومريح.',
            ),
            _buildSection(
              context,
              'كيفية الاستخدام',
              '''1. استعرض المزادات المتاحة في الصفحة الرئيسية
2. اختر المزاد الذي تريد المشاركة فيه
3. اضغط على "انضمام للمزاد" لدفع رسوم الدخول
4. بعد الانضمام، يمكنك تقديم مزايداتك
5. تابع المزاد لحظة بلحظة حتى انتهائه
6. إذا فزت بالمزاد، ستظهر لك تعليمات الدفع''',
            ),
            _buildSection(
              context,
              'المزايدة',
              '''• يجب أن تكون قد انضممت للمزاد أولاً
• يمكنك تقديم مزايدة أعلى من السعر الحالي
• سيتم إعلامك إذا تم تجاوز مزايدتك
• يمكنك متابعة جميع مزاداتك في صفحة المفضلة''',
            ),
            _buildSection(
              context,
              'الدفع والمحفظة',
              '''• يمكنك شحن محفظتك باستخدام بطاقة ائتمان أو محفظة إلكترونية
• رسوم الدخول للمزاد تخصم من المحفظة
• يمكنك سحب رصيدك في أي وقت
• جميع المعاملات آمنة ومشفرة''',
            ),
            _buildSection(
              context,
              'الدعم الفني',
              '''للاستفسارات والدعم الفني، يمكنك التواصل معنا عبر:
• البريد الإلكتروني: support@live-auction.com
• الهاتف: 19000
• ساعات العمل: من الأحد إلى الخميس، 9 ص - 5 م''',
            ),
            const SizedBox(height: 32),
            _buildContactButton(context),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Center(
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.help_outline,
              size: 40,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 16),
          Text('مرحباً بك في مركز المساعدة', style: AppTextStyles.heading3),
          const SizedBox(height: 8),
          Text(
            'هنا ستجد كل ما تحتاج معرفته عن استخدام التطبيق',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextStyles.heading3.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.getContainerColor(context),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(content, style: AppTextStyles.bodyMedium),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildContactButton(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () {
        // TODO: Open contact form or chat
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('سيتم توجيهك للدعم الفني قريباً')),
        );
      },
      icon: const Icon(Icons.chat_bubble_outline),
      label: const Text('تواصل مع الدعم الفني'),
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(double.infinity, 50),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
    );
  }
}
