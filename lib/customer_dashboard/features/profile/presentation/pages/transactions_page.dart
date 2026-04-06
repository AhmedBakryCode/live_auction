import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../../wallet/domain/entities/wallet.dart';
import '../../../wallet/presentation/bloc/wallet_bloc.dart';

class TransactionsPage extends StatelessWidget {
  const TransactionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: context.read<WalletBloc>()..add(LoadWallet()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('مشترياتي'),
        ),
        body: BlocBuilder<WalletBloc, WalletState>(
          builder: (context, state) {
            if (state is WalletLoading) {
              return const LoadingIndicator();
            } else if (state is WalletError) {
              return ErrorView(
                message: state.message,
                onRetry: () => context.read<WalletBloc>().add(LoadWallet()),
              );
            } else if (state is WalletLoaded) {
              return _buildTransactionsList(state.transactions);
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildTransactionsList(List<WalletTransaction> transactions) {
    if (transactions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 64,
              color: AppColors.textSecondary.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'لا توجد معاملات حالياً',
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: transactions.length,
      separatorBuilder: (_, __) => const Divider(),
      itemBuilder: (context, index) {
        final transaction = transactions[index];
        return _buildTransactionItem(context, transaction);
      },
    );
  }

  Widget _buildTransactionItem(BuildContext context, WalletTransaction transaction) {
    final isPositive = transaction.type == 'deposit' || transaction.type == 'refund';
    final isAuctionPayment = transaction.type == 'auction_payment' || transaction.type == 'bid';
    
    IconData icon;
    Color color;
    String typeLabel;
    
    switch (transaction.type) {
      case 'deposit':
        icon = Icons.add_circle_outline;
        color = Colors.green;
        typeLabel = 'إيداع';
        break;
      case 'withdrawal':
        icon = Icons.remove_circle_outline;
        color = Colors.red;
        typeLabel = 'سحب';
        break;
      case 'auction_payment':
      case 'bid':
        icon = Icons.gavel;
        color = AppColors.primary;
        typeLabel = 'دفع مزاد';
        break;
      case 'refund':
        icon = Icons.replay;
        color = Colors.blue;
        typeLabel = 'استرداد';
        break;
      default:
        icon = Icons.receipt;
        color = AppColors.textSecondary;
        typeLabel = transaction.type;
    }

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Theme.of(context).dividerColor.withOpacity(0.1)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    typeLabel,
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatDate(transaction.createdAt),
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  if (transaction.description != null && transaction.description!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        transaction.description!,
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Text(
              '${isPositive ? '+' : '-'} ${transaction.amount.toStringAsFixed(2)} ر.س',
              style: AppTextStyles.bodyLarge.copyWith(
                color: isPositive ? Colors.green : (isAuctionPayment ? AppColors.primary : Colors.red),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy - hh:mm a', 'ar').format(date);
  }
}
