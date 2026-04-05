import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../dashboard/widgets/dashboard_header.dart';
import '../../dashboard/widgets/sidebar_widget.dart';
import '../models/auction_model.dart';
import '../repositories/auctions_repository.dart';
import '../widgets/auction_card.dart';

class ActiveAuctionsScreen extends StatefulWidget {
  const ActiveAuctionsScreen({super.key});

  @override
  State<ActiveAuctionsScreen> createState() => _ActiveAuctionsScreenState();
}

class _ActiveAuctionsScreenState extends State<ActiveAuctionsScreen> {
  final AuctionsRepository _repository = AuctionsRepository();
  final List<AuctionModel> _auctions = [];
  bool _isLoading = false;
  bool _hasMore = true;
  int _currentPage = 1;

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _fetchActiveAuctions();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
        if (!_isLoading && _hasMore) {
          _fetchActiveAuctions();
        }
      }
    });
  }

  Future<void> _fetchActiveAuctions() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await _repository.fetchActiveAuctions(page: _currentPage);
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
              child: Text(
                'المزادات النشطة',
                style: AppTextStyles.h1,
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                color: AppColors.primary,
                onRefresh: () async {
                  setState(() {
                    _auctions.clear();
                    _currentPage = 1;
                    _hasMore = true;
                  });
                  await _fetchActiveAuctions();
                },
                child: _auctions.isEmpty && !_isLoading
                    ? const Center(
                        child: Text(
                          'لا توجد مزادات نشطة حالياً.',
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 20),
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
}
