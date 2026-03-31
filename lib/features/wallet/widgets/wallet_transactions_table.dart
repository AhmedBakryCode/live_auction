import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_table.dart';
import '../../../core/widgets/app_badge.dart';
import '../../../core/utils/mock_data.dart';

class WalletTransactionsTable extends StatelessWidget {
  const WalletTransactionsTable({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          AppTable(
            headers: const ['المستخدم', 'النوع', 'المبلغ', 'الرسوم', 'الوصف', 'الحالة', 'التاريخ', 'الإجراءات'],
            rows: MockData.walletTransactions.map((tx) => [
              // 1. User
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircleAvatar(
                    radius: 14,
                    backgroundImage: NetworkImage(tx['userAvatar'] as String),
                    backgroundColor: AppColors.surface,
                  ),
                  const SizedBox(width: 8),
                  Text(tx['user'] as String, style: AppTextStyles.body2.copyWith(fontSize: 13)),
                ],
              ),
              // 2. Type
              AppBadge(
                text: tx['type'] as String,
                color: _getIconColor(tx['typeColor'] as String),
                icon: _getIconData(tx['typeIcon'] as String),
              ),
              // 3. Amount
              Text(
                tx['amount'] as String,
                style: TextStyle(
                  color: _getAmountColor(tx['amount'] as String),
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              // 4. Fees
              Text(tx['fees'] as String, style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
              // 5. Description
              Text(tx['description'] as String, style: AppTextStyles.body2.copyWith(fontSize: 13)),
              // 6. Status
              AppBadge(
                text: tx['status'] as String,
                color: _getIconColor(tx['statusColor'] as String),
                icon: _getIconData(tx['statusIcon'] as String),
              ),
              // 7. Date/Time
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(tx['date'] as String, style: AppTextStyles.caption.copyWith(color: AppColors.textPrimary)),
                  Text(tx['time'] as String, style: AppTextStyles.caption.copyWith(color: AppColors.textExtraSecondary, fontSize: 10)),
                ],
              ),
              // 8. Actions
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildActionBtn(Icons.visibility_outlined, Colors.blue),
                  const SizedBox(width: 4),
                  _buildActionBtn(Icons.file_download_outlined, AppColors.textSecondary),
                ],
              ),
            ]).toList(),
          ),
          
          // Pagination
          _buildPagination(),
        ],
      ),
    );
  }

  Widget _buildPagination() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('عرض ١-٥ من ١٥٦ معاملة', style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
          Row(
            children: [
              _buildPageBtn(Icons.chevron_right_rounded, active: false, enabled: true),
              const SizedBox(width: 8),
              _buildPageBtn(null, label: '١', active: true),
              const SizedBox(width: 8),
              _buildPageBtn(null, label: '٢', active: false),
              const SizedBox(width: 8),
              _buildPageBtn(null, label: '٣', active: false),
              const SizedBox(width: 8),
              _buildPageBtn(Icons.chevron_left_rounded, active: false, enabled: true),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPageBtn(IconData? icon, {String? label, required bool active, bool enabled = true}) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: active ? AppColors.primary : AppColors.card,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: active ? AppColors.primary : AppColors.border),
      ),
      child: Center(
        child: icon != null 
          ? Icon(icon, size: 18, color: enabled ? (active ? Colors.white : AppColors.textSecondary) : AppColors.textExtraSecondary)
          : Text(label!, style: TextStyle(color: active ? Colors.white : AppColors.textSecondary, fontWeight: FontWeight.bold, fontSize: 12)),
      ),
    );
  }

  Widget _buildActionBtn(IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, color: color, size: 16),
    );
  }

  Color _getIconColor(String color) {
    switch (color) {
      case 'green': return Colors.green;
      case 'red': return Colors.red;
      case 'blue': return Colors.blue;
      case 'purple': return Colors.purple;
      case 'orange': return Colors.orange;
      default: return AppColors.primary;
    }
  }

  IconData _getIconData(String icon) {
    switch (icon) {
      case 'arrow_downward': return Icons.arrow_downward_rounded;
      case 'arrow_upward': return Icons.arrow_upward_rounded;
      case 'gavel': return Icons.gavel_rounded;
      case 'undo': return Icons.undo_rounded;
      case 'check_circle': return Icons.check_circle_outline_rounded;
      case 'schedule': return Icons.schedule_rounded;
      case 'cancel': return Icons.cancel_outlined;
      default: return Icons.help_outline_rounded;
    }
  }

  Color _getAmountColor(String amount) {
    if (amount.startsWith('+')) return Colors.greenAccent;
    if (amount.startsWith('-')) return Colors.redAccent;
    return AppColors.textPrimary;
  }
}
