import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../../auctions/domain/entities/auction.dart';
import '../bloc/watchlist_bloc.dart';

class WatchlistPage extends StatelessWidget {
  const WatchlistPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: context.read<WatchlistBloc>()..add(LoadWatchlist()),
      child: Scaffold(
        appBar: AppBar(title: const Text('مزايداتي')),
        body: BlocBuilder<WatchlistBloc, WatchlistState>(
          builder: (context, state) {
            if (state is WatchlistLoading) {
              return const LoadingIndicator();
            } else if (state is WatchlistError) {
              return ErrorView(
                message: state.message,
                onRetry: () =>
                    context.read<WatchlistBloc>().add(LoadWatchlist()),
              );
            } else if (state is WatchlistLoaded) {
              if (state.auctions.isEmpty) {
                return const EmptyStateWidget(
                  message: 'لم تشارك في أي مزادات بعد.',
                  icon: Icons.gavel_outlined,
                );
              }
              return RefreshIndicator(
                onRefresh: () async =>
                    context.read<WatchlistBloc>().add(LoadWatchlist()),
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: state.auctions.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final auction = state.auctions[index];
                    return _buildAuctionCard(context, auction);
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

  Widget _buildAuctionCard(BuildContext context, Auction auction) {
    final bool isUserWinner =
        auction.winnerId != null && auction.winnerId == auction.highestBidderId;
    final bool isClosed = auction.status == 'closed' || auction.isClosed;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () => Navigator.pushNamed(
          context,
          '/auction-details',
          arguments: {'auction': auction, 'isAlreadyJoined': true},
        ),
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            if (auction.image != null)
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                child: Image.network(
                  auction.image!,
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: 180,
                    color: Colors.grey[300],
                    child: const Icon(Icons.image_not_supported, size: 50),
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status badge
                  _buildStatusBadge(isUserWinner, isClosed, auction),
                  const SizedBox(height: 12),
                  // Title
                  Text(
                    auction.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  // Price info
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'السعر الحالي',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              '${auction.currentPrice.toStringAsFixed(2)} ج.م',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: isClosed
                                    ? Colors.grey
                                    : AppColors.priceGreen,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'سعر البداية',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              '${auction.startPrice.toStringAsFixed(2)} ج.م',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // End date
                  Text(
                    'تاريخ الانتهاء: ${_formatDate(auction.endTime)}',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(bool isWinner, bool isClosed, Auction auction) {
    if (isWinner) {
      return _buildBadge('🎉 فزت بالمزاد!', Colors.green, Icons.emoji_events);
    } else if (isClosed) {
      return _buildBadge('❌ المزاد منتهي', Colors.grey, Icons.close);
    } else if (auction.highestBidderId != null) {
      return _buildBadge(
        '✓ أنت المزايد الأعلى',
        AppColors.priceGreen,
        Icons.check_circle,
      );
    } else {
      return _buildBadge('🟢 مزاد نشط', Colors.blue, Icons.gavel);
    }
  }

  Widget _buildBadge(String text, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
