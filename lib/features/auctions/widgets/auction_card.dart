import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class AuctionCard extends StatelessWidget {
  final Map<String, dynamic> auction;

  const AuctionCard({super.key, required this.auction});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          // Info Section
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product Image
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.network(
                    auction['image'],
                    width: 90,
                    height: 90,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 16),
                // Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              auction['category'],
                              style: AppTextStyles.caption.copyWith(color: AppColors.primary),
                            ),
                          ),
                          _buildStatusBadge(auction['status']),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(auction['name'], style: AppTextStyles.h3),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.timer_outlined, size: 14, color: Colors.orangeAccent),
                          const SizedBox(width: 4),
                          Text(auction['remainingTime'], style: AppTextStyles.caption.copyWith(color: Colors.orangeAccent)),
                          const Spacer(),
                          const Icon(Icons.people_outline, size: 14, color: AppColors.textSecondary),
                          const SizedBox(width: 4),
                          Text('${auction['bidsCount']} مزايدة', style: AppTextStyles.caption),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(color: AppColors.border, height: 1),
          // Price Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildPriceCol('بداية المزاد', auction['startPrice']),
                _buildPriceCol('السعر الحالي', auction['currentPrice'], isHighlight: true),
                _buildBidderAvatar(auction['topBidderAvatar'], auction['topBidder']),
              ],
            ),
          ),
          const Divider(color: AppColors.border, height: 1),
          // Actions Section
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                _buildActionButton(Icons.visibility_outlined, 'عرض', Colors.blueAccent),
                _buildActionButton(Icons.edit_outlined, 'تعديل', Colors.grey),
                _buildActionButton(Icons.block_flipped, 'إيقاف', Colors.orange),
                const Spacer(),
                _buildActionButton(Icons.delete_outline, 'حذف', AppColors.error),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    final bool isActive = status == 'نشط';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isActive ? Colors.green.withOpacity(0.1) : Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(radius: 3, backgroundColor: isActive ? Colors.green : Colors.blue),
          const SizedBox(width: 4),
          Text(status, style: AppTextStyles.caption.copyWith(color: isActive ? Colors.green : Colors.blue)),
        ],
      ),
    );
  }

  Widget _buildPriceCol(String label, String value, {bool isHighlight = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.caption),
        Text(value, style: isHighlight ? AppTextStyles.body1Bold.copyWith(color: AppColors.primary) : AppTextStyles.body1Bold),
      ],
    );
  }

  Widget _buildBidderAvatar(String url, String name) {
    return Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text('أعلى مزايد', style: AppTextStyles.caption),
            Text(name, style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
          ],
        ),
        const SizedBox(width: 8),
        CircleAvatar(
          radius: 16,
          backgroundImage: NetworkImage(url),
        ),
      ],
    );
  }

  Widget _buildActionButton(IconData icon, String label, Color color) {
    return InkWell(
      onTap: () {},
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(height: 2),
            Text(label, style: AppTextStyles.caption.copyWith(fontSize: 9, color: color)),
          ],
        ),
      ),
    );
  }
}
