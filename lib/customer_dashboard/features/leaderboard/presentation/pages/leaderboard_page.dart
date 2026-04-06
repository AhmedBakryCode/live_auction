import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../../../core/widgets/user_avatar.dart';
import '../../domain/entities/leaderboard_entry.dart';
import '../bloc/leaderboard_bloc.dart';

class LeaderboardPage extends StatelessWidget {
  const LeaderboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: context.read<LeaderboardBloc>()..add(LoadLeaderboard()),
      child: DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('لوحة المتصدرين'),
            bottom: const TabBar(
              tabs: [
                Tab(text: 'الفائزون', icon: Icon(Icons.emoji_events)),
                Tab(text: 'المزايدون', icon: Icon(Icons.gavel)),
                Tab(text: 'المشتريون', icon: Icon(Icons.shopping_cart)),
              ],
            ),
          ),
          body: BlocBuilder<LeaderboardBloc, LeaderboardState>(
            builder: (context, state) {
              if (state is LeaderboardLoading) {
                return const LoadingIndicator();
              } else if (state is LeaderboardError) {
                return ErrorView(
                  message: state.message,
                  onRetry: () =>
                      context.read<LeaderboardBloc>().add(LoadLeaderboard()),
                );
              } else if (state is LeaderboardLoaded) {
                final data = state.data;
                return TabBarView(
                  children: [
                    _buildWinnersTab(data.topWinners),
                    _buildBiddersTab(data.topBidders),
                    _buildSpendersTab(data.topSpenders),
                  ],
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  }

  Widget _buildWinnersTab(List<LeaderboardEntry> winners) {
    if (winners.isEmpty) {
      return const Center(child: Text('لا يوجد فائزون حالياً'));
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: winners.length,
      separatorBuilder: (_, __) => const Divider(),
      itemBuilder: (context, index) {
        final winner = winners[index];
        final user = winner.winner;
        return _buildLeaderboardItem(
          rank: index + 1,
          name: user?.fullName ?? 'فائز #${winner.winnerId}',
          subtitle: '${winner.wins} فوز',
          medalColor: _getMedalColor(index),
          profileImage: user?.profileImage,
        );
      },
    );
  }

  Widget _buildBiddersTab(List<TopBidder> bidders) {
    if (bidders.isEmpty) {
      return const Center(child: Text('لا يوجد مزايدون حالياً'));
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: bidders.length,
      separatorBuilder: (_, __) => const Divider(),
      itemBuilder: (context, index) {
        final bidder = bidders[index];
        final user = bidder.user;
        return _buildLeaderboardItem(
          rank: index + 1,
          name: user?.fullName ?? 'مزايد #${bidder.userId}',
          subtitle: '${bidder.auctionsParticipated} مزاد مشترك',
          medalColor: _getMedalColor(index),
          profileImage: user?.profileImage,
        );
      },
    );
  }

  Widget _buildSpendersTab(List<TopSpender> spenders) {
    if (spenders.isEmpty) {
      return const Center(child: Text('لا يوجد مشتريون حالياً'));
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: spenders.length,
      separatorBuilder: (_, __) => const Divider(),
      itemBuilder: (context, index) {
        final spender = spenders[index];
        final user = spender.winner;
        return _buildLeaderboardItem(
          rank: index + 1,
          name: user?.fullName ?? 'مشتري #${spender.winnerId}',
          subtitle: '${spender.totalSpent.toStringAsFixed(2)} ر.س',
          medalColor: _getMedalColor(index),
          profileImage: user?.profileImage,
        );
      },
    );
  }

  Widget _buildLeaderboardItem({
    required int rank,
    required String name,
    required String subtitle,
    Color? medalColor,
    String? profileImage,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      leading: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: medalColor ?? Colors.grey[300],
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '#$rank',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: medalColor != null ? Colors.white : Colors.black,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          profileImage != null && profileImage.isNotEmpty
              ? CircleAvatar(
                  radius: 24,
                  backgroundImage: NetworkImage(profileImage),
                  onBackgroundImageError: (_, __) {},
                )
              : UserAvatar(name: name, size: 48),
        ],
      ),
      title: Text(
        name,
        style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        subtitle,
        style: AppTextStyles.caption.copyWith(color: AppColors.primary),
      ),
    );
  }

  Color _getMedalColor(int index) {
    switch (index) {
      case 0:
        return Colors.amber;
      case 1:
        return Colors.grey[400]!;
      case 2:
        return Colors.orangeAccent;
      default:
        return Colors.transparent;
    }
  }
}
