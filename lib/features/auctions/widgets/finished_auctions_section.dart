import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/section_header.dart';

class FinishedAuctionsSection extends StatelessWidget {
  const FinishedAuctionsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> finished = [
      {
        'title': 'سيارة مرسيدس G-Class',
        'image': 'https://images.unsplash.com/photo-1541899481282-d53bffe3c35d?w=400',
        'price': '\$150,000',
        'winner': 'يوسف كمال',
        'time': 'منذ ساعة',
      },
      {
        'title': 'آيفون 15 برو ماكس',
        'image': 'https://images.unsplash.com/photo-1696446701796-da61225697cc?w=400',
        'price': '\$1,100',
        'winner': 'ليلى أحمد',
        'time': 'منذ 3 ساعات',
      },
      {
        'title': 'لوحة فنية نادرة',
        'image': 'https://images.unsplash.com/photo-1579783902614-a3fb3927b6a5?w=400',
        'price': '\$5,000',
        'winner': 'محمد فوزي',
        'time': 'منذ أمس',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: SectionHeader(title: 'مزادات انتهت مؤخراً'),
        ),
        SizedBox(
          height: 180,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            scrollDirection: Axis.horizontal,
            itemCount: finished.length,
            separatorBuilder: (context, index) => const SizedBox(width: 16),
            itemBuilder: (context, index) {
              final item = finished[index];
              return Container(
                width: 150,
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.border),
                ),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 5,
                      child: Image.network(
                        item['image'],
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Expanded(
                      flex: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              item['title'],
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(item['price'], style: AppTextStyles.caption.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold)),
                                Text(item['time'], style: const TextStyle(fontSize: 8, color: AppColors.textSecondary, fontFamily: 'Cairo')),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
