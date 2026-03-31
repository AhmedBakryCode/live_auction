import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class FiltersSection extends StatefulWidget {
  const FiltersSection({super.key});

  @override
  State<FiltersSection> createState() => _FiltersSectionState();
}

class _FiltersSectionState extends State<FiltersSection> {
  int _selectedIndex = 0;
  final List<String> _filters = ['الكل', 'نشط', 'ينتهي قريباً', 'منتهي', 'قادم'];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        scrollDirection: Axis.horizontal,
        itemCount: _filters.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final isSelected = _selectedIndex == index;
          return InkWell(
            onTap: () => setState(() => _selectedIndex = index),
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : AppColors.card,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.border,
                ),
              ),
              child: Text(
                _filters[index],
                style: AppTextStyles.body1Bold.copyWith(
                  color: isSelected ? Colors.black : AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
