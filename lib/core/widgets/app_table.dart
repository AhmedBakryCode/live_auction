import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class AppTable extends StatelessWidget {
  final List<String> headers;
  final List<List<Widget>> rows;

  const AppTable({super.key, required this.headers, required this.rows});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Table(
        defaultColumnWidth: const IntrinsicColumnWidth(),
        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
        children: [
          TableRow(
            decoration: const BoxDecoration(
              color: AppColors.surface,
              border: Border(
                bottom: BorderSide(color: AppColors.border, width: 1),
              ),
            ),
            children: headers
                .map(
                  (h) => Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 16.0,
                      horizontal: 16.0,
                    ),
                    child: Text(
                      h,
                      style: AppTextStyles.body1Bold.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          ...rows.map(
            (row) => TableRow(
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: AppColors.border, width: 1),
                ),
              ),
              children: row
                  .map(
                    (cell) => Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 14.0,
                        horizontal: 16.0,
                      ),
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: cell,
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}
