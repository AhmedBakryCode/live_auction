import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../providers/leaderboard_provider.dart';
import '../models/leaderboard_model.dart';
import '../../../core/widgets/app_card.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LeaderboardProvider>().fetchLeaderboard();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'لوحة المتصدرين',
          style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.surface,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'إحصائيات المنصة',
                style: GoogleFonts.cairo(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Expanded(
                child: DefaultTabController(
                  length: 3,
                  child: Column(
                    children: [
                      TabBar(
                        labelColor: AppColors.primary,
                        unselectedLabelColor: Colors.white54,
                        indicatorColor: AppColors.primary,
                        labelStyle: GoogleFonts.cairo(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        unselectedLabelStyle: GoogleFonts.cairo(
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                        tabs: const [
                          Tab(text: 'الأكثر فوزاً'),
                          Tab(text: 'أعلى المزايدات'),
                          Tab(text: 'الأكثر إنفاقاً'),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: Consumer<LeaderboardProvider>(
                          builder: (context, provider, child) {
                            if (provider.isLoading) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
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
                              return const Center(
                                child: Text('لا توجد بيانات متاحة'),
                              );
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
              ),
            ],
          ),
        ),
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
          title: winner.creator != null ? 'اسم: ${winner.creator}' : 'مستخدم #${winner.winnerId}',
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Text(
              rank,
              style: GoogleFonts.cairo(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.cairo(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.cairo(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
        ],
      ),
    );
  }
}
