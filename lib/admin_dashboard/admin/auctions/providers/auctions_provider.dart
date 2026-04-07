import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/auction_model.dart';
import '../repositories/auctions_repository.dart';
import '../../../core/utils/app_logger.dart';

enum AuctionTab { all, active, upcoming, closed, paid, reposted }

extension AuctionTabExt on AuctionTab {
  String get label {
    switch (this) {
      case AuctionTab.all:
        return 'الكل';
      case AuctionTab.active:
        return 'نشط';
      case AuctionTab.upcoming:
        return 'قادم';
      case AuctionTab.closed:
        return 'مغلق';
      case AuctionTab.paid:
        return 'مدفوع';
      case AuctionTab.reposted:
        return 'معاد نشره';
    }
  }
}

class AuctionsProvider extends ChangeNotifier {
  final AuctionsRepository _repository = AuctionsRepository();

  // ─── Tab State ────────────────────────────────────────────────────────────
  AuctionTab _activeTab = AuctionTab.all;
  AuctionTab get activeTab => _activeTab;

  // ─── Auction List State ────────────────────────────────────────────────────
  List<AuctionModel> _auctions = [];
  List<AuctionModel> get auctions => _auctions;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _hasMore = true;
  bool get hasMore => _hasMore;

  int _currentPage = 1;

  String? _error;
  String? get error => _error;

  // ─── Search State ─────────────────────────────────────────────────────────
  bool _isSearching = false;
  bool get isSearching => _isSearching;

  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  Timer? _debounce;

  // ─── Filter State ─────────────────────────────────────────────────────────
  double? filterMinPrice;
  double? filterMaxPrice;
  String? filterStartTime;
  String? filterEndTime;
  String? filterSortBy;
  String? filterSortDirection;
  bool get hasActiveFilter =>
      filterMinPrice != null ||
      filterMaxPrice != null ||
      filterStartTime != null ||
      filterEndTime != null ||
      filterSortBy != null;

  // ─── Tab Switch ───────────────────────────────────────────────────────────
  Future<void> switchTab(AuctionTab tab) async {
    if (_activeTab == tab && _auctions.isNotEmpty) return;
    _activeTab = tab;
    _isSearching = false;
    _searchQuery = '';
    _clearFilterParams();
    await _reload();
  }

  // ─── Load / Reload ────────────────────────────────────────────────────────
  Future<void> loadAuctions() async => _reload();

  Future<void> _reload() async {
    _auctions = [];
    _currentPage = 1;
    _hasMore = true;
    _error = null;
    notifyListeners();
    await _fetchNextPage();
  }

  Future<void> loadMore() async {
    if (_isLoading || !_hasMore) return;
    await _fetchNextPage();
  }

  Future<void> _fetchNextPage() async {
    _isLoading = true;
    notifyListeners();

    try {
      if (_isSearching && _searchQuery.isNotEmpty) {
        final res = await _repository.searchAuctions(
            query: _searchQuery, page: _currentPage);
        _auctions.addAll(res.auctions);
        _hasMore = res.nextPageUrl != null;
        if (_hasMore) _currentPage++;
      } else if (hasActiveFilter) {
        final res = await _repository.fetchFilteredAuctions(
          page: _currentPage,
          minPrice: filterMinPrice,
          maxPrice: filterMaxPrice,
          startTime: filterStartTime,
          endTime: filterEndTime,
          sortBy: filterSortBy,
          sortDirection: filterSortDirection,
        );
        _auctions.addAll(res.auctions);
        _hasMore = res.nextPageUrl != null;
        if (_hasMore) _currentPage++;
      } else {
        switch (_activeTab) {
          case AuctionTab.all:
            // All auctions is not paginated; fetch entire list once
            final list = await _repository.fetchAuctions();
            _auctions = list;
            _hasMore = false;
            break;
          case AuctionTab.active:
            final res =
                await _repository.fetchActiveAuctions(page: _currentPage);
            _auctions.addAll(res.auctions);
            _hasMore = res.nextPageUrl != null;
            if (_hasMore) _currentPage++;
            break;
          case AuctionTab.upcoming:
            final res =
                await _repository.fetchUpcomingAuctions(page: _currentPage);
            _auctions.addAll(res.auctions);
            _hasMore = res.nextPageUrl != null;
            if (_hasMore) _currentPage++;
            break;
          case AuctionTab.closed:
            final res =
                await _repository.fetchClosedAuctions(page: _currentPage);
            _auctions.addAll(res.auctions);
            _hasMore = res.nextPageUrl != null;
            if (_hasMore) _currentPage++;
            break;
          case AuctionTab.paid:
            final res =
                await _repository.fetchPaidAuctions(page: _currentPage);
            _auctions.addAll(res.auctions);
            _hasMore = res.nextPageUrl != null;
            if (_hasMore) _currentPage++;
            break;
          case AuctionTab.reposted:
            final res =
                await _repository.fetchRepostedAuctions(page: _currentPage);
            _auctions.addAll(res.auctions);
            _hasMore = res.nextPageUrl != null;
            if (_hasMore) _currentPage++;
            break;
        }
      }
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      AppLogger.error('AuctionsProvider', 'Failed to load: $_error');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ─── Search ───────────────────────────────────────────────────────────────
  void onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 600), () {
      final trimmed = query.trim();
      if (trimmed == _searchQuery) return;
      _searchQuery = trimmed;
      _isSearching = trimmed.isNotEmpty;
      _reload();
    });
    // Immediate UI update for clear icon
    notifyListeners();
  }

  void clearSearch() {
    _debounce?.cancel();
    _searchQuery = '';
    _isSearching = false;
    _reload();
  }

  // ─── Filter ───────────────────────────────────────────────────────────────
  Future<void> applyFilter({
    double? minPrice,
    double? maxPrice,
    String? startTime,
    String? endTime,
    String? sortBy,
    String? sortDirection,
  }) async {
    filterMinPrice = minPrice;
    filterMaxPrice = maxPrice;
    filterStartTime = startTime;
    filterEndTime = endTime;
    filterSortBy = sortBy;
    filterSortDirection = sortDirection;
    _isSearching = false;
    _searchQuery = '';
    await _reload();
  }

  void clearFilter() {
    _clearFilterParams();
    _reload();
  }

  void _clearFilterParams() {
    filterMinPrice = null;
    filterMaxPrice = null;
    filterStartTime = null;
    filterEndTime = null;
    filterSortBy = null;
    filterSortDirection = null;
  }

  // ─── Delete ───────────────────────────────────────────────────────────────
  Future<bool> deleteAuction(int id) async {
    try {
      await _repository.deleteAuction(id);
      _auctions.removeWhere((a) => a.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      AppLogger.error('AuctionsProvider', 'Failed to delete: $_error');
      notifyListeners();
      return false;
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}
