import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../dashboard/widgets/dashboard_header.dart';
import '../providers/wallet_provider.dart';
import '../widgets/wallet_balance_card.dart';
import '../widgets/wallet_summary_card.dart';
import '../widgets/wallet_filters_section.dart';
import '../widgets/wallet_transactions_table.dart';
import '../../dashboard/widgets/sidebar_widget.dart';
import 'deposit_screen.dart';

class WalletAdminScreen extends StatefulWidget {
  const WalletAdminScreen({super.key});

  @override
  State<WalletAdminScreen> createState() => _WalletAdminScreenState();
}

class _WalletAdminScreenState extends State<WalletAdminScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) {
        context.read<WalletProvider>().fetchWalletDetails();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: const Drawer(width: 300, child: SidebarWidget()),
      appBar: const DashboardHeader(),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Page Header with Title and Quick Actions
              _buildPageHeader(context),
              const SizedBox(height: 16),
              // 2. Main Balance Cards Grid
              LayoutBuilder(
                builder: (context, constraints) {
                  return GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: constraints.maxWidth > 800
                        ? 4
                        : (constraints.maxWidth > 500 ? 2 : 2),
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    childAspectRatio: constraints.maxWidth > 500 ? 1.4 : 1.05,
                    children: [

                      /////////////////////////////////////////////////

                      Consumer<WalletProvider>(
                        builder: (context, provider, child) {
                          if (provider.isLoading) {
                            return const WalletBalanceCard(
                              title: 'الرصيد الكلي',
                              amount: '...',
                              subtitle: 'جاري التحميل...',
                              icon: Icons.account_balance_wallet_rounded,
                              isMain: true,
                              trend: '',
                            );
                          }
                          
                          if (provider.errorMessage != null) {
                            return WalletBalanceCard(
                              title: 'الرصيد الكلي',
                              amount: 'Error',
                              subtitle: provider.errorMessage!,
                              icon: Icons.error_outline_rounded,
                              isMain: true,
                              trend: '',
                            );
                          }

                          return WalletBalanceCard(
                            title: 'الرصيد الكلي',
                            amount: provider.wallet?.balance ?? '0.00',
                            subtitle: 'الرصيد المتاح',
                            icon: Icons.account_balance_wallet_rounded,
                            isMain: true,
                            trend: '',
                          );
                        },
                      ),

                      const WalletBalanceCard(
                        title: 'إيداعات',
                        amount: '0.00',
                        subtitle: '0 معاملة',
                        icon: Icons.arrow_downward_rounded,
                        iconBg: Colors.green,
                        iconColor: Colors.greenAccent,
                        trend: '',
                      ),
                      const WalletBalanceCard(
                        title: 'سحوبات',
                        amount: '0.00',
                        subtitle: '0 معاملة',
                        icon: Icons.arrow_upward_rounded,
                        iconBg: Colors.red,
                        iconColor: Colors.redAccent,
                        trend: '',
                      ),
                      const WalletBalanceCard(
                        title: 'معلقة',
                        amount: '0.00',
                        subtitle: '0 معاملة',
                        icon: Icons.schedule_rounded,
                        iconBg: Colors.orange,
                        iconColor: Colors.orangeAccent,
                        trend: '',
                      ),
                    ],
                  );
                },
              ),

              const SizedBox(height: 12),

              // 3. Additional Summary Cards
              LayoutBuilder(
                builder: (context, constraints) {
                  return GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: constraints.maxWidth > 800
                        ? 4
                        : (constraints.maxWidth > 500 ? 2 : 2),
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                    childAspectRatio: constraints.maxWidth > 500 ? 2.2 : 1.35,
                    children: const [
                      WalletSummaryCard(
                        title: 'حد المحفظة',
                        value: '0',
                        subtitle: 'المتبقي: 0',
                        icon: Icons.shield_outlined,
                        color: AppColors.primary,
                        progress: 0.0,
                      ),
                      WalletSummaryCard(
                        title: 'متوسط العمليات',
                        value: '0',
                        subtitle: 'الأعلى: 0',
                        icon: Icons.bar_chart_rounded,
                        color: Colors.blueAccent,
                      ),
                      WalletSummaryCard(
                        title: 'إحصائيات',
                        value: '0',
                        subtitle: 'المكتملة: 0',
                        icon: Icons.pie_chart_outline_rounded,
                        color: Colors.purpleAccent,
                      ),
                      WalletSummaryCard(
                        title: 'النمو',
                        value: '0٪',
                        subtitle: 'شهري',
                        icon: Icons.show_chart_rounded,
                        color: Colors.greenAccent,
                      ),
                    ],
                  );
                },
              ),

              const SizedBox(height: 20),
              // 4. Filters Section
              const WalletFiltersSection(),
              const SizedBox(height: 12),
              // 5. Transactions Table
              const WalletTransactionsTable(),
              const SizedBox(height: 20),
              // 6. Bottom Summary Grid
              _buildBottomSummaryGrid(),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPageHeader(BuildContext context) {
    return Row(
      children: [
        Container(
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(
            Icons.account_balance_wallet_rounded,
            color: AppColors.primary,
            size: 28,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('المحفظة', style: AppTextStyles.h1.copyWith(fontSize: 24)),
              Text(
                'إدارة الرصيد والمعاملات المالية وكشف الحساب',
                style: AppTextStyles.body2.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12,height: 16,),
        _buildHeaderActions(context),

      ],
    );
  }

  Widget _buildHeaderActions(BuildContext context) {
    return Consumer<WalletProvider>(
      builder: (context, provider, child) {
        final hasWallet = provider.wallet != null;
        
        return Row(
          children: [
            if (hasWallet) ...[
              _buildActionBtn(
                Icons.delete_outline_rounded,
                'حذف المحفظة',
                isPrimary: false,
                color: AppColors.error,
                onTap: () => _confirmDelete(context),
              ),
              const SizedBox(width: 8),
            ],
            Opacity(
              opacity: hasWallet ? 1.0 : 0.5,
              child: _buildActionBtn(
                Icons.add_rounded,
                'إيداع',
                isPrimary: true,
                onTap: hasWallet ? () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const DepositScreen()),
                  );
                } : null,
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final provider = context.read<WalletProvider>();
    if (provider.isLoading || provider.wallet == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.card,
        title: const Text('حذف المحفظة', style: TextStyle(fontFamily: 'Cairo', color: AppColors.error)),
        content: const Text('هل أنت متأكد من حذف هذه المحفظة بشكل نهائي؟', style: TextStyle(fontFamily: 'Cairo')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء', style: TextStyle(fontFamily: 'Cairo', color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('تأكيد الحذف', style: TextStyle(fontFamily: 'Cairo', color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      final success = await provider.deleteWallet();
      if (!context.mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم الحذف بنجاح', style: TextStyle(fontFamily: 'Cairo')),
            backgroundColor: AppColors.success,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.errorMessage ?? 'حدث خطأ غير متوقع', style: const TextStyle(fontFamily: 'Cairo')),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Widget _buildActionBtn(
    IconData icon,
    String label, {
    required bool isPrimary,
    Color? color,
    VoidCallback? onTap,
  }) {
    final actionColor = color ?? (isPrimary ? Colors.white : AppColors.textPrimary);
    
    return Container(
      decoration: BoxDecoration(
        color: isPrimary ? AppColors.primary : AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: isPrimary ? null : Border.all(color: color ?? AppColors.border),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: isPrimary ? Colors.white : actionColor,
                  size: 18,
                ),
                Text(
                  label,
                  style: TextStyle(
                    color: actionColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomSummaryGrid() {
    final summaries = [
      {
        'title': 'إجمالي الإيداعات',
        'value': '١٢٬٨٠٠',
        'count': '٢٤ معاملة',
        'icon': Icons.arrow_downward,
        'color': Colors.green,
      },
      {
        'title': 'إجمالي السحوبات',
        'value': '٤٬٢٠٠',
        'count': '١٢ معاملة',
        'icon': Icons.arrow_upward,
        'color': Colors.red,
      },
      {
        'title': 'مدفوعات المزادات',
        'value': '٢٨٬٥٠٠',
        'count': '٤٥ معاملة',
        'icon': Icons.gavel_rounded,
        'color': Colors.blue,
      },
      {
        'title': 'إجمالي الاستردادات',
        'value': '٣٬٢٠٠',
        'count': '٨ معاملات',
        'icon': Icons.history_rounded,
        'color': Colors.purple,
      },
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: constraints.maxWidth > 800
                ? 4
                : (constraints.maxWidth > 600 ? 2 : 2),
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: constraints.maxWidth > 800
                ? 2.5
                : (constraints.maxWidth > 600 ? 2.2 : 1.7),
          ),
          itemCount: summaries.length,
          itemBuilder: (context, index) {
            final item = summaries[index];
            final Color color = item['color'] as Color;
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      item['icon'] as IconData,
                      color: color,
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          item['title'] as String,
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.textSecondary,
                            fontSize: 10,
                          ),
                        ),
                        Text(
                          item['value'] as String,
                          style: AppTextStyles.h2.copyWith(
                            fontSize: 15,
                            color: color,
                          ),
                        ),
                        Text(
                          item['count'] as String,
                          style: AppTextStyles.caption.copyWith(fontSize: 9),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
