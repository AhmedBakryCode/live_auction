import 'package:flutter/material.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/section_header.dart';
import '../../../core/widgets/app_table.dart';

class LatestBidsTable extends StatelessWidget {
  const LatestBidsTable({super.key});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(24.0),
            child: SectionHeader(
              title: 'أحدث المزايدات',
              actionText: 'عرض الكل',
            ),
          ),
          AppTable(
            headers: const ['المزاد', 'المستخدم', 'المبلغ', 'الوقت', 'الحالة'],
            rows: const [],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
