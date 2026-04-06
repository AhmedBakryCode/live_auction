import 'package:dartz/dartz.dart';
import '../../../../core/errors/failure.dart';
import '../../../auctions/domain/entities/auction.dart';

abstract class WatchlistRepository {
  Future<Either<Failure, List<Auction>>> getUserParticipatedAuctions();
}
