import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../dashboard/widgets/dashboard_header.dart';
import '../widgets/wallet_balance_card.dart';
import '../widgets/wallet_summary_card.dart';
import '../widgets/wallet_filters_section.dart';
import '../widgets/wallet_transactions_table.dart';
import '../../dashboard/widgets/sidebar_widget.dart';

class WalletAdminScreen extends StatelessWidget {
  const WalletAdminScreen({super.key});

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
              _buildPageHeader(),
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
                    childAspectRatio: constraints.maxWidth > 500 ? 1.4 : 1.25,
                    children: const [

                      /////////////////////////////////////////////////


                      WalletBalanceCard(
                        title: 'الرصيد الكلي',
                        amount: '٤٥٬٢٠٠',
                        subtitle: 'الرصيد المتاح',
                        icon: Icons.account_balance_wallet_rounded,
                        isMain: true,
                        trend: '+١٢٪',
                      ),
                      WalletBalanceCard(
                        title: 'إيداعات',
                        amount: '١٢٬٨٠٠',
                        subtitle: '٢٤ معاملة',
                        icon: Icons.arrow_downward_rounded,
                        iconBg: Colors.green,
                        iconColor: Colors.greenAccent,
                        trend: '+٨٪',
                      ),
                      WalletBalanceCard(
                        title: 'سحوبات',
                        amount: '٤٬٢٠٠',
                        subtitle: '١٢ معاملة',
                        icon: Icons.arrow_upward_rounded,
                        iconBg: Colors.red,
                        iconColor: Colors.redAccent,
                        trend: '-٥٪',
                      ),
                      WalletBalanceCard(
                        title: 'معلقة',
                        amount: '١٬٢٥٠',
                        subtitle: 'قيد المراجعة',
                        icon: Icons.schedule_rounded,
                        iconBg: Colors.orange,
                        iconColor: Colors.orangeAccent,
                        trend: '٣',
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
                        value: '٤٥٬٢٠٠',
                        subtitle: 'المتبقي: ٥٤٬٨٠٠',
                        icon: Icons.shield_outlined,
                        color: AppColors.primary,
                        progress: 0.45,
                      ),
                      WalletSummaryCard(
                        title: 'متوسط العمليات',
                        value: '٣٬٢٥٠',
                        subtitle: 'الأعلى: ١٢٬٥٠٠',
                        icon: Icons.bar_chart_rounded,
                        color: Colors.blueAccent,
                      ),
                      WalletSummaryCard(
                        title: 'إحصائيات',
                        value: '١٥٦',
                        subtitle: 'المكتملة: ١٤٢',
                        icon: Icons.pie_chart_outline_rounded,
                        color: Colors.purpleAccent,
                      ),
                      WalletSummaryCard(
                        title: 'النمو',
                        value: '+١٨٫٥٪',
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

  Widget _buildPageHeader() {
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
        _buildHeaderActions(),

      ],
    );
  }

  Widget _buildHeaderActions() {
    return _buildActionBtn(Icons.add_rounded, 'إيداع', isPrimary: true);
  }

  Widget _buildActionBtn(
    IconData icon,
    String label, {
    required bool isPrimary,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isPrimary ? AppColors.primary : AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: isPrimary ? null : Border.all(color: AppColors.border),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {},
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: isPrimary ? Colors.white : AppColors.textSecondary,
                  size: 18,
                ),
               // const SizedBox(width: 8),
                Text(
                  label,
                  style: TextStyle(
                    color: isPrimary ? Colors.white : AppColors.textPrimary,
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
