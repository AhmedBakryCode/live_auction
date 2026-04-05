import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/services/token_manager.dart';
import '../../../core/network/api_helper.dart';
import '../models/user_bid_model.dart';

class BidsRepository {
  final String apiUrl = "http://192.168.1.20:8000/api/user/bids";

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

  Future<List<UserBidModel>> fetchUserBids() async {
    try {
      print('[API_BIDS] Fetching user bids...');
      final response = await ApiHelper.requestWithRetry(() async {
        final headers = await _getHeaders();
        return await http.get(
          Uri.parse(apiUrl),
          headers: headers,
        ).timeout(const Duration(seconds: 15));
      });

      print('[API_BIDS] Status Code: ${response.statusCode}');
      
      _handleUnauthenticated(response.statusCode);

      if (response.statusCode == 200) {
        final decodedResponse = json.decode(response.body);
        final List<dynamic> data = decodedResponse['data'] ?? [];
        return data.map((json) => UserBidModel.fromJson(json)).toList();
      } else {
        final body = json.decode(response.body);
        throw Exception(body['message'] ?? 'Failed to load user bids: ${response.statusCode}');
      }
    } catch (e) {
      print('[API_BIDS] Error: $e');
      if (e is http.ClientException) {
        throw Exception('تعذر الاتصال بالخادم، يرجى التحقق من الاتصال');
      }
      rethrow;
    }
  }
}
