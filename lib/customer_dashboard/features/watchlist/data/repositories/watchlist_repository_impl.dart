import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failure.dart';
import '../../../auctions/domain/entities/auction.dart';
import '../../domain/repositories/watchlist_repository.dart';
import '../datasources/watchlist_remote_datasource.dart';

class WatchlistRepositoryImpl implements WatchlistRepository {
  final WatchlistRemoteDataSource remoteDataSource;

  WatchlistRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, List<Auction>>> getUserParticipatedAuctions() async {
    try {
      final result = await remoteDataSource.getUserParticipatedAuctions();
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message ?? 'Unknown error'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
