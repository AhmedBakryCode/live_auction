import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/price_widget.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../bloc/wallet_bloc.dart';

class WalletPage extends StatelessWidget {
  const WalletPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: context.read<WalletBloc>()..add(LoadWallet()),
      child: Scaffold(
        appBar: AppBar(title: const Text('محفظتي')),
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
              return RefreshIndicator(
                onRefresh: () async => context.read<WalletBloc>().add(LoadWallet()),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    children: [
                      _buildBalanceCard(state.balance),
                      _buildActionButtons(),
                      _buildTransactionHeader(),
                      _buildTransactionList(state.transactions),
                    ],
                  ),
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildBalanceCard(double balance) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryVariant],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'إجمالي الرصيد',
            style: AppTextStyles.bodyMedium.copyWith(color: Colors.white.withOpacity(0.8)),
          ),
          const SizedBox(height: 8),
          PriceWidget(
            price: balance,
            style: AppTextStyles.heading1.copyWith(color: Colors.white, fontSize: 32),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _buildMinicardInfo('الدخل', '+1200 ج.م'),
              const SizedBox(width: 24),
              _buildMinicardInfo('المصروفات', '-450 ج.م'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMinicardInfo(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
        Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          Expanded(
            child: PrimaryButton(
              text: 'شحن رصيد',
              onPressed: () {},
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 20),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                side: const BorderSide(color: AppColors.primary),
              ),
              child: const Text('سحب أموال', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 32, 16, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('آخر العمليات', style: AppTextStyles.heading3),
          TextButton(onPressed: () {}, child: const Text('عرض الكل')),
        ],
      ),
    );
  }

  Widget _buildTransactionList(List<Map<String, dynamic>> transactions) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: transactions.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final tx = transactions[index];
        final isNegative = tx['amount'] < 0;

        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.light ? Colors.white : AppColors.darkSurface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.getContainerColor(context)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _getTransactionColor(tx['type']).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(_getTransactionIcon(tx['type']), color: _getTransactionColor(tx['type']), size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(tx['title'], style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold)),
                    Text(tx['date'], style: AppTextStyles.caption),
                  ],
                ),
              ),
              Text(
                '${isNegative ? "" : "+"}${tx['amount']}',
                style: AppTextStyles.bodyLarge.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isNegative ? Colors.red : AppColors.priceGreen,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  IconData _getTransactionIcon(String type) {
    switch (type) {
      case 'Bid': return Icons.gavel;
      case 'Deposit': return Icons.add_circle_outline;
      case 'Refund': return Icons.refresh;
      default: return Icons.money;
    }
  }

  Color _getTransactionColor(String type) {
    switch (type) {
      case 'Bid': return Colors.orange;
      case 'Deposit': return AppColors.priceGreen;
      case 'Refund': return AppColors.primary;
      default: return Colors.grey;
    }
  }
}
