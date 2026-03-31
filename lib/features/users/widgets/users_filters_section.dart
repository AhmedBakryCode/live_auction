import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class UsersFiltersSection extends StatelessWidget {
  const UsersFiltersSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          // Premium Search Bar
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 55,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppColors.border),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.search_rounded, color: AppColors.textSecondary),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          style: AppTextStyles.body1,
                          decoration: InputDecoration(
                            hintText: 'ابحث عن اسم، بريد، أو هاتف...',
                            hintStyle: AppTextStyles.body2,
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              _buildFilterIcon(),
            ],
          ),
          const SizedBox(height: 16),
          // Scrollable Filter Chips
          SizedBox(
            height: 42,
            child: ListView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              children: [
                _buildChip('الكل', true),
                _buildChip('مدير', false),
                _buildChip('بائعين', false),
                _buildChip('نشطين', false),
                _buildChip('محظورين', false),
                _buildChip('موثقين', false),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterIcon() {
    return Container(
      height: 55,
      width: 55,
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: const Icon(Icons.tune_rounded, color: AppColors.primary),
    );
  }

  Widget _buildChip(String label, bool isSelected) {
    return Container(
      margin: const EdgeInsets.only(left: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (v) {},
        labelStyle: AppTextStyles.caption.copyWith(
          color: isSelected ? Colors.black : AppColors.textSecondary,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
        backgroundColor: AppColors.card,
        selectedColor: AppColors.primary,
        checkmarkColor: Colors.black,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: isSelected ? AppColors.primary : AppColors.border),
        ),
      ),
    );
  }
}
