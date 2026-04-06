import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';

import '../../../../core/widgets/auction_card.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../bloc/auction_bloc.dart';

class AllAuctionsPage extends StatefulWidget {
  const AllAuctionsPage({super.key});

  @override
  State<AllAuctionsPage> createState() => _AllAuctionsPageState();
}

class _AllAuctionsPageState extends State<AllAuctionsPage> {
  bool isGridView = true;
  String selectedFilter = 'الكل';
  final List<String> filters = [
    'الكل',
    'مباشر',
    'قريب جداً',
    'ساعات',
    'مجوهرات',
    'سيارات',
  ];

  @override
  void initState() {
    super.initState();
    // Load auctions only once when page opens
    context.read<AuctionBloc>().add(LoadActiveAuctions());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('المزادات'),
        actions: [
          IconButton(
            icon: Icon(
              isGridView ? Icons.view_list_rounded : Icons.grid_view_rounded,
            ),
            onPressed: () => setState(() => isGridView = !isGridView),
          ),
        ],
      ),
        body: Column(
          children: [
            _buildFilterTabs(),
            Expanded(
              child: BlocBuilder<AuctionBloc, AuctionState>(
                builder: (context, state) {
                  if (state is AuctionLoading) {
                    return const LoadingIndicator();
                  } else if (state is AuctionError) {
                    return ErrorView(
                      message: state.message,
                      onRetry: () =>
                          context.read<AuctionBloc>().add(LoadActiveAuctions()),
                    );
                  } else if (state is AuctionsLoaded) {
                    if (state.activeAuctions.isEmpty) {
                      return const Center(
                        child: Text('لا يوجد مزادات متاحة حالياً.'),
                      );
                    }
                    return RefreshIndicator(
                      onRefresh: () async =>
                          context.read<AuctionBloc>().add(LoadActiveAuctions()),
                      child: isGridView
                          ? _buildGridView(state.activeAuctions)
                          : _buildListView(state.activeAuctions),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      );
  }

  Widget _buildFilterTabs() {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final isSelected = selectedFilter == filters[index];
          return ChoiceChip(
            label: Text(filters[index]),
            selected: isSelected,
            onSelected: (val) =>
                setState(() => selectedFilter = filters[index]),
            selectedColor: AppColors.primary,
            labelStyle: TextStyle(
              color: isSelected
                  ? Colors.white
                  : AppColors.getPrimaryText(context),
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          );
        },
      ),
    );
  }

  Widget _buildGridView(List auctions) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.55,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: auctions.length,
      itemBuilder: (context, index) {
        final auction = auctions[index];
        return AuctionCard(
          title: auction.title,
          imageUrl: auction.image ?? '',
          currentBid: auction.currentPrice,
          endTime: auction.endTime,
          totalBids: 0,
          onTap: () => Navigator.pushNamed(
            context,
            '/auction-details',
            arguments: auction,
          ),
        );
      },
    );
  }

  Widget _buildListView(List auctions) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: auctions.length,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final auction = auctions[index];
        return AuctionCard(
          title: auction.title,
          imageUrl: auction.image ?? '',
          currentBid: auction.currentPrice,
          endTime: auction.endTime,
          totalBids: 0,
          onTap: () => Navigator.pushNamed(
            context,
            '/auction-details',
            arguments: auction,
          ),
        );
      },
    );
  }
}
