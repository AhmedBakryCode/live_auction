import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_table.dart';
import '../providers/bids_provider.dart';

class BidsTableSection extends StatelessWidget {
  const BidsTableSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Table Header/Title
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('قائمة المزايدات', style: AppTextStyles.h2),
              ],
            ),
          ),

          // The Table
          Consumer<BidsProvider>(
            builder: (context, provider, child) {
              if (provider.isLoading) {
                return const Padding(
                  padding: EdgeInsets.all(40),
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              if (provider.error != null) {
                return Padding(
                  padding: const EdgeInsets.all(40),
                  child: Center(
                    child: Text(
                      provider.error!,
                      style: AppTextStyles.body1.copyWith(color: AppColors.error),
                    ),
                  ),
                );
              }

              if (provider.userBids.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.all(40),
                  child: Center(child: Text('لا توجد مزايدات', style: AppTextStyles.body1)),
                );
              }

              return AppTable(
                headers: const ['المزاد', 'المستخدم', 'المبلغ', 'التاريخ', 'الإجراءات'],
                rows: provider.userBids.map((bid) {
                  final dateParts = bid.createdAt.split(' ');
                  final date = dateParts.isNotEmpty ? dateParts.first : '';
                  final time = dateParts.length > 1 ? dateParts.last : '';
                  
                  return [
                    // Auction Column
                    Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.gavel_rounded, color: AppColors.primary),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('مزاد #${bid.auctionId}', style: AppTextStyles.body1Bold.copyWith(fontSize: 13)),
                            Text('#${bid.id}', style: AppTextStyles.caption.copyWith(fontSize: 11)),
                          ],
                        ),
                      ],
                    ),
                    // User Column
                    Row(
                      children: [
                        const CircleAvatar(
                          radius: 12,
                          backgroundColor: AppColors.primary,
                          child: Icon(Icons.person, size: 16, color: Colors.white),
                        ),
                        const SizedBox(width: 8),
                        Text('مستخدم #${bid.userId}', style: AppTextStyles.body2),
                      ],
                    ),
                    // Amount Column
                    Text('${bid.amount} \$', style: AppTextStyles.body1Bold.copyWith(color: AppColors.primary)),
                    // Time Column
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(date, style: AppTextStyles.body2),
                        Text(time, style: AppTextStyles.caption.copyWith(fontSize: 10)),
                      ],
                    ),
                    // Actions Column
                    Row(
                      children: [
                        _buildTableAction(Icons.visibility_outlined, Colors.blue),
                      ],
                    ),
                  ];
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTableAction(IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(left: 4),
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, color: color, size: 16),
    );
  }
}
