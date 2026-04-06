import 'package:dartz/dartz.dart';
import '../../../../core/errors/failure.dart';
import '../../data/models/bid_model.dart';
import '../entities/auction.dart';

abstract class AuctionRepository {
  Future<Either<Failure, List<Auction>>> getActiveAuctions();
  Future<Either<Failure, List<Auction>>> getUpcomingAuctions();
  Future<Either<Failure, List<Auction>>> getClosedAuctions();
  Future<Either<Failure, List<Auction>>> getRepostedAuctions();
  Future<Either<Failure, List<Auction>>> getPaidAuctions();
  Future<Either<Failure, Auction>> getAuctionDetails(int id);
  Future<Either<Failure, void>> joinAuction(int auctionId);
  Future<Either<Failure, void>> placeBid(int auctionId, double amount);
  Future<Either<Failure, List<BidModel>>> getAuctionBids(int auctionId);
}
