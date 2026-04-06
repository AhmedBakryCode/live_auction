import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failure.dart';
import '../../domain/entities/user_stats.dart';
import '../../domain/repositories/user_stats_repository.dart';
import '../datasources/user_stats_remote_datasource.dart';

class UserStatsRepositoryImpl implements UserStatsRepository {
  final UserStatsRemoteDataSource remoteDataSource;

  UserStatsRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, UserStats>> getUserStats() async {
    try {
      final result = await remoteDataSource.getUserStats();
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message ?? 'Unknown error'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
