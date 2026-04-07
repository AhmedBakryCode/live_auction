import '../models/user_bid_model.dart';
import '../../../core/network/api_client.dart';
import '../../../core/utils/app_logger.dart';

class BidsRepository extends ApiClient {
  Future<List<UserBidModel>> fetchUserBids() async {
    // تم حذف نقطة النهاية (Endpoint) بشكل نهائي بناءً على طلبك
    AppLogger.info('BIDS', 'Endpoint removed. Returning mock bids.');
    await Future.delayed(const Duration(seconds: 1));
    return [
      UserBidModel(
        id: 1,
        auctionId: 101,
        userId: 5,
        amount: 250.0,
        createdAt: DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
        updatedAt: DateTime.now().toIso8601String(),
      ),
      UserBidModel(
        id: 2,
        auctionId: 102,
        userId: 5,
        amount: 1500.0,
        createdAt: DateTime.now().subtract(const Duration(days: 2)).toIso8601String(),
        updatedAt: DateTime.now().toIso8601String(),
      ),
    ];
  }
}
