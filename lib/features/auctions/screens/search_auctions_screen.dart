import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../dashboard/widgets/dashboard_header.dart';
import '../../dashboard/widgets/sidebar_widget.dart';
import '../models/auction_model.dart';
import '../repositories/auctions_repository.dart';
import '../widgets/auction_card.dart';

class SearchAuctionsScreen extends StatefulWidget {
  const SearchAuctionsScreen({super.key});

  @override
  State<SearchAuctionsScreen> createState() => _SearchAuctionsScreenState();
}

class _SearchAuctionsScreenState extends State<SearchAuctionsScreen> {
  final AuctionsRepository _repository = AuctionsRepository();
  final List<AuctionModel> _auctions = [];
  
  bool _isLoading = false;
  bool _hasMore = true;
  int _currentPage = 1;
  String _currentQuery = '';

  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
        if (!_isLoading && _hasMore && _currentQuery.isNotEmpty) {
          _fetchSearchResults();
        }
      }
    });
  }

  void _onSearchChanged(String query) {
    setState(() {}); // Update the clear suffix icon 
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 600), () {
      final trimmedQuery = query.trim();
      if (trimmedQuery.isNotEmpty) {
        _currentQuery = trimmedQuery;
        _fetchSearchResults(refresh: true);
      } else {
        setState(() {
          _currentQuery = '';
          _auctions.clear();
          _isLoading = false;
          _hasMore = false;
        });
      }
    });
  }

  Future<void> _fetchSearchResults({bool refresh = false}) async {
    if (refresh) {
      if (!mounted) return;
      setState(() {
        _auctions.clear();
        _currentPage = 1;
        _hasMore = true;
      });
    }

    if (!_hasMore || _currentQuery.isEmpty) return;

    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await _repository.searchAuctions(
        query: _currentQuery,
        page: _currentPage,
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
    _debounce?.cancel();
    _searchController.dispose();
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
            _buildSearchPanel(),
            Expanded(
              child: _currentQuery.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.search_rounded, size: 64, color: Colors.grey.withValues(alpha: 0.3)),
                          const SizedBox(height: 16),
                          const Text(
                            'ابدأ البحث عن المزادات بكتابة اسمها',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      color: AppColors.primary,
                      onRefresh: () => _fetchSearchResults(refresh: true),
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

  Widget _buildSearchPanel() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
      color: AppColors.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('البحث الحر', style: AppTextStyles.h1),
          const SizedBox(height: 16),
          TextField(
            controller: _searchController,
            onChanged: _onSearchChanged,
            style: const TextStyle(fontSize: 15),
            decoration: InputDecoration(
              hintText: 'ابحث بعنوان المزاد...',
              prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textSecondary),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear_rounded, color: AppColors.textSecondary),
                      onPressed: () {
                        _searchController.clear();
                        _onSearchChanged('');
                      },
                    )
                  : null,
              filled: true,
              fillColor: AppColors.card,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.primary),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
