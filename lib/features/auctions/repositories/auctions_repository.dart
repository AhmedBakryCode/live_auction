import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/auction_model.dart';
import '../models/auction_bid_model.dart';
import '../../../core/services/token_manager.dart';
import '../../../core/network/api_helper.dart';

class AuctionsRepository {
  final String apiUrl = "http://192.168.1.20:8000/api/auctions";

  Future<Map<String, String>> _getHeaders() async {
    final token = await TokenManager.getToken();
    return {
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  void _handleUnauthenticated(int statusCode) {
    if (statusCode == 401) {
      TokenManager.clearToken();
      throw Exception('انتهت صلاحية الجلسة، يرجى تسجيل الدخول مجدداً');
    }
  }

  Future<AuctionModel> createAuction({
    required String title,
    String? description,
    required String startPrice,
    required String startTime,
    required String endTime,
    String? imagePath,
  }) async {
    try {
      final response = await ApiHelper.requestWithRetry(() async {
        var request = http.MultipartRequest('POST', Uri.parse(apiUrl));
        request.headers.addAll(await _getHeaders());

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
        final streamedResponse = await request.send().timeout(const Duration(seconds: 30));
        return await http.Response.fromStream(streamedResponse);
      });

      print('[API_CREATE_AUCTION] Status Code: ${response.statusCode}');

      final decodedResponse = json.decode(response.body);

      if (response.statusCode == 201) {
        return AuctionModel.fromJson(decodedResponse['data']);
      } else if (response.statusCode == 422) {
        final errors = decodedResponse['errors'] as Map<String, dynamic>?;
        if (errors != null && errors.isNotEmpty) {
          final firstError = errors.values.first;
          if (firstError is List && firstError.isNotEmpty) {
            throw Exception(firstError.first.toString());
          }
        }
        throw Exception(
          decodedResponse['message'] ?? 'خطأ في البيانات المدخلة',
        );
      } else if (response.statusCode == 403) {
        throw Exception('عفواً، ليس لديك صلاحية لإنشاء مزاد');
      } else {
        throw Exception(
          decodedResponse['message'] ??
              'فشل إنشاء المزاد: ${response.statusCode}',
        );
      }
    } catch (e) {
      if (e is http.ClientException) {
        throw Exception('تعذر الاتصال بالخادم، يرجى التحقق من الاتصال');
      }
      rethrow;
    }
  }

  Future<List<AuctionModel>> fetchAuctions() async {
    try {
      print('[API_GET_AUCTIONS] Fetching auctions...');
      final response = await ApiHelper.requestWithRetry(() async {
        return await http
            .get(Uri.parse(apiUrl), headers: await _getHeaders())
            .timeout(const Duration(seconds: 15));
      });

      print('[API_GET_AUCTIONS] Status Code: ${response.statusCode}');

      if (response.statusCode == 200) {
        final decodedResponse = json.decode(response.body);
        final dynamic dataNode = decodedResponse['data'];
        final List<dynamic> auctionsList = dataNode is List
            ? dataNode
            : (dataNode?['data'] as List<dynamic>? ?? []);

        return auctionsList.map((json) => AuctionModel.fromJson(json)).toList();
      } else if (response.statusCode == 500) {
        throw Exception(
          'حدث خطأ في الخادم (500). يرجى المحاولة لاحقاً بعد إصلاح المشكلة التقنية.',
        );
      } else if (response.statusCode == 403) {
        throw Exception('عفواً، ليس لديك صلاحية لعرض المزادات');
      } else {
        final decodedResponse = json.decode(response.body);
        throw Exception(
          decodedResponse['message'] ??
              'فشل جلب المزادات: ${response.statusCode}',
        );
      }
    } catch (e) {
      if (e is http.ClientException) {
        throw Exception(
          'تعذر الاتصال بالخادم، يرجى التحقق من الاتصال المتصل بالإنترنت',
        );
      }
      rethrow;
    }
  }

  Future<AuctionModel> fetchAuctionById(int id) async {
    try {
      print('[API_GET_AUCTION] Fetching auction details for id=$id...');
      final response = await ApiHelper.requestWithRetry(() async {
        return await http
            .get(Uri.parse('$apiUrl/$id'), headers: await _getHeaders())
            .timeout(const Duration(seconds: 15));
      });

      print('[API_GET_AUCTION] Status Code: ${response.statusCode}');

      final decodedResponse = json.decode(response.body);

      if (response.statusCode == 200) {
        return AuctionModel.fromJson(decodedResponse['data']);
      } else if (response.statusCode == 404) {
        throw Exception('المزاد غير موجود أو تم حذفه');
      } else if (response.statusCode == 403) {
        throw Exception('عفواً، ليس لديك صلاحية لعرض بيانات هذا المزاد');
      } else if (response.statusCode == 500) {
        throw Exception(
          'حدث خطأ في الخادم (500). يرجى المحاولة لاحقاً بعد إصلاح المشكلة التقنية.',
        );
      } else {
        throw Exception(
          decodedResponse['message'] ??
              'فشل تحميل بيانات المزاد: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('[API_GET_AUCTION] Error: $e');
      if (e is http.ClientException) {
        throw Exception('تعذر الاتصال بالخادم، يرجى التحقق من الاتصال');
      }
      rethrow;
    }
  }

  Future<String?> deleteAuction(int id) async {
    try {
      print('[API_DELETE_AUCTION] Deleting auction id=$id...');
      final response = await ApiHelper.requestWithRetry(() async {
        return await http
            .delete(Uri.parse('$apiUrl/$id'), headers: await _getHeaders())
            .timeout(const Duration(seconds: 15));
      });

      print('[API_DELETE_AUCTION] Status Code: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 204) {
        if (response.body.isNotEmpty) {
          try {
            final decodedBody = json.decode(response.body);
            return decodedBody['message'];
          } catch (_) {}
        }
        return 'تم حذف المزاد بنجاح';
      } else if (response.statusCode == 404) {
        throw Exception('المزاد غير موجود أو تم حذفه مسبقاً');
      } else if (response.statusCode == 500) {
        throw Exception(
          'حدث خطأ في الخادم (500). يرجى المحاولة لاحقاً بعد إصلاح المشكلة التقنية.',
        );
      } else {
        String msg = 'فشل حذف المزاد: ${response.statusCode}';
        if (response.body.isNotEmpty) {
          try {
            final decodedBody = json.decode(response.body);
            msg = decodedBody['message'] ?? msg;
          } catch (_) {}
        }
        throw Exception(msg);
      }
    } catch (e) {
      print('[API_DELETE_AUCTION] Error: $e');
      if (e is http.ClientException) {
        throw Exception('تعذر الاتصال بالخادم، يرجى التحقق من الاتصال');
      }
      rethrow;
    }
  }

  Future<Map<String, dynamic>> joinAuction(int id) async {
    try {
      print('[API_JOIN_AUCTION] Joining auction id=$id...');
      final response = await ApiHelper.requestWithRetry(() async {
        return await http
            .post(Uri.parse('$apiUrl/join/$id'), headers: await _getHeaders())
            .timeout(const Duration(seconds: 15));
      });

      print('[API_JOIN_AUCTION] Status Code: ${response.statusCode}');

      if (response.body.isNotEmpty) {
        final decodedResponse = json.decode(response.body);
        if (response.statusCode == 200 || response.statusCode == 201) {
          return decodedResponse;
        } else if (response.statusCode == 404) {
          throw Exception('المزاد غير موجود');
        } else if (response.statusCode == 500) {
          throw Exception('حدث خطأ في الخادم (500). يرجى المحاولة لاحقاً.');
        } else {
          throw Exception(
            decodedResponse['message'] ??
                'فشل طلب الانضمام (${response.statusCode})',
          );
        }
      } else {
        if (response.statusCode == 200 || response.statusCode == 204) {
          return {'message': 'تم الانضمام بنجاح', 'auction': true};
        } else {
          throw Exception('فشل طلب الانضمام (${response.statusCode})');
        }
      }
    } catch (e) {
      print('[API_JOIN_AUCTION] Error: $e');
      if (e is http.ClientException) {
        throw Exception('تعذر الاتصال بالخادم، يرجى التحقق من الاتصال');
      }
      rethrow;
    }
  }

  Future<AuctionsResponse> fetchPaidAuctions({int page = 1}) async {
    try {
      print('[API_GET_PAID_AUCTIONS] Fetching paid auctions page $page...');
      final response = await ApiHelper.requestWithRetry(() async {
        return await http.get(
          Uri.parse('$apiUrl/paid?page=$page'),
          headers: await _getHeaders(),
        ).timeout(const Duration(seconds: 15));
      });

      print('[API_GET_PAID_AUCTIONS] Status Code: ${response.statusCode}');

      if (response.statusCode == 200) {
        final decodedResponse = json.decode(response.body);
        return AuctionsResponse.fromJson(decodedResponse);
      } else if (response.statusCode == 403) {
        throw Exception('عفواً، ليس لديك صلاحية لعرض هذه المزادات');
      } else {
        final decodedResponse = json.decode(response.body);
        throw Exception(decodedResponse['message'] ?? 'فشل جلب المزادات المدفوعة: ${response.statusCode}');
      }
    } catch (e) {
      if (e is http.ClientException) {
        throw Exception('تعذر الاتصال بالخادم، يرجى التحقق من الاتصال المتصل بالإنترنت');
      }
      rethrow;
    }
  }

  Future<AuctionsResponse> fetchRepostedAuctions({int page = 1}) async {
    try {
      print('[API_GET_REPOSTED_AUCTIONS] Fetching reposted auctions page $page...');
      final response = await ApiHelper.requestWithRetry(() async {
        return await http.get(
          Uri.parse('$apiUrl/reposted?page=$page'),
          headers: await _getHeaders(),
        ).timeout(const Duration(seconds: 15));
      });

      print('[API_GET_REPOSTED_AUCTIONS] Status Code: ${response.statusCode}');

      if (response.statusCode == 200) {
        final decodedResponse = json.decode(response.body);
        return AuctionsResponse.fromJson(decodedResponse);
      } else if (response.statusCode == 403) {
        throw Exception('عفواً، ليس لديك صلاحية لعرض هذه المزادات');
      } else {
        final decodedResponse = json.decode(response.body);
        throw Exception(decodedResponse['message'] ?? 'فشل جلب المزادات المعاد نشرها: ${response.statusCode}');
      }
    } catch (e) {
      if (e is http.ClientException) {
        throw Exception('تعذر الاتصال بالخادم، يرجى التحقق من الاتصال المتصل بالإنترنت');
      }
      rethrow;
    }
  }

  Future<AuctionsResponse> fetchClosedAuctions({int page = 1}) async {
    try {
      print('[API_GET_CLOSED_AUCTIONS] Fetching closed auctions page $page...');
      final response = await ApiHelper.requestWithRetry(() async {
        return await http.get(
          Uri.parse('$apiUrl/closed?page=$page'),
          headers: await _getHeaders(),
        ).timeout(const Duration(seconds: 15));
      });

      print('[API_GET_CLOSED_AUCTIONS] Status Code: ${response.statusCode}');

      if (response.statusCode == 200) {
        final decodedResponse = json.decode(response.body);
        return AuctionsResponse.fromJson(decodedResponse);
      } else if (response.statusCode == 403) {
        throw Exception('عفواً، ليس لديك صلاحية لعرض هذه المزادات');
      } else {
        final decodedResponse = json.decode(response.body);
        throw Exception(decodedResponse['message'] ?? 'فشل جلب المزادات المغلقة: ${response.statusCode}');
      }
    } catch (e) {
      if (e is http.ClientException) {
        throw Exception('تعذر الاتصال بالخادم، يرجى التحقق من الاتصال المتصل بالإنترنت');
      }
      rethrow;
    }
  }

  Future<AuctionsResponse> fetchUpcomingAuctions({int page = 1}) async {
    try {
      print('[API_GET_UPCOMING_AUCTIONS] Fetching upcoming auctions page $page...');
      final response = await ApiHelper.requestWithRetry(() async {
        return await http.get(
          Uri.parse('$apiUrl/upcoming?page=$page'),
          headers: await _getHeaders(),
        ).timeout(const Duration(seconds: 15));
      });

      print('[API_GET_UPCOMING_AUCTIONS] Status Code: ${response.statusCode}');

      if (response.statusCode == 200) {
        final decodedResponse = json.decode(response.body);
        return AuctionsResponse.fromJson(decodedResponse);
      } else if (response.statusCode == 403) {
        throw Exception('عفواً، ليس لديك صلاحية لعرض هذه المزادات');
      } else {
        final decodedResponse = json.decode(response.body);
        throw Exception(decodedResponse['message'] ?? 'فشل جلب المزادات القادمة: ${response.statusCode}');
      }
    } catch (e) {
      if (e is http.ClientException) {
        throw Exception('تعذر الاتصال بالخادم، يرجى التحقق من الاتصال المتصل بالإنترنت');
      }
      rethrow;
    }
  }

  Future<AuctionsResponse> fetchActiveAuctions({int page = 1}) async {
    try {
      print('[API_GET_ACTIVE_AUCTIONS] Fetching active auctions page $page...');
      final response = await ApiHelper.requestWithRetry(() async {
        return await http.get(
          Uri.parse('$apiUrl/active?page=$page'),
          headers: await _getHeaders(),
        ).timeout(const Duration(seconds: 15));
      });

      print('[API_GET_ACTIVE_AUCTIONS] Status Code: ${response.statusCode}');

      if (response.statusCode == 200) {
        final decodedResponse = json.decode(response.body);
        return AuctionsResponse.fromJson(decodedResponse);
      } else if (response.statusCode == 403) {
        throw Exception('عفواً، ليس لديك صلاحية لعرض هذه المزادات');
      } else {
        final decodedResponse = json.decode(response.body);
        throw Exception(decodedResponse['message'] ?? 'فشل جلب المزادات النشطة: ${response.statusCode}');
      }
    } catch (e) {
      if (e is http.ClientException) {
        throw Exception('تعذر الاتصال بالخادم، يرجى التحقق من الاتصال المتصل بالإنترنت');
      }
      rethrow;
    }
  }

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
      print('[API_GET_FILTERED_AUCTIONS] Fetching page $page...');

      final Map<String, String> queryParams = {'page': page.toString()};
      if (status != null && status.isNotEmpty) queryParams['status'] = status;
      if (startTime != null && startTime.isNotEmpty) queryParams['start_time'] = startTime;
      if (endTime != null && endTime.isNotEmpty) queryParams['end_time'] = endTime;
      if (minPrice != null) queryParams['min_price'] = minPrice.toString();
      if (maxPrice != null) queryParams['max_price'] = maxPrice.toString();
      if (sortBy != null && sortBy.isNotEmpty) queryParams['sort_by'] = sortBy;
      if (sortDirection != null && sortDirection.isNotEmpty) queryParams['sort_direction'] = sortDirection;

      final response = await ApiHelper.requestWithRetry(() async {
        final uri = Uri.parse('$apiUrl/filter').replace(queryParameters: queryParams);
        return await http.get(uri, headers: await _getHeaders()).timeout(const Duration(seconds: 15));
      });

      print('[API_GET_FILTERED_AUCTIONS] Status Code: ${response.statusCode}');

      if (response.statusCode == 200) {
        final decodedResponse = json.decode(response.body);
        return AuctionsResponse.fromJson(decodedResponse);
      } else if (response.statusCode == 403) {
        throw Exception('عفواً، ليس لديك صلاحية للبحث وتصفية المزادات');
      } else {
        final decodedResponse = json.decode(response.body);
        throw Exception(decodedResponse['message'] ?? 'فشل التصفية: ${response.statusCode}');
      }
    } catch (e) {
      if (e is http.ClientException) {
        throw Exception('تعذر الاتصال بالخادم، يرجى التحقق من الاتصال');
      }
      rethrow;
    }
  }

  Future<AuctionsResponse> searchAuctions({required String query, int page = 1}) async {
    try {
      print('[API_SEARCH_AUCTIONS] Searching "$query" page $page...');

      if (query.trim().isEmpty) {
        throw Exception('يرجى إدخال كلمة البحث أولاً');
      }

      final response = await ApiHelper.requestWithRetry(() async {
        final uri = Uri.parse('$apiUrl/search').replace(queryParameters: {
          'query': query,
          'page': page.toString(),
        });
        return await http.get(uri, headers: await _getHeaders()).timeout(const Duration(seconds: 15));
      });

      print('[API_SEARCH_AUCTIONS] Status Code: ${response.statusCode}');

      if (response.statusCode == 200) {
        final decodedResponse = json.decode(response.body);
        return AuctionsResponse.fromJson(decodedResponse);
      } else if (response.statusCode == 403) {
        throw Exception('عفواً، ليس لديك صلاحية للبحث في المزادات');
      } else if (response.statusCode == 404) {
        return AuctionsResponse(
          message: 'لا توجد نتائج', 
          auctions: [], 
          currentPage: 1, 
          total: 0,
        );
      } else {
        final decodedResponse = json.decode(response.body);
        throw Exception(decodedResponse['message'] ?? 'فشل البحث: ${response.statusCode}');
      }
    } catch (e) {
      if (e is http.ClientException) {
        throw Exception('تعذر الاتصال بالخادم، يرجى التحقق من الاتصال');
      }
      rethrow;
    }
  }

  Future<List<AuctionBidModel>> fetchAuctionBids(int id) async {
    try {
      print('[API_GET_AUCTION_BIDS] Fetching bids for auction id=$id...');
      final response = await ApiHelper.requestWithRetry(() async {
        return await http
            .get(Uri.parse('$apiUrl/$id/bids'), headers: await _getHeaders())
            .timeout(const Duration(seconds: 15));
      });

      print('[API_GET_AUCTION_BIDS] Status Code: ${response.statusCode}');

      final decodedResponse = json.decode(response.body);

      if (response.statusCode == 200) {
        final List<dynamic> data = decodedResponse['data'] ?? [];
        return data.map((json) => AuctionBidModel.fromJson(json)).toList();
      } else if (response.statusCode == 404) {
        throw Exception('المزاد غير موجود');
      } else {
        throw Exception(
          decodedResponse['message'] ??
              'فشل تحميل قائمة المزايدات: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('[API_GET_AUCTION_BIDS] Error: $e');
      if (e is http.ClientException) {
        throw Exception('تعذر الاتصال بالخادم، يرجى التحقق من الاتصال');
      }
      rethrow;
    }
  }
}
