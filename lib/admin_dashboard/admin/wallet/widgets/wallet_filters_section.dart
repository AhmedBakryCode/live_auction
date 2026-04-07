import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class WalletFiltersSection extends StatelessWidget {
  const WalletFiltersSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth > 800) {
                return Row(
                  children: [
                    Expanded(child: _buildDropdown('نوع المعاملة', ['جميع المعاملات', 'إيداع', 'سحب', 'دفع', 'استرداد'])),
                    const SizedBox(width: 12),
                    Expanded(child: _buildDropdown('الحالة', ['جميع الحالات', 'مكتمل', 'قيد الانتظار', 'فشل'])),
                    const SizedBox(width: 12),
                    Expanded(child: _buildDropdown('الفترة', ['اليوم', 'هذا الأسبوع', 'هذا الشهر', 'هذا العام', 'مخصص'])),
                    const SizedBox(width: 12),
                    Expanded(child: _buildAmountRange()),
                    const SizedBox(width: 12),
                    _buildSearchButton(),
                  ],
                );
              } else {
                return Column(
                  children: [
                    Row(
                      children: [
                        Expanded(child: _buildDropdown('نوع المعاملة', ['جميع المعاملات', 'إيداع', 'سحب', 'دفع', 'استرداد'])),
                        const SizedBox(width: 12),
                        Expanded(child: _buildDropdown('الحالة', ['جميع الحالات', 'مكتمل', 'قيد الانتظار', 'فشل'])),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(child: _buildDropdown('الفترة', ['اليوم', 'هذا الأسبوع', 'هذا الشهر', 'هذا العام', 'مخصص'])),
                        const SizedBox(width: 12),
                        Expanded(child: _buildAmountRange()),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildSearchButton(fullWidth: true),
                  ],
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown(String label, List<String> options) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary, fontSize: 11)),
        const SizedBox(height: 6),
        Container(
          height: 40,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: options[0],
              isExpanded: true,
              dropdownColor: AppColors.card,
              style: AppTextStyles.body2,
              items: options.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (_) {},
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAmountRange() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('نطاق المبلغ', style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary, fontSize: 11)),
        const SizedBox(height: 6),
        Row(
          children: [
            Expanded(
              child: _buildTextField('من'),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildTextField('إلى'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTextField(String hint) {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: TextField(
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: hint,
          hintStyle: AppTextStyles.caption.copyWith(color: AppColors.textExtraSecondary),
          contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        ),
        style: AppTextStyles.body2,
        keyboardType: TextInputType.number,
      ),
    );
  }

  Widget _buildSearchButton({bool fullWidth = false}) {
    return Container(
      width: fullWidth ? double.infinity : null,
      height: 40,
      margin: fullWidth ? EdgeInsets.zero : const EdgeInsets.only(top: 14),
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 16),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_rounded, size: 18),
            SizedBox(width: 8),
            Text('بحث', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
