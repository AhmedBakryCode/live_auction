import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/auction_model.dart';
import '../models/bid_model.dart';

abstract class AuctionRemoteDataSource {
  Future<List<AuctionModel>> getActiveAuctions();
  Future<List<AuctionModel>> getUpcomingAuctions();
  Future<List<AuctionModel>> getClosedAuctions();
  Future<List<AuctionModel>> getRepostedAuctions();
  Future<List<AuctionModel>> getPaidAuctions();
  Future<AuctionModel> getAuctionDetails(int id);
  Future<void> joinAuction(int auctionId);
  Future<void> placeBid(int auctionId, double amount);
  Future<List<BidModel>> getAuctionBids(int auctionId);
}

class AuctionRemoteDataSourceImpl implements AuctionRemoteDataSource {
  final Dio dio;

  AuctionRemoteDataSourceImpl(this.dio);

  @override
  Future<List<AuctionModel>> getActiveAuctions() async {
    return _fetchAuctions(ApiConstants.activeAuctions);
  }

  @override
  Future<List<AuctionModel>> getUpcomingAuctions() async {
    return _fetchAuctions(ApiConstants.upcomingAuctions);
  }

  @override
  Future<List<AuctionModel>> getClosedAuctions() async {
    return _fetchAuctions(ApiConstants.closedAuctions);
  }

  @override
  Future<List<AuctionModel>> getRepostedAuctions() async {
    return _fetchAuctions(ApiConstants.repostedAuctions);
  }

  @override
  Future<List<AuctionModel>> getPaidAuctions() async {
    return _fetchAuctions(ApiConstants.paidAuctions);
  }

  @override
  Future<AuctionModel> getAuctionDetails(int id) async {
    try {
      final response = await dio.get(ApiConstants.auctionById(id));

      if (response.statusCode == 200) {
        final data = response.data is Map && response.data['data'] != null
            ? response.data['data']
            : response.data;
        return AuctionModel.fromJson(data);
      } else {
        throw ServerException(
          response.data['message'] ?? 'Failed to load auction details',
        );
      }
    } on DioException catch (e) {
      throw ServerException(e.message ?? 'Network error');
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> joinAuction(int auctionId) async {
    try {
      final response = await dio.post(ApiConstants.joinAuction(auctionId));

      if (response.statusCode == 200 || response.statusCode == 201) {
        return;
      } else {
        throw ServerException(
          response.data['message'] ?? 'Failed to join auction',
        );
      }
    } on DioException catch (e) {
      throw ServerException(e.message ?? 'Network error');
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> placeBid(int auctionId, double amount) async {
    try {
      final response = await dio.post(
        ApiConstants.bids,
        data: {'auction_id': auctionId, 'amount': amount},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return;
      } else {
        throw ServerException(
          response.data['message'] ?? 'Failed to place bid',
        );
      }
    } on DioException catch (e) {
      throw ServerException(e.message ?? 'Network error');
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<BidModel>> getAuctionBids(int auctionId) async {
    try {
      final endpoint = ApiConstants.auctionBids(auctionId);
      debugPrint('🔍 Calling getAuctionBids with endpoint: $endpoint');
      final response = await dio.get(endpoint);
      debugPrint('🔍 Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final responseData = response.data;
        debugPrint('🔍 Response data: $responseData');
        if (responseData is Map && responseData['data'] is List) {
          final bids = (responseData['data'] as List)
              .map((e) => BidModel.fromJson(e as Map<String, dynamic>))
              .toList();
          debugPrint('🔍 Parsed ${bids.length} bids');
          return bids;
        } else if (responseData is List) {
          final bids = responseData
              .map((e) => BidModel.fromJson(e as Map<String, dynamic>))
              .toList();
          debugPrint('🔍 Parsed ${bids.length} bids from list');
          return bids;
        }
        debugPrint('🔍 No bids found in response');
        return [];
      } else {
        throw ServerException(
          response.data['message'] ?? 'Failed to load auction bids',
        );
      }
    } on DioException catch (e) {
      throw ServerException(e.message ?? 'Network error');
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  Future<List<AuctionModel>> _fetchAuctions(String endpoint) async {
    try {
      debugPrint('🔍 Calling _fetchAuctions with endpoint: $endpoint');
      final response = await dio.get(endpoint);

      if (response.statusCode == 200) {
        List<dynamic> data;
        if (response.data is List) {
          data = response.data;
        } else if (response.data is Map) {
          final responseData = response.data['data'];
          if (responseData is List) {
            data = responseData;
          } else if (responseData is Map && responseData['data'] is List) {
            // Handle paginated response: {data: {data: [], current_page: ...}}
            data = responseData['data'];
          } else {
            data = [];
          }
        } else {
          data = [];
        }
        return data.map((e) => AuctionModel.fromJson(e)).toList();
      } else {
        throw ServerException(
          response.data['message'] ?? 'Failed to load auctions',
        );
      }
    } on DioException catch (e) {
      throw ServerException(e.message ?? 'Network error');
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
