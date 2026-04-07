import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/auction_model.dart';
import '../models/auction_bid_model.dart';
import '../../../core/config/app_config.dart';
import '../../../core/network/api_client.dart';
import '../../../core/utils/app_logger.dart';

class AuctionsRepository extends ApiClient {
  // ─── Create Auction ───────────────────────────────────────────────────────
  Future<AuctionModel> createAuction({
    required String title,
    String? description,
    required String startPrice,
    required String startTime,
    required String endTime,
    String? imagePath,
  }) async {
    try {
      final headers = await getJsonHeaders();
      final request = http.MultipartRequest(
        'POST',
        Uri.parse(AppConfig.auctionsEndpoint),
      );
      request.headers.addAll(headers);
      request.fields['title'] = title;
      if (description != null && description.isNotEmpty) {
        request.fields['description'] = description;
      }
      request.fields['start_price'] = startPrice;
      request.fields['start_time'] = startTime;
      request.fields['end_time'] = endTime;

      if (imagePath != null && imagePath.isNotEmpty) {
        request.files.add(
          await http.MultipartFile.fromPath('image', imagePath),
        );
      }

      final streamed =
          await request.send().timeout(AppConfig.uploadTimeout);
      final response = await http.Response.fromStream(streamed);
      AppLogger.network(
        'AUCTIONS_CREATE',
        response.statusCode,
        AppConfig.auctionsEndpoint,
      );

      final decoded = json.decode(response.body) as Map<String, dynamic>;
      if (response.statusCode == 201) {
        return AuctionModel.fromJson(decoded['data'] as Map<String, dynamic>);
      } else if (response.statusCode == 422) {
        final firstError = extractValidationError(decoded);
        throw Exception(
          firstError ?? decoded['message'] ?? 'خطأ في البيانات المدخلة',
        );
      }
      throwApiError(response.statusCode, decoded);
    } catch (e) {
      if (e is http.ClientException) {
        throw Exception('تعذر الاتصال بالخادم، يرجى التحقق من الاتصال');
      }
      rethrow;
    }
  }

  // ─── Update Auction ───────────────────────────────────────────────────────
  Future<AuctionModel> updateAuction(
    int id, {
    String? title,
    String? description,
    String? startPrice,
    String? startTime,
    String? endTime,
    String? imagePath,
  }) async {
    try {
      final headers = await getJsonHeaders();
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('${AppConfig.auctionsEndpoint}/$id'),
      );
      request.headers.addAll(headers);

      // Partial updates: only add populated fields
      if (title != null && title.isNotEmpty) request.fields['title'] = title;
      if (description != null && description.isNotEmpty) request.fields['description'] = description;
      if (startPrice != null && startPrice.isNotEmpty) request.fields['start_price'] = startPrice;
      if (startTime != null && startTime.isNotEmpty) request.fields['start_time'] = startTime;
      if (endTime != null && endTime.isNotEmpty) request.fields['end_time'] = endTime;

      if (imagePath != null && imagePath.isNotEmpty) {
        request.files.add(
          await http.MultipartFile.fromPath('image', imagePath),
        );
      }

      final streamed = await request.send().timeout(AppConfig.uploadTimeout);
      final response = await http.Response.fromStream(streamed);
      AppLogger.network('AUCTIONS_UPDATE', response.statusCode, '${AppConfig.auctionsEndpoint}/$id');

      final decoded = response.body.isNotEmpty 
          ? json.decode(response.body) as Map<String, dynamic> 
          : <String, dynamic>{};

      if (response.statusCode == 200 || response.statusCode == 201) {
        return AuctionModel.fromJson(decoded['data'] as Map<String, dynamic>);
      } else if (response.statusCode == 422) {
        final firstError = extractValidationError(decoded);
        throw Exception(firstError ?? decoded['message'] ?? 'خطأ في البيانات المدخلة');
      } else if (response.statusCode == 404) {
        throw Exception('المزاد غير موجود');
      } else if (response.statusCode == 401) {
        throw Exception('غير مصرح لك، يرجى تسجيل الدخول مجدداً');
      } else if (response.statusCode >= 500) {
        throw Exception('خطأ في الخادم، يرجى المحاولة لاحقاً');
      }
      
      throwApiError(response.statusCode, decoded);
    } catch (e) {
      if (e is http.ClientException) {
        throw Exception('تعذر الاتصال بالخادم، يرجى التحقق من الاتصال');
      }
      rethrow;
    }
  }

  // ─── Fetch All Auctions ───────────────────────────────────────────────────
  Future<List<AuctionModel>> fetchAuctions() async {
    try {
      AppLogger.info('AUCTIONS', 'Fetching all auctions...');
      final response = await apiGet(AppConfig.auctionsEndpoint);
      AppLogger.network(
        'AUCTIONS',
        response.statusCode,
        AppConfig.auctionsEndpoint,
      );

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body) as Map<String, dynamic>;
        final dynamic dataNode = decoded['data'];
        final List<dynamic> auctionsList = dataNode is List
            ? dataNode
            : (dataNode?['data'] as List<dynamic>? ?? []);
        return auctionsList
            .map((json) => AuctionModel.fromJson(json as Map<String, dynamic>))
            .toList();
      }
      final body = json.decode(response.body) as Map<String, dynamic>?;
      throwApiError(response.statusCode, body);
    } catch (e) {
      AppLogger.error('AUCTIONS', 'Error fetching auctions', e);
      if (e is http.ClientException) {
        throw Exception('تعذر الاتصال بالخادم، يرجى التحقق من الاتصال');
      }
      rethrow;
    }
  }

  // ─── Fetch Auction By ID ──────────────────────────────────────────────────
  Future<AuctionModel> fetchAuctionById(int id) async {
    try {
      AppLogger.info('AUCTIONS', 'Fetching auction id=$id...');
      final response = await apiGet('${AppConfig.auctionsEndpoint}/$id');
      AppLogger.network(
        'AUCTIONS',
        response.statusCode,
        '${AppConfig.auctionsEndpoint}/$id',
      );

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body) as Map<String, dynamic>;
        return AuctionModel.fromJson(decoded['data'] as Map<String, dynamic>);
      }
      final body = json.decode(response.body) as Map<String, dynamic>?;
      throwApiError(response.statusCode, body);
    } catch (e) {
      AppLogger.error('AUCTIONS', 'Error fetching auction $id', e);
      if (e is http.ClientException) {
        throw Exception('تعذر الاتصال بالخادم، يرجى التحقق من الاتصال');
      }
      rethrow;
    }
  }

  // ─── Delete Auction ───────────────────────────────────────────────────────
  Future<String?> deleteAuction(int id) async {
    try {
      AppLogger.info('AUCTIONS', 'Deleting auction id=$id...');
      final response = await apiDelete('${AppConfig.auctionsEndpoint}/$id');
      AppLogger.network(
        'AUCTIONS_DELETE',
        response.statusCode,
        '${AppConfig.auctionsEndpoint}/$id',
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        if (response.body.isNotEmpty) {
          try {
            final decoded = json.decode(response.body) as Map<String, dynamic>;
            return decoded['message'] as String?;
          } catch (_) {}
        }
        return 'تم حذف المزاد بنجاح';
      }

      final body = response.body.isNotEmpty
          ? json.decode(response.body) as Map<String, dynamic>?
          : null;
      throwApiError(response.statusCode, body);
    } catch (e) {
      AppLogger.error('AUCTIONS_DELETE', 'Error deleting auction $id', e);
      if (e is http.ClientException) {
        throw Exception('تعذر الاتصال بالخادم، يرجى التحقق من الاتصال');
      }
      rethrow;
    }
  }

  // ─── Paginated Auction Lists ───────────────────────────────────────────────
  Future<AuctionsResponse> _fetchPagedAuctions(
    String endpoint, {
    int page = 1,
    String logTag = 'AUCTIONS',
  }) async {
    try {
      AppLogger.info(logTag, 'Fetching page $page from $endpoint...');
      final response =
          await apiGet('$endpoint?page=$page');
      AppLogger.network(logTag, response.statusCode, endpoint);

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body) as Map<String, dynamic>;
        return AuctionsResponse.fromJson(decoded);
      }
      final body = json.decode(response.body) as Map<String, dynamic>?;
      throwApiError(response.statusCode, body);
    } catch (e) {
      AppLogger.error(logTag, 'Error fetching from $endpoint', e);
      if (e is http.ClientException) {
        throw Exception('تعذر الاتصال بالخادم، يرجى التحقق من الاتصال');
      }
      rethrow;
    }
  }

  Future<AuctionsResponse> fetchPaidAuctions({int page = 1}) =>
      _fetchPagedAuctions(
        '${AppConfig.auctionsEndpoint}/paid',
        page: page,
        logTag: 'AUCTIONS_PAID',
      );

  Future<AuctionsResponse> fetchRepostedAuctions({int page = 1}) =>
      _fetchPagedAuctions(
        '${AppConfig.auctionsEndpoint}/reposted',
        page: page,
        logTag: 'AUCTIONS_REPOSTED',
      );

  Future<AuctionsResponse> fetchClosedAuctions({int page = 1}) =>
      _fetchPagedAuctions(
        '${AppConfig.auctionsEndpoint}/closed',
        page: page,
        logTag: 'AUCTIONS_CLOSED',
      );

  Future<AuctionsResponse> fetchUpcomingAuctions({int page = 1}) =>
      _fetchPagedAuctions(
        '${AppConfig.auctionsEndpoint}/upcoming',
        page: page,
        logTag: 'AUCTIONS_UPCOMING',
      );

  Future<AuctionsResponse> fetchActiveAuctions({int page = 1}) =>
      _fetchPagedAuctions(
        '${AppConfig.auctionsEndpoint}/active',
        page: page,
        logTag: 'AUCTIONS_ACTIVE',
      );

  // ─── Filter Auctions ──────────────────────────────────────────────────────
  Future<AuctionsResponse> fetchFilteredAuctions({
    int page = 1,
    String? status,
    String? startTime,
    String? endTime,
    double? minPrice,
    double? maxPrice,
    String? sortBy,
    String? sortDirection,
  }) async {
    try {
      AppLogger.info('AUCTIONS_FILTER', 'Fetching filtered auctions page $page...');
      final queryParams = <String, String>{'page': page.toString()};
      if (status != null && status.isNotEmpty) queryParams['status'] = status;
      if (startTime != null && startTime.isNotEmpty) {
        queryParams['start_time'] = startTime;
      }
      if (endTime != null && endTime.isNotEmpty) {
        queryParams['end_time'] = endTime;
      }
      if (minPrice != null) queryParams['min_price'] = minPrice.toString();
      if (maxPrice != null) queryParams['max_price'] = maxPrice.toString();
      if (sortBy != null && sortBy.isNotEmpty) queryParams['sort_by'] = sortBy;
      if (sortDirection != null && sortDirection.isNotEmpty) {
        queryParams['sort_direction'] = sortDirection;
      }

      final response = await apiGetWithParams(
        '${AppConfig.auctionsEndpoint}/filter',
        queryParams,
      );
      AppLogger.network(
        'AUCTIONS_FILTER',
        response.statusCode,
        '${AppConfig.auctionsEndpoint}/filter',
      );

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body) as Map<String, dynamic>;
        return AuctionsResponse.fromJson(decoded);
      }
      final body = json.decode(response.body) as Map<String, dynamic>?;
      throwApiError(response.statusCode, body);
    } catch (e) {
      AppLogger.error('AUCTIONS_FILTER', 'Error filtering auctions', e);
      if (e is http.ClientException) {
        throw Exception('تعذر الاتصال بالخادم، يرجى التحقق من الاتصال');
      }
      rethrow;
    }
  }

  // ─── Search Auctions ──────────────────────────────────────────────────────
  Future<AuctionsResponse> searchAuctions({
    required String query,
    int page = 1,
  }) async {
    try {
      if (query.trim().isEmpty) {
        throw Exception('يرجى إدخال كلمة البحث أولاً');
      }

      AppLogger.info('AUCTIONS_SEARCH', 'Searching "$query" page $page...');
      final response = await apiGetWithParams(
        '${AppConfig.auctionsEndpoint}/search',
        {'query': query, 'page': page.toString()},
      );
      AppLogger.network(
        'AUCTIONS_SEARCH',
        response.statusCode,
        '${AppConfig.auctionsEndpoint}/search',
      );

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body) as Map<String, dynamic>;
        return AuctionsResponse.fromJson(decoded);
      } else if (response.statusCode == 404) {
        return AuctionsResponse(
          message: 'لا توجد نتائج',
          auctions: [],
          currentPage: 1,
          total: 0,
        );
      }

      final body = json.decode(response.body) as Map<String, dynamic>?;
      throwApiError(response.statusCode, body);
    } catch (e) {
      AppLogger.error('AUCTIONS_SEARCH', 'Error searching auctions', e);
      if (e is http.ClientException) {
        throw Exception('تعذر الاتصال بالخادم، يرجى التحقق من الاتصال');
      }
      rethrow;
    }
  }

  // ─── Auction Bids ─────────────────────────────────────────────────────────
  Future<List<AuctionBidModel>> fetchAuctionBids(int id) async {
    try {
      AppLogger.info('AUCTIONS', 'Fetching bids for auction id=$id...');
      final response =
          await apiGet('${AppConfig.auctionsEndpoint}/$id/bids');
      AppLogger.network(
        'AUCTIONS_BIDS',
        response.statusCode,
        '${AppConfig.auctionsEndpoint}/$id/bids',
      );

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body) as Map<String, dynamic>;
        final List<dynamic> data = decoded['data'] as List<dynamic>? ?? [];
        return data
            .map((json) =>
                AuctionBidModel.fromJson(json as Map<String, dynamic>))
            .toList();
      }

      final body = json.decode(response.body) as Map<String, dynamic>?;
      throwApiError(response.statusCode, body);
    } catch (e) {
      AppLogger.error('AUCTIONS_BIDS', 'Error fetching bids for $id', e);
      if (e is http.ClientException) {
        throw Exception('تعذر الاتصال بالخادم، يرجى التحقق من الاتصال');
      }
      rethrow;
    }
  }
}
