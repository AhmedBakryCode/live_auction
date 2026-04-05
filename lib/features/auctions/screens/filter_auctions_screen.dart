import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../dashboard/widgets/dashboard_header.dart';
import '../../dashboard/widgets/sidebar_widget.dart';
import '../models/auction_model.dart';
import '../repositories/auctions_repository.dart';
import '../widgets/auction_card.dart';

class FilterAuctionsScreen extends StatefulWidget {
  const FilterAuctionsScreen({super.key});

  @override
  State<FilterAuctionsScreen> createState() => _FilterAuctionsScreenState();
}

class _FilterAuctionsScreenState extends State<FilterAuctionsScreen> {
  final AuctionsRepository _repository = AuctionsRepository();
  final List<AuctionModel> _auctions = [];
  
  bool _isLoading = false;
  bool _hasMore = true;
  int _currentPage = 1;

  // Filter state
  String? _selectedStatus;
  String? _selectedSortBy;
  String _selectedSortDirection = 'asc';
  
  final ScrollController _scrollController = ScrollController();

  final Map<String, String> _statusOptions = {
    '': 'الكل',
    'active': 'نشط',
    'closed': 'مغلق',
    'upcoming': 'قادم',
  };

  final Map<String, String> _sortByOptions = {
    '': 'بدون ترتيب',
    'start_price': 'السعر المبدئي',
    'end_time': 'تاريخ الانتهاء',
  };

  @override
  void initState() {
    super.initState();
    _fetchAuctions(refresh: true);
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
        if (!_isLoading && _hasMore) {
          _fetchAuctions();
        }
      }
    });
  }

  Future<void> _fetchAuctions({bool refresh = false}) async {
    if (refresh) {
      if (!mounted) return;
      setState(() {
        _auctions.clear();
        _currentPage = 1;
        _hasMore = true;
      });
    }

    if (!_hasMore) return;

    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await _repository.fetchFilteredAuctions(
        page: _currentPage,
        status: _selectedStatus == '' ? null : _selectedStatus,
        sortBy: _selectedSortBy == '' ? null : _selectedSortBy,
        sortDirection: _selectedSortBy == '' ? null : _selectedSortDirection,
      );

      if (!mounted) return;
      setState(() {
        _auctions.addAll(response.auctions);
        if (response.nextPageUrl != null) {
          _currentPage++;
        } else {
          _hasMore = false;
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: const Drawer(
        width: 300,
        child: SidebarWidget(),
      ),
      appBar: const DashboardHeader(),
      body: SafeArea(
        child: Column(
          children: [
            _buildFiltersPanel(),
            Expanded(
              child: RefreshIndicator(
                color: AppColors.primary,
                onRefresh: () => _fetchAuctions(refresh: true),
                child: _auctions.isEmpty && !_isLoading
                    ? const Center(
                        child: Text(
                          'لا توجد نتائج تطابق بحثك حالياً.',
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        itemCount: _auctions.length + (_hasMore ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index == _auctions.length) {
                            return const Padding(
                              padding: EdgeInsets.all(20),
                              child: Center(
                                child: CircularProgressIndicator(color: AppColors.primary),
                              ),
                            );
                          }
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: AuctionCard(
                              auction: _auctions[index],
                              onDeleteSuccess: () {
                                setState(() {
                                  _auctions.removeAt(index);
                                });
                              },
                            ),
                          );
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFiltersPanel() {
    return Container(
      padding: const EdgeInsets.all(20),
      color: AppColors.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.tune_rounded, color: AppColors.primary),
              const SizedBox(width: 8),
              Text('تصفية وبحث متقدم', style: AppTextStyles.h2),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildDropdown(
                  label: 'الحالة',
                  value: _selectedStatus,
                  items: _statusOptions,
                  onChanged: (val) {
                    setState(() => _selectedStatus = val);
                    _fetchAuctions(refresh: true);
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildDropdown(
                  label: 'الترتيب حسب',
                  value: _selectedSortBy,
                  items: _sortByOptions,
                  onChanged: (val) {
                    setState(() => _selectedSortBy = val);
                    _fetchAuctions(refresh: true);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (_selectedSortBy != null && _selectedSortBy!.isNotEmpty)
            Row(
              children: [
                Expanded(
                  child: _buildDropdown(
                    label: 'نوع الترتيب',
                    value: _selectedSortDirection,
                    items: const {'asc': 'تصاعدي', 'desc': 'تنازلي'},
                    onChanged: (val) {
                      setState(() => _selectedSortDirection = val ?? 'asc');
                      _fetchAuctions(refresh: true);
                    },
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String? value,
    required Map<String, String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
        const SizedBox(height: 4),
        Container(
           height: 45,
           padding: const EdgeInsets.symmetric(horizontal: 12),
           decoration: BoxDecoration(
             color: AppColors.card,
             borderRadius: BorderRadius.circular(8),
             border: Border.all(color: AppColors.border),
           ),
           child: DropdownButtonHideUnderline(
             child: DropdownButton<String>(
               value: value ?? '',
               isExpanded: true,
               dropdownColor: AppColors.card,
               icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textSecondary),
               items: items.entries.map((entry) {
                 return DropdownMenuItem<String>(
                   value: entry.key,
                   child: Text(entry.value, style: const TextStyle(fontSize: 14)),
                 );
               }).toList(),
               onChanged: onChanged,
             ),
           ),
        ),
      ],
    );
  }
}
