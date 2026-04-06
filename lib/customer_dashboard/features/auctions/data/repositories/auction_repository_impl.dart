import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failure.dart';
import '../models/bid_model.dart';
import '../../domain/entities/auction.dart';
import '../../domain/repositories/auction_repository.dart';
import '../datasources/auction_remote_datasource.dart';

class AuctionRepositoryImpl implements AuctionRepository {
  final AuctionRemoteDataSource remoteDataSource;

  AuctionRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, List<Auction>>> getActiveAuctions() async {
    return _getAuctions(() => remoteDataSource.getActiveAuctions());
  }

  @override
  Future<Either<Failure, List<Auction>>> getUpcomingAuctions() async {
    return _getAuctions(() => remoteDataSource.getUpcomingAuctions());
  }

  @override
  Future<Either<Failure, List<Auction>>> getClosedAuctions() async {
    return _getAuctions(() => remoteDataSource.getClosedAuctions());
  }

  @override
  Future<Either<Failure, List<Auction>>> getRepostedAuctions() async {
    return _getAuctions(() => remoteDataSource.getRepostedAuctions());
  }

  @override
  Future<Either<Failure, List<Auction>>> getPaidAuctions() async {
    return _getAuctions(() => remoteDataSource.getPaidAuctions());
  }

  @override
  Future<Either<Failure, Auction>> getAuctionDetails(int id) async {
    try {
      final result = await remoteDataSource.getAuctionDetails(id);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message ?? 'Unknown error'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> joinAuction(int auctionId) async {
    try {
      await remoteDataSource.joinAuction(auctionId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message ?? 'Failed to join auction'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> placeBid(int auctionId, double amount) async {
    try {
      await remoteDataSource.placeBid(auctionId, amount);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message ?? 'Failed to place bid'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<BidModel>>> getAuctionBids(int auctionId) async {
    try {
      final result = await remoteDataSource.getAuctionBids(auctionId);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message ?? 'Failed to load bids'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, List<Auction>>> _getAuctions(
    Future<List<Auction>> Function() getAuctions,
  ) async {
    try {
      final result = await getAuctions();
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message ?? 'Unknown error'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
