import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../../../core/widgets/user_avatar.dart';
import '../bloc/leaderboard_bloc.dart';

class LeaderboardPage extends StatelessWidget {
  const LeaderboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: context.read<LeaderboardBloc>()..add(LoadLeaderboard()),
      child: Scaffold(
        appBar: AppBar(title: const Text('لوحة المتصدرين')),
        body: BlocBuilder<LeaderboardBloc, LeaderboardState>(
          builder: (context, state) {
            if (state is LeaderboardLoading) {
              return const LoadingIndicator();
            } else if (state is LeaderboardError) {
              return ErrorView(
                message: state.message,
                onRetry: () => context.read<LeaderboardBloc>().add(LoadLeaderboard()),
              );
            } else if (state is LeaderboardLoaded) {
              if (state.users.isEmpty) {
                return const Center(child: Text('لا يوجد بيانات حالياً'));
              }
              return Column(
                children: [
                  _buildTopThree(state.users),
                  const SizedBox(height: 24),
                  Expanded(child: _buildRankList(state.users)),
                ],
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildTopThree(List<Map<String, dynamic>> users) {
    if (users.length < 3) return const SizedBox.shrink();
    
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: const BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _buildPodiumItem(users[1], 80, Colors.grey[300]!),
          _buildPodiumItem(users[0], 110, Colors.amber),
          _buildPodiumItem(users[2], 75, Colors.orangeAccent),
        ],
      ),
    );
  }

  Widget _buildPodiumItem(Map<String, dynamic> user, double height, Color medalColor) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomCenter,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: UserAvatar(name: user['name'], size: height * 0.7),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: medalColor,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: Text(
                '#${user['rank']}',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: 90,
          child: Text(
            user['name'],
            style: AppTextStyles.bodyMedium.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Text(
          '${user['wins']} فوز',
          style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildRankList(List<Map<String, dynamic>> users) {
    final List<Map<String, dynamic>> restUsers = users.length > 3 ? users.sublist(3) : [];

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: restUsers.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final user = restUsers[index];
        return ListTile(
          contentPadding: const EdgeInsets.symmetric(vertical: 8),
          leading: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 30,
                child: Text(
                  '${user['rank']}',
                  style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              UserAvatar(name: user['name'], size: 44),
            ],
          ),
          title: Text(user['name'], style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w600)),
          subtitle: Text('${user['bids']} إجمالي المزايدات', style: AppTextStyles.caption),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('${user['wins']} فوز', style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
              Text('${user['score']} نقطة', style: AppTextStyles.caption.copyWith(color: AppColors.primary)),
            ],
          ),
        );
      },
    );
  }
}
