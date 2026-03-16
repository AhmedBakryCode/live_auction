import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';

import '../../../../core/widgets/auction_card.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../bloc/watchlist_bloc.dart';

class WatchlistPage extends StatelessWidget {
  const WatchlistPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: context.read<WatchlistBloc>()..add(LoadWatchlist()),
      child: Scaffold(
        appBar: AppBar(title: const Text('قائمة المتابعة')),
        body: BlocBuilder<WatchlistBloc, WatchlistState>(
          builder: (context, state) {
            if (state is WatchlistLoading) {
              return const LoadingIndicator();
            } else if (state is WatchlistError) {
              return ErrorView(
                message: state.message,
                onRetry: () => context.read<WatchlistBloc>().add(LoadWatchlist()),
              );
            } else if (state is WatchlistLoaded) {
              if (state.items.isEmpty) {
                return const EmptyStateWidget(
                  message: 'أضف المزادات إلى قائمتك لتتمكن من تتبعها بسهولة.',
                  icon: Icons.favorite_border,
                );
              }
              return RefreshIndicator(
                onRefresh: () async => context.read<WatchlistBloc>().add(LoadWatchlist()),
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: state.items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final auction = state.items[index];
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildBidStatusMarker(index == 0 ? 'Leading' : 'Outbid'),
                        const SizedBox(height: 8),
                        AuctionCard(
                          title: auction.title,
                          imageUrl: auction.imageUrl,
                          currentBid: auction.currentBid,
                          endTime: auction.endTime,
                          totalBids: auction.totalBids,
                          onTap: () => Navigator.pushNamed(context, '/auction-details', arguments: auction),
                        ),
                      ],
                    );
                  },
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildBidStatusMarker(String status) {
    final bool isLeading = status == 'Leading';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isLeading ? AppColors.priceGreen.withOpacity(0.1) : Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(isLeading ? Icons.check_circle : Icons.warning_rounded, 
               size: 14, color: isLeading ? AppColors.priceGreen : Colors.red),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              isLeading ? 'أنت صاحب أعلى مزايدة حالياً!' : 'لقد قام شخص آخر بالمزايدة عليك!',
              style: TextStyle(
                color: isLeading ? AppColors.priceGreen : Colors.red,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
