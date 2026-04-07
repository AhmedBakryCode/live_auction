import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/section_header.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../leaderboard/providers/leaderboard_provider.dart';
import '../../leaderboard/models/leaderboard_model.dart';

class LeaderboardSection extends StatefulWidget {
  const LeaderboardSection({super.key});

  @override
  State<LeaderboardSection> createState() => _LeaderboardSectionState();
}

class _LeaderboardSectionState extends State<LeaderboardSection> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<LeaderboardProvider>().fetchLeaderboard();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(title: 'المتصدرون'),
          const SizedBox(height: 16),
          DefaultTabController(
            length: 3,
            child: Column(
              children: [
                TabBar(
                  labelColor: AppColors.primary,
                  unselectedLabelColor: Colors.white54,
                  indicatorColor: AppColors.primary,
                  isScrollable: true,
                  tabs: const [
                    Tab(text: 'الأكثر فوزاً'),
                    Tab(text: 'أعلى المزايدات'),
                    Tab(text: 'الأكثر إنفاقاً'),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 300, // Fixed height for the lists
                  child: Consumer<LeaderboardProvider>(
                    builder: (context, provider, child) {
                      if (provider.isLoading) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (provider.error != null) {
                        return Center(
                          child: Text(
                            provider.error!,
                            style: const TextStyle(color: Colors.red),
                            textAlign: TextAlign.center,
                          ),
                        );
                      }

                      final data = provider.leaderboardData;
                      if (data == null) {
                        return const Center(child: Text('لا توجد بيانات متاحة'));
                      }

                      return TabBarView(
                        children: [
                          _buildWinnersList(data.topWinners),
                          _buildBiddersList(data.topBidders),
                          _buildSpendersList(data.topSpenders),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWinnersList(List<TopWinner> winners) {
    if (winners.isEmpty) {
      return const Center(child: Text('لا يوجد فائزون بعد'));
    }
    return ListView.builder(
      itemCount: winners.length,
      itemBuilder: (context, index) {
        final winner = winners[index];
        return _buildItem(
          rank: '${index + 1}',
          title: 'مستخدم #${winner.winnerId}',
          subtitle: '${winner.wins} مرات فوز',
          icon: Icons.emoji_events_rounded,
          color: AppColors.primary,
        );
      },
    );
  }

  Widget _buildBiddersList(List<TopBidder> bidders) {
    if (bidders.isEmpty) {
      return const Center(child: Text('لا يوجد مزايدون بعد'));
    }
    return ListView.builder(
      itemCount: bidders.length,
      itemBuilder: (context, index) {
        final bidder = bidders[index];
        return _buildItem(
          rank: '${index + 1}',
          title: 'مستخدم #${bidder.userId}',
          subtitle: '${bidder.bidsCount} مزايدات',
          icon: Icons.local_fire_department_rounded,
          color: AppColors.secondary,
        );
      },
    );
  }

  Widget _buildSpendersList(List<TopSpender> spenders) {
    if (spenders.isEmpty) {
      return const Center(child: Text('لا يوجد منفقون بعد'));
    }
    return ListView.builder(
      itemCount: spenders.length,
      itemBuilder: (context, index) {
        final spender = spenders[index];
        return _buildItem(
          rank: '${index + 1}',
          title: 'مستخدم #${spender.winnerId}',
          subtitle: '${spender.totalSpent} ريال',
          icon: Icons.attach_money_rounded,
          color: AppColors.success,
        );
      },
    );
  }

  Widget _buildItem({
    required String rank,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.background.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Text(rank, style: AppTextStyles.body1Bold.copyWith(color: color)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.body1Bold),
                Text(subtitle, style: AppTextStyles.caption.copyWith(fontSize: 12)),
              ],
            ),
          ),
          Icon(icon, color: color, size: 24),
        ],
      ),
    );
  }
}
