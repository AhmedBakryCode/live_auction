import 'package:dartz/dartz.dart';
import '../../../../core/errors/failure.dart';
import '../entities/user_stats.dart';

abstract class UserStatsRepository {
  Future<Either<Failure, UserStats>> getUserStats();
}
