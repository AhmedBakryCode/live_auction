import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/services/socket_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/price_widget.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../domain/entities/wallet.dart';
import '../bloc/wallet_bloc.dart';
import 'paymob_iframe_screen.dart';
import 'payment_result_screen.dart';

class WalletPage extends StatefulWidget {
  const WalletPage({super.key});

  @override
  State<WalletPage> createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage> {
  @override
  void initState() {
    super.initState();
    // Listen for payment confirmation from socket
    final socketService = context.read<SocketService>();
    socketService.onPaymentConfirmed((data) {
      // Refresh wallet when payment is confirmed via webhook
      context.read<WalletBloc>().add(LoadWallet());
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم تأكيد الدفع وتحديث الرصيد!'),
          backgroundColor: Colors.green,
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<WalletBloc, WalletState>(
      listener: (context, state) async {
        if (state is DepositSuccess) {
          final depositResponse = state.depositResponse;
          String? paymentUrl = depositResponse.url;

          // Determine integration ID from payment method
          final integrationId =
              state.paymentMethod == 'wallet'
                  ? ApiConstants.paymobWalletIntegrationId
                  : ApiConstants.paymobCardIntegrationId;

          // If backend provides SDK credentials but no URL, construct iframe URL
          if (paymentUrl == null &&
              depositResponse.apiKey != null &&
              depositResponse.iframeId != null) {
            paymentUrl =
                'https://accept.paymob.com/api/acceptance/iframes/${depositResponse.iframeId}';
          }

          // Render Paymob in an iframe to avoid owner error
          if (paymentUrl != null) {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PaymobIframeScreen(
                  paymentUrl: paymentUrl!,
                  integrationId: integrationId,
                ),
              ),
            );
            // After browser closes or deep link returns, refresh wallet
            if (result == true) {
              context.read<WalletBloc>().add(LoadWallet());
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PaymentSuccessScreen(onContinue: () {}),
                ),
              );
            } else if (result == false) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PaymentFailedScreen(
                    onContinue: () {},
                    onRetry: () => _showDepositDialog(context),
                  ),
                ),
              );
            }
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('خطأ: لا يوجد رابط للدفع'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      },
      child: BlocProvider.value(
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
                  onRefresh: () async =>
                      context.read<WalletBloc>().add(LoadWallet()),
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Column(
                      children: [
                        _buildBalanceCard(state.wallet.balance),
                        _buildActionButtons(context),
                        _buildTransactionHeader(),
                        _buildTransactionList(state.transactions),
                      ],
                    ),
                  ),
                );
              } else if (state is DepositLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is DepositError) {
                return ErrorView(message: state.message, onRetry: () {});
              }
              return const SizedBox.shrink();
            },
          ),
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
            style: AppTextStyles.bodyMedium.copyWith(
              color: Colors.white.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 8),
          PriceWidget(
            price: balance,
            style: AppTextStyles.heading1.copyWith(
              color: Colors.white,
              fontSize: 32,
            ),
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
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          Expanded(
            child: PrimaryButton(
              text: 'شحن رصيد',
              onPressed: () => _showDepositDialog(context),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                side: const BorderSide(color: AppColors.primary),
              ),
              child: const Text(
                'سحب أموال',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
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

  Widget _buildTransactionList(List<WalletTransaction> transactions) {
    if (transactions.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(32),
        child: Center(child: Text('لا توجد معاملات حتى الآن')),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: transactions.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final tx = transactions[index];
        final isNegative = tx.isWithdrawal;
        final dateFormat = DateFormat('yyyy-MM-dd HH:mm');

        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.light
                ? Colors.white
                : AppColors.darkSurface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.getContainerColor(context)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _getTransactionColor(tx.type).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _getTransactionIcon(tx.type),
                  color: _getTransactionColor(tx.type),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tx.description,
                      style: AppTextStyles.bodyLarge.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      dateFormat.format(tx.createdAt),
                      style: AppTextStyles.caption,
                    ),
                  ],
                ),
              ),
              Text(
                '${isNegative ? "-" : "+"}${tx.amount.toStringAsFixed(2)}',
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
    switch (type.toLowerCase()) {
      case 'deposit':
        return Icons.add_circle_outline;
      case 'withdrawal':
        return Icons.remove_circle_outline;
      case 'bid':
        return Icons.gavel;
      case 'refund':
        return Icons.refresh;
      default:
        return Icons.money;
    }
  }

  Color _getTransactionColor(String type) {
    switch (type.toLowerCase()) {
      case 'deposit':
        return AppColors.priceGreen;
      case 'withdrawal':
        return Colors.red;
      case 'bid':
        return Colors.orange;
      case 'refund':
        return AppColors.primary;
      default:
        return Colors.grey;
    }
  }

  void _showDepositDialog(BuildContext context) {
    final amountController = TextEditingController();
    String selectedMethod = 'card';

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('شحن رصيد'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: amountController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'المبلغ',
                      prefixText: 'ج.م ',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text('طريقة الدفع:'),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: ChoiceChip(
                          label: const Text('بطاقة'),
                          selected: selectedMethod == 'card',
                          onSelected: (selected) {
                            setState(() => selectedMethod = 'card');
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ChoiceChip(
                          label: const Text('محفظة'),
                          selected: selectedMethod == 'wallet',
                          onSelected: (selected) {
                            setState(() => selectedMethod = 'wallet');
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('إلغاء'),
                ),
                ElevatedButton(
                  onPressed: () {
                    final amount = double.tryParse(amountController.text);
                    if (amount != null && amount > 0) {
                      Navigator.pop(dialogContext);
                      // Trigger deposit event - credentials will come from API response
                      context.read<WalletBloc>().add(
                        Deposit(amount: amount, paymentMethod: selectedMethod),
                      );
                    }
                  },
                  child: const Text('شحن'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
