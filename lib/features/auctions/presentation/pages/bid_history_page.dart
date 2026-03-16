import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../../../core/widgets/price_widget.dart';
import '../../../../core/widgets/user_avatar.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../../../core/widgets/error_view.dart';
import '../../domain/entities/auction.dart';
import '../bloc/bid_history_bloc.dart';
import '../../../../core/widgets/custom_network_image.dart';

class BidHistoryPage extends StatelessWidget {
  final Auction auction;

  const BidHistoryPage({super.key, required this.auction});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: context.read<BidHistoryBloc>()..add(LoadBidHistory(auction.id)),
      child: Scaffold(
        appBar: CustomAppBar(
          title: 'تاريخ المزايدات',
          actions: [
            IconButton(icon: const Icon(Icons.info_outline), onPressed: () {}),
          ],
        ),
        body: BlocBuilder<BidHistoryBloc, BidHistoryState>(
          builder: (context, state) {
            if (state is BidHistoryLoading) {
              return const LoadingIndicator();
            } else if (state is BidHistoryError) {
              return ErrorView(
                message: state.message,
                onRetry: () => context.read<BidHistoryBloc>().add(LoadBidHistory(auction.id)),
              );
            } else if (state is BidHistoryLoaded) {
              return Column(
                children: [
                  _buildAuctionHeader(),
                  const Divider(height: 1),
                  Expanded(child: _buildHistoryList(state.bids)),
                ],
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildAuctionHeader() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          CustomNetworkImage(
            imageUrl: auction.imageUrl,
            width: 80,
            height: 80,
            borderRadius: 8,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(auction.title, style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text('إجمالي المزايدات: ${auction.totalBids}', style: AppTextStyles.caption),
                const SizedBox(height: 4),
                PriceWidget(
                  price: auction.currentBid,
                  style: AppTextStyles.bodyLarge.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryList(List<Map<String, dynamic>> bids) {
    if (bids.isEmpty) {
      return const Center(child: Text('لا يوجد مزايدات بعد.'));
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: bids.length,
      separatorBuilder: (context, index) => const Divider(height: 24),
      itemBuilder: (context, index) {
        final bid = bids[index];
        final bool isHighest = bid['isHighest'] ?? false;

        return Row(
          children: [
            UserAvatar(name: bid['bidderName'], size: 40),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(bid['bidderName'], style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold)),
                  Text(bid['time'], style: AppTextStyles.caption),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                PriceWidget(
                  price: bid['amount'],
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isHighest ? AppColors.priceGreen : AppColors.getPrimaryText(context),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: isHighest ? AppColors.priceGreen.withOpacity(0.1) : AppColors.getContainerColor(context),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    isHighest ? 'أعلى سعر' : 'تم تخطيه',
                    style: TextStyle(
                      fontSize: 10,
                      color: isHighest ? AppColors.priceGreen : AppColors.getSecondaryText(context),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
