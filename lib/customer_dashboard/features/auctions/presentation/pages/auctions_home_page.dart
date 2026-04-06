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
import '../../../profile/presentation/bloc/profile_bloc.dart';
import '../../../wallet/presentation/bloc/wallet_bloc.dart';
import '../bloc/auction_bloc.dart';
import '../../domain/entities/auction.dart';

class AuctionsHomePage extends StatefulWidget {
  const AuctionsHomePage({super.key});

  @override
  State<AuctionsHomePage> createState() => _AuctionsHomePageState();
}

class _AuctionsHomePageState extends State<AuctionsHomePage> {
  @override
  void initState() {
    super.initState();
    // Load wallet and profile data when page loads
    context.read<WalletBloc>().add(LoadWallet());
    context.read<ProfileBloc>().add(LoadProfile());
    // Load only active auctions initially for faster startup
    context.read<AuctionBloc>().add(LoadActiveAuctions());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocBuilder<AuctionBloc, AuctionState>(
          builder: (context, state) {
            if (state is AuctionLoading) {
              return const LoadingIndicator();
            } else if (state is AuctionError) {
              return ErrorView(
                message: state.message,
                onRetry: () {
                  context.read<AuctionBloc>().add(LoadActiveAuctions());
                  context.read<AuctionBloc>().add(LoadUpcomingAuctions());
                  context.read<AuctionBloc>().add(LoadClosedAuctions());
                  context.read<AuctionBloc>().add(LoadRepostedAuctions());
                  context.read<AuctionBloc>().add(LoadPaidAuctions());
                },
              );
            } else if (state is AuctionsLoaded) {
              return RefreshIndicator(
                onRefresh: () async {
                  context.read<AuctionBloc>().add(LoadActiveAuctions());
                  context.read<AuctionBloc>().add(LoadUpcomingAuctions());
                  context.read<AuctionBloc>().add(LoadClosedAuctions());
                  context.read<AuctionBloc>().add(LoadRepostedAuctions());
                  context.read<AuctionBloc>().add(LoadPaidAuctions());
                },
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
                    _buildHorizontalAuctionList(state.activeAuctions),
                    _buildLazyLoadSection(
                      context,
                      title: '⏳ مزادات قادمة',
                      auctions: state.upcomingAuctions,
                      onLoad: () => context.read<AuctionBloc>().add(
                        LoadUpcomingAuctions(),
                      ),
                    ),
                    _buildLazyLoadSection(
                      context,
                      title: '📋 مزادات منتهية',
                      auctions: state.closedAuctions,
                      onLoad: () =>
                          context.read<AuctionBloc>().add(LoadClosedAuctions()),
                    ),
                    _buildLazyLoadSection(
                      context,
                      title: '🔄 مزادات معاد نشرها',
                      auctions: state.repostedAuctions,
                      onLoad: () => context.read<AuctionBloc>().add(
                        LoadRepostedAuctions(),
                      ),
                    ),
                    _buildLazyLoadSection(
                      context,
                      title: '💰 مزادات مدفوعة',
                      auctions: state.paidAuctions,
                      onLoad: () =>
                          context.read<AuctionBloc>().add(LoadPaidAuctions()),
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 24)),
                  ],
                ),
              );
            }
            // For any other state (JoinAuctionSuccess, PlaceBidSuccess, etc.),
            // reload the auctions to get fresh data
            WidgetsBinding.instance.addPostFrameCallback((_) {
              context.read<AuctionBloc>().add(LoadActiveAuctions());
            });
            return const LoadingIndicator();
          },
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
                child: BlocBuilder<ProfileBloc, ProfileState>(
                  builder: (context, profileState) {
                    String userName = 'مستخدم';
                    String avatarName = 'مستخدم';

                    if (profileState is ProfileLoaded) {
                      userName = profileState.profile.fullName;
                      avatarName = profileState.profile.firstName;
                    }

                    return Row(
                      children: [
                        UserAvatar(name: avatarName, size: 40),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'مرحباً بك،',
                                style: TextStyle(
                                  color: AppColors.getSecondaryText(context),
                                  fontSize: 12,
                                ),
                              ),
                              Text(
                                userName,
                                style: TextStyle(
                                  color: AppColors.getPrimaryText(context),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: BlocBuilder<WalletBloc, WalletState>(
                builder: (context, walletState) {
                  double walletBalance = 0.0;

                  if (walletState is WalletLoaded) {
                    walletBalance = walletState.wallet.balance;
                  }

                  return Row(
                    children: [
                      const Icon(
                        Icons.account_balance_wallet,
                        size: 16,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 8),
                      PriceWidget(
                        price: walletBalance,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            NotificationBadge(
              count: 3,
              child: IconButton(
                onPressed:
                    () {}, // Navigate to notifications tab if possible or stay here
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
        color: Theme.of(context).brightness == Brightness.light
            ? Colors.grey[100]
            : AppColors.darkSurface,
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
                imageUrl: auction.image ?? '',
                currentBid: auction.currentPrice,
                endTime: auction.endTime,
                totalBids: 0,
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    '/auction-details',
                    arguments: auction,
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildLazyLoadSection(
    BuildContext context, {
    required String title,
    required List<Auction> auctions,
    required VoidCallback onLoad,
  }) {
    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title, style: AppTextStyles.heading3),
                if (auctions.isNotEmpty)
                  TextButton(
                    onPressed: () =>
                        Navigator.pushNamed(context, '/all-auctions'),
                    child: const Text('عرض الكل'),
                  ),
              ],
            ),
          ),
          if (auctions.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ElevatedButton.icon(
                onPressed: onLoad,
                icon: const Icon(Icons.refresh),
                label: const Text('تحميل المزادات'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                ),
              ),
            )
          else
            SizedBox(
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
                      imageUrl: auction.image ?? '',
                      currentBid: auction.currentPrice,
                      endTime: auction.endTime,
                      totalBids: 0,
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          '/auction-details',
                          arguments: auction,
                        );
                      },
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
