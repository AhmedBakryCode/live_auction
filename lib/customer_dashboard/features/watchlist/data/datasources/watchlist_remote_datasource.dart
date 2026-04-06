import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../auctions/data/models/auction_model.dart';

abstract class WatchlistRemoteDataSource {
  Future<List<AuctionModel>> getUserParticipatedAuctions();
}

class WatchlistRemoteDataSourceImpl implements WatchlistRemoteDataSource {
  final Dio dio;

  WatchlistRemoteDataSourceImpl(this.dio);

  @override
  Future<List<AuctionModel>> getUserParticipatedAuctions() async {
    try {
      final response = await dio.get(ApiConstants.userBids);

      if (response.statusCode == 200) {
        final responseData = response.data;
        if (responseData is Map && responseData['data'] is List) {
          return (responseData['data'] as List)
              .map((e) => AuctionModel.fromJson(e as Map<String, dynamic>))
              .toList();
        } else if (responseData is List) {
          return responseData
              .map((e) => AuctionModel.fromJson(e as Map<String, dynamic>))
              .toList();
        }
        return [];
      } else {
        throw ServerException(
          response.data['message'] ?? 'Failed to load participated auctions',
        );
      }
    } on DioException catch (e) {
      throw ServerException(e.message ?? 'Network error');
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
