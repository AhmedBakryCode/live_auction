import 'package:dartz/dartz.dart';
import '../../../../core/errors/failure.dart';
import '../entities/leaderboard_entry.dart';

abstract class LeaderboardRepository {
  Future<Either<Failure, LeaderboardData>> getLeaderboard();
}
