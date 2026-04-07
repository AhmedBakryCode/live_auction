import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_table.dart';
import '../providers/wallet_provider.dart';
import '../models/transaction_model.dart';

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
      child: Consumer<WalletProvider>(
        builder: (context, provider, child) {
          if (provider.isLoadingTransactions) {
            return const Padding(
              padding: EdgeInsets.all(50.0),
              child: Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
            );
          }

          final transactions = provider.transactions;

          return Column(
            children: [
              if (transactions.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(50.0),
                  child: Center(
                    child: Text(
                      'لا توجد معاملات حتى الآن',
                      style: TextStyle(fontFamily: 'Cairo', color: AppColors.textSecondary),
                    ),
                  ),
                )
              else
                AppTable(
                  headers: const ['المبلغ', 'النوع', 'الحالة', 'الوصف', 'التاريخ'],
                  rows: transactions.map((t) => _buildRow(t)).toList(),
                ),
              
              if (transactions.isNotEmpty)
                 _buildPagination(transactions.length),
            ],
          );
        },
      ),
    );
  }

  List<Widget> _buildRow(TransactionModel t) {
    final dateFormat = DateFormat('yyyy-MM-dd hh:mm a', 'en');
    
    // Determine colors
    final isIncome = t.type.toLowerCase().contains('in') || t.type.toLowerCase() == 'deposit';
    final amountColor = isIncome ? Colors.greenAccent : AppColors.error;
    
    return [
      Text(
        '${t.amount} ر.س',
        style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, color: amountColor),
      ),
      _buildBadge(
        _getTypeLabel(t.type),
        isIncome ? Colors.green : Colors.orange,
      ),
      _buildBadge(
        _getStatusLabel(t.status),
        _getStatusColor(t.status),
      ),
      Text(
        t.description ?? '-',
        style: const TextStyle(fontFamily: 'Cairo', color: AppColors.textSecondary),
      ),
      Text(
        dateFormat.format(t.createdAt),
        style: const TextStyle(fontFamily: 'Cairo', color: AppColors.textSecondary),
      ),
    ];
  }

  String _getTypeLabel(String type) {
    switch (type.toLowerCase()) {
      case 'transfer_in': case 'deposit': return 'إيداع';
      case 'transfer_out': case 'withdrawal': return 'سحب';
      case 'payment': return 'دفع';
      default: return type;
    }
  }

  String _getStatusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'completed': case 'success': return 'مكتمل';
      case 'pending': return 'قيد الانتظار';
      case 'failed': return 'فشل';
      case 'cancelled': return 'أُلغيت';
      default: return status;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed': case 'success': return Colors.green;
      case 'pending': return Colors.orange;
      case 'failed': case 'cancelled': return AppColors.error;
      default: return AppColors.textSecondary;
    }
  }

  Widget _buildBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.bold,
          fontFamily: 'Cairo',
        ),
      ),
    );
  }

  Widget _buildPagination(int total) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              'عرض آخر معاملات المحفظة (الإجمالي: $total)',
              style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
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

}
