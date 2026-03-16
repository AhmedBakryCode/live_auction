import 'package:dartz/dartz.dart';
import '../../../../core/errors/failure.dart';
import '../entities/auction.dart';

abstract class AuctionRepository {
  Future<Either<Failure, List<Auction>>> getActiveAuctions();
  Future<Either<Failure, Auction>> getAuctionDetails(String id);
}
