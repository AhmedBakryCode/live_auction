import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/notification_badge.dart';
import '../../../../core/widgets/user_avatar.dart';
import '../../../../core/widgets/price_widget.dart';
import '../../../../core/widgets/auction_card.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../../../core/widgets/error_view.dart';
import '../bloc/auction_bloc.dart';
import '../../domain/entities/auction.dart';

class AuctionsHomePage extends StatelessWidget {
  const AuctionsHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: context.read<AuctionBloc>()..add(LoadAuctions()),
      child: Scaffold(
        body: SafeArea(
          child: BlocBuilder<AuctionBloc, AuctionState>(
            builder: (context, state) {
              if (state is AuctionLoading) {
                return const LoadingIndicator();
              } else if (state is AuctionError) {
                return ErrorView(
                  message: state.message,
                  onRetry: () => context.read<AuctionBloc>().add(LoadAuctions()),
                );
              } else if (state is AuctionLoaded) {
                return RefreshIndicator(
                  onRefresh: () async => context.read<AuctionBloc>().add(LoadAuctions()),
                  child: CustomScrollView(
                    slivers: [
                      _buildAppBar(context),
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: _buildSearchBar(context),
                        ),
                      ),
                      _buildSectionHeader(context, '🔥 مزادات مباشرة'),
                      _buildHorizontalAuctionList(state.auctions),
                      _buildSectionHeader(context, '⏳ أوشكت على الانتهاء'),
                      _buildHorizontalAuctionList(state.auctions),
                      _buildSectionHeader(context, '⭐ مقترح لك'),
                      _buildHorizontalAuctionList(state.auctions),
                      const SliverToBoxAdapter(child: SizedBox(height: 24)),
                    ],
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      sliver: SliverToBoxAdapter(
        child: Row(
          children: [
            Expanded(
              child: InkWell(
                onTap: () => Navigator.pushNamed(context, '/profile'),
                borderRadius: BorderRadius.circular(12),
                child: Row(
                  children: [
                    const UserAvatar(name: 'أحمد', size: 40),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('مرحباً بك،', style: TextStyle(color: AppColors.getSecondaryText(context), fontSize: 12)),
                          Text('أحمد بكري', style: TextStyle(color: AppColors.getPrimaryText(context), fontWeight: FontWeight.bold, fontSize: 16)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  const Icon(Icons.account_balance_wallet, size: 16, color: AppColors.primary),
                  const SizedBox(width: 8),
                  PriceWidget(
                    price: 1250.50,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            NotificationBadge(
              count: 3,
              child: IconButton(
                onPressed: () {}, // Navigate to notifications tab if possible or stay here
                icon: const Icon(Icons.notifications_outlined),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.light ? Colors.grey[100] : AppColors.darkSurface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const TextField(
        decoration: InputDecoration(
          hintText: 'ابحث عن مزادات...',
          hintStyle: TextStyle(color: AppColors.textSecondary, fontSize: 12),
          prefixIcon: Icon(Icons.search, color: AppColors.textSecondary),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: AppTextStyles.heading3),
            TextButton(
              onPressed: () => Navigator.pushNamed(context, '/all-auctions'),
              child: const Text('عرض الكل'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHorizontalAuctionList(List<Auction> auctions) {
    return SliverToBoxAdapter(
      child: SizedBox(
        height: 380,
        child: ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          scrollDirection: Axis.horizontal,
          itemCount: auctions.length,
          separatorBuilder: (context, index) => const SizedBox(width: 16),
          itemBuilder: (context, index) {
            final auction = auctions[index];
            return SizedBox(
              width: 280,
              child: AuctionCard(
                title: auction.title,
                imageUrl: auction.imageUrl,
                currentBid: auction.currentBid,
                endTime: auction.endTime,
                totalBids: auction.totalBids,
                onTap: () {
                  Navigator.pushNamed(context, '/auction-details', arguments: auction);
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
