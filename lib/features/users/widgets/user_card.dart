import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class UserCard extends StatelessWidget {
  final Map<String, dynamic> user;
  const UserCard({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          // 1. Avatar with Status Dot
          Stack(
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: AppColors.background,
                backgroundImage: NetworkImage(user['avatar']),
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: _buildStatusDot(user['status']),
              ),
            ],
          ),
          const SizedBox(width: 16),
          
          // 2. Name & Secondary Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(user['name'], style: AppTextStyles.h3.copyWith(fontSize: 16)),
                    if (user['isVerified'])
                      const Padding(
                        padding: EdgeInsets.only(right: 6),
                        child: Icon(Icons.verified, color: Colors.blueAccent, size: 14),
                      ),
                  ],
                ),
                Text(user['role'], style: AppTextStyles.caption.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold)),
              ],
            ),
          ),

          // 3. Primary Metric (Wallet)
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(user['wallet'], style: AppTextStyles.body1Bold.copyWith(color: AppColors.primary)),
              const Text('الرصيد', style: TextStyle(fontSize: 10, color: AppColors.textSecondary, fontFamily: 'Cairo')),
            ],
          ),

          const SizedBox(width: 8),

          // 4. Compact Menu Icon
          const Icon(Icons.more_vert_rounded, color: AppColors.textSecondary, size: 20),
        ],
      ),
    );
  }

  Widget _buildStatusDot(String status) {
    Color color = Colors.greenAccent;
    if (status == 'محظور') color = AppColors.error;
    if (status == 'قيد الانتظار') color = Colors.orangeAccent;

    return Container(
      width: 14,
      height: 14,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.card, width: 2),
      ),
    );
  }
}
