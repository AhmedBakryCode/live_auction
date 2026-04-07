import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auctions_provider.dart';
import '../widgets/auction_card.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../dashboard/widgets/dashboard_header.dart';
import '../../dashboard/widgets/sidebar_widget.dart';
import '../../../routes/app_routes.dart';

class AuctionsAdminScreen extends StatefulWidget {
  const AuctionsAdminScreen({super.key});

  @override
  State<AuctionsAdminScreen> createState() => _AuctionsAdminScreenState();
}

class _AuctionsAdminScreenState extends State<AuctionsAdminScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) context.read<AuctionsProvider>().loadAuctions();
    });
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 250) {
      context.read<AuctionsProvider>().loadMore();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // ─── Filter Bottom Sheet ──────────────────────────────────────────────────
  void _showFilterSheet(BuildContext context) {
    final provider = context.read<AuctionsProvider>();
    final minCtrl =
        TextEditingController(text: provider.filterMinPrice?.toString() ?? '');
    final maxCtrl =
        TextEditingController(text: provider.filterMaxPrice?.toString() ?? '');
    String? sortBy = provider.filterSortBy;
    String sortDir = provider.filterSortDirection ?? 'asc';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) {
        return StatefulBuilder(builder: (ctx, setSheetState) {
          return Padding(
            padding: EdgeInsets.only(
              left: 24,
              right: 24,
              top: 24,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 32,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    const Icon(Icons.tune_rounded, color: AppColors.primary),
                    const SizedBox(width: 8),
                    Text('فلترة متقدمة', style: AppTextStyles.h2),
                    const Spacer(),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        provider.clearFilter();
                        minCtrl.clear();
                        maxCtrl.clear();
                      },
                      child: const Text('مسح الكل',
                          style: TextStyle(color: AppColors.error)),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Price Range
                Text('نطاق السعر', style: AppTextStyles.caption),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _filterTextField(
                          ctrl: minCtrl,
                          hint: 'أدنى سعر',
                          icon: Icons.arrow_downward_rounded),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _filterTextField(
                          ctrl: maxCtrl,
                          hint: 'أعلى سعر',
                          icon: Icons.arrow_upward_rounded),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Sort by
                Text('الترتيب حسب', style: AppTextStyles.caption),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: {
                    'start_price': 'السعر',
                    'end_time': 'تاريخ الانتهاء',
                    'start_time': 'تاريخ البدء',
                  }.entries.map((e) {
                    final selected = sortBy == e.key;
                    return ChoiceChip(
                      label: Text(e.value),
                      selected: selected,
                      selectedColor: AppColors.primary,
                      backgroundColor: AppColors.card,
                      labelStyle: TextStyle(
                        color: selected ? Colors.black : AppColors.textPrimary,
                        fontFamily: 'Cairo',
                      ),
                      onSelected: (_) =>
                          setSheetState(() => sortBy = selected ? null : e.key),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 12),

                // Sort direction
                if (sortBy != null) ...[
                  Text('نوع الترتيب', style: AppTextStyles.caption),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _dirChip(
                          'تصاعدي', 'asc', sortDir, (v) =>
                              setSheetState(() => sortDir = v)),
                      const SizedBox(width: 8),
                      _dirChip(
                          'تنازلي', 'desc', sortDir, (v) =>
                              setSheetState(() => sortDir = v)),
                    ],
                  ),
                  const SizedBox(height: 12),
                ],

                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () {
                      Navigator.pop(ctx);
                      provider.applyFilter(
                        minPrice: double.tryParse(minCtrl.text),
                        maxPrice: double.tryParse(maxCtrl.text),
                        sortBy: sortBy,
                        sortDirection: sortBy != null ? sortDir : null,
                      );
                    },
                    child: const Text('تطبيق الفلتر',
                        style: TextStyle(
                            color: Colors.black,
                            fontFamily: 'Cairo',
                            fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          );
        });
      },
    );
  }

  Widget _filterTextField(
      {required TextEditingController ctrl,
      required String hint,
      required IconData icon}) {
    return TextField(
      controller: ctrl,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      style: const TextStyle(fontFamily: 'Cairo'),
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, size: 16, color: AppColors.textSecondary),
        filled: true,
        fillColor: AppColors.card,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        border:
            OutlineInputBorder(borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppColors.border)),
        enabledBorder:
            OutlineInputBorder(borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppColors.border)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppColors.primary)),
      ),
    );
  }

  Widget _dirChip(
      String label, String value, String current, Function(String) onTap) {
    final selected = current == value;
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      selectedColor: AppColors.primary,
      backgroundColor: AppColors.card,
      labelStyle: TextStyle(
        color: selected ? Colors.black : AppColors.textPrimary,
        fontFamily: 'Cairo',
      ),
      onSelected: (_) => onTap(value),
    );
  }

  // ─── Build ────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: const Drawer(width: 300, child: SidebarWidget()),
      appBar: const DashboardHeader(),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ──────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('إدارة المزادات',
                          style: AppTextStyles.h1),
                      Text('تحكم في كافة المزادات النشطة والمنتهية',
                          style: AppTextStyles.caption
                              .copyWith(color: AppColors.textSecondary)),
                    ],
                  ),
                  const Spacer(),
                  _AddButton(),
                ],
              ),
            ),

            // ── Search Bar ───────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: _SearchBar(controller: _searchController),
            ),

            // ── Filter Tabs ───────────────────────────────────────────────────
            const SizedBox(height: 12),
            _TabsRow(onFilterTap: () => _showFilterSheet(context)),

            // ── Filter Active Badge ───────────────────────────────────────────
            _FilterBadge(),

            // ── List ─────────────────────────────────────────────────────────
            Expanded(
              child: _AuctionListView(scrollController: _scrollController),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Extracted Widgets
// ─────────────────────────────────────────────────────────────────────────────

class _AddButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () async {
        await Navigator.pushNamed(context, AppRoutes.createAuction);
        if (context.mounted) {
          context.read<AuctionsProvider>().loadAuctions();
        }
      },
      icon: const Icon(Icons.add_rounded, color: Colors.black, size: 18),
      label: const Text('إضافة',
          style: TextStyle(
              color: Colors.black, fontFamily: 'Cairo', fontSize: 13)),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  const _SearchBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AuctionsProvider>();
    return TextField(
      controller: controller,
      onChanged: (q) => context.read<AuctionsProvider>().onSearchChanged(q),
      style: const TextStyle(fontFamily: 'Cairo', fontSize: 14),
      decoration: InputDecoration(
        hintText: 'ابحث بعنوان المزاد...',
        hintStyle:
            const TextStyle(fontFamily: 'Cairo', color: AppColors.textSecondary),
        prefixIcon: const Icon(Icons.search_rounded,
            color: AppColors.textSecondary, size: 20),
        suffixIcon: provider.searchQuery.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear_rounded,
                    color: AppColors.textSecondary, size: 18),
                onPressed: () {
                  controller.clear();
                  context.read<AuctionsProvider>().clearSearch();
                },
              )
            : null,
        filled: true,
        fillColor: AppColors.card,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppColors.border)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppColors.border)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppColors.primary)),
      ),
    );
  }
}

class _TabsRow extends StatelessWidget {
  final VoidCallback onFilterTap;
  const _TabsRow({required this.onFilterTap});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AuctionsProvider>();
    final tabs = AuctionTab.values;

    return SizedBox(
      height: 40,
      child: Row(
        children: [
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              scrollDirection: Axis.horizontal,
              itemCount: tabs.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (_, i) {
                final tab = tabs[i];
                final selected = provider.activeTab == tab &&
                    !provider.isSearching &&
                    !provider.hasActiveFilter;
                return GestureDetector(
                  onTap: () => context.read<AuctionsProvider>().switchTab(tab),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: selected ? AppColors.primary : AppColors.card,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: selected
                            ? AppColors.primary
                            : AppColors.border,
                      ),
                    ),
                    child: Text(
                      tab.label,
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 13,
                        fontWeight: selected
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color:
                            selected ? Colors.black : AppColors.textSecondary,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          // Filter Button
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Consumer<AuctionsProvider>(
              builder: (_, p, _) => Stack(
                clipBehavior: Clip.none,
                children: [
                  GestureDetector(
                    onTap: onFilterTap,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: p.hasActiveFilter
                            ? AppColors.primary
                            : AppColors.card,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Icon(
                        Icons.tune_rounded,
                        size: 20,
                        color: p.hasActiveFilter
                            ? Colors.black
                            : AppColors.textSecondary,
                      ),
                    ),
                  ),
                  if (p.hasActiveFilter)
                    Positioned(
                      top: -4,
                      right: -4,
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          color: Colors.redAccent,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AuctionsProvider>();
    if (!provider.hasActiveFilter && !provider.isSearching) {
      return const SizedBox.shrink();
    }
    final label = provider.isSearching
        ? 'نتائج البحث: "${provider.searchQuery}"'
        : 'فلتر مفعّل';
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.3)),
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.filter_alt_rounded,
                  size: 14, color: AppColors.primary),
              const SizedBox(width: 4),
              Text(label,
                  style: const TextStyle(
                      fontSize: 12,
                      fontFamily: 'Cairo',
                      color: AppColors.primary)),
            ]),
          ),
        ],
      ),
    );
  }
}

class _AuctionListView extends StatelessWidget {
  final ScrollController scrollController;
  const _AuctionListView({required this.scrollController});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AuctionsProvider>();

    // Loading — first page
    if (provider.isLoading && provider.auctions.isEmpty) {
      return const Center(
          child: CircularProgressIndicator(color: AppColors.primary));
    }

    // Error — no data
    if (provider.error != null && provider.auctions.isEmpty) {
      return _ErrorState(
        message: provider.error!,
        onRetry: () => context.read<AuctionsProvider>().loadAuctions(),
      );
    }

    // Empty state
    if (provider.auctions.isEmpty) {
      return _EmptyState(tab: provider.activeTab, isSearching: provider.isSearching);
    }

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () => context.read<AuctionsProvider>().loadAuctions(),
      child: ListView.builder(
        controller: scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
        itemCount: provider.auctions.length + (provider.hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == provider.auctions.length) {
            return const Padding(
              padding: EdgeInsets.all(20),
              child: Center(
                  child: CircularProgressIndicator(color: AppColors.primary)),
            );
          }
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: AuctionCard(
              auction: provider.auctions[index],
              onDeleteSuccess: () =>
                  context.read<AuctionsProvider>().loadAuctions(),
            ),
          );
        },
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.error_outline_rounded,
              color: AppColors.error, size: 52),
          const SizedBox(height: 12),
          Text(message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: AppColors.textSecondary, fontFamily: 'Cairo')),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded, color: Colors.black),
            label: const Text('إعادة المحاولة',
                style: TextStyle(color: Colors.black, fontFamily: 'Cairo')),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ]),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final AuctionTab tab;
  final bool isSearching;
  const _EmptyState({required this.tab, required this.isSearching});

  @override
  Widget build(BuildContext context) {
    final msg = isSearching
        ? 'لا توجد نتائج تطابق بحثك'
        : 'لا توجد مزادات في هذا القسم حالياً';
    return Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(
          isSearching ? Icons.search_off_rounded : Icons.inbox_outlined,
          size: 64,
          color: Colors.grey.withValues(alpha: 0.4),
        ),
        const SizedBox(height: 16),
        Text(msg,
            style: const TextStyle(color: Colors.grey, fontFamily: 'Cairo')),
      ]),
    );
  }
}
