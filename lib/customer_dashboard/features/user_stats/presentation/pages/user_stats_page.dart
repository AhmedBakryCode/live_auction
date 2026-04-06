import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../domain/entities/user_stats.dart';
import '../bloc/user_stats_bloc.dart';

class UserStatsPage extends StatelessWidget {
  const UserStatsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: context.read<UserStatsBloc>()..add(LoadUserStats()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('إحصائياتي'),
        ),
        body: BlocBuilder<UserStatsBloc, UserStatsState>(
          builder: (context, state) {
            if (state is UserStatsLoading) {
              return const LoadingIndicator();
            } else if (state is UserStatsError) {
              return ErrorView(
                message: state.message,
                onRetry: () => context.read<UserStatsBloc>().add(LoadUserStats()),
              );
            } else if (state is UserStatsLoaded) {
              final stats = state.stats;
              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildStatsGrid(stats),
                    const SizedBox(height: 24),
                    Text(
                      'المزادات المشارك فيها',
                      style: AppTextStyles.heading3,
                    ),
                    const SizedBox(height: 16),
                    _buildAuctionsList(stats.participatedAuctions),
                  ],
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildStatsGrid(UserStats stats) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      children: [
        _buildStatCard(
          icon: Icons.gavel,
          value: stats.totalBids.toString(),
          label: 'إجمالي المزايدات',
          color: AppColors.primary,
        ),
        _buildStatCard(
          icon: Icons.emoji_events,
          value: stats.auctionsWon.toString(),
          label: 'المزادات الفائز بها',
          color: Colors.amber,
        ),
        _buildStatCard(
          icon: Icons.account_balance_wallet,
          value: '${stats.totalSpent.toStringAsFixed(0)} ر.س',
          label: 'إجمالي الإنفاق',
          color: Colors.green,
        ),
        _buildStatCard(
          icon: Icons.local_activity,
          value: stats.joinedAuctionsCount.toString(),
          label: 'المزادات المنضم لها',
          color: Colors.blue,
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(height: 12),
            Text(
              value,
              style: AppTextStyles.heading2.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: AppTextStyles.caption,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAuctionsList(List<ParticipatedAuction> auctions) {
    if (auctions.isEmpty) {
      return const Center(
        child: Text('لم تشارك في أي مزادات حتى الآن'),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: auctions.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final auction = auctions[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            contentPadding: const EdgeInsets.all(12),
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: auction.image.isNotEmpty
                  ? Image.network(
                      auction.image,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: 60,
                        height: 60,
                        color: Colors.grey[300],
                        child: const Icon(Icons.image_not_supported),
                      ),
                    )
                  : Container(
                      width: 60,
                      height: 60,
                      color: Colors.grey[300],
                      child: const Icon(Icons.gavel),
                    ),
            ),
            title: Text(
              auction.title,
              style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w600),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  auction.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.caption,
                ),
                const SizedBox(height: 4),
                Text(
                  'سعر البداية: ${auction.startPrice.toStringAsFixed(0)} ر.س',
                  style: AppTextStyles.caption.copyWith(color: AppColors.primary),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
