import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/dashboard_stats.dart';
import '../../../core/services/token_manager.dart';
import '../../../core/network/api_helper.dart';

class DashboardRepository {
  final String apiUrl = "http://192.168.1.20:8000/api/admin/dashboard";

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

  Future<DashboardStats> fetchDashboardStats() async {
    try {
      print('[API_DASHBOARD] Fetching dashboard stats...');
      final response = await ApiHelper.requestWithRetry(() async {
        final headers = await _getHeaders();
        return await http.get(
          Uri.parse(apiUrl),
          headers: headers,
        ).timeout(const Duration(seconds: 15));
      });

      print('[API_DASHBOARD] Status Code: ${response.statusCode}');
      
      _handleUnauthenticated(response.statusCode);

      if (response.statusCode == 200) {
        final decodedResponse = json.decode(response.body);
        final statsData = decodedResponse['statistics'] ?? decodedResponse['data'];

        if (statsData == null) {
          throw Exception('No dashboard data found in the response');
        }

        return DashboardStats.fromJson(statsData);
      } else if (response.statusCode == 403) {
        print('[API_DASHBOARD] 403 Forbidden Body: ${response.body}');
        throw Exception('عفواً، ليس لديك صلاحية الوصول إلى هذه الصفحة');
      } else {
        throw Exception('Failed to load dashboard stats: ${response.statusCode}');
      }
    } catch (e) {
      print('[API_DASHBOARD] Error: $e');
      if (e is http.ClientException) {
        throw Exception('تعذر الاتصال بالخادم، يرجى التحقق من الاتصال');
      }
      rethrow;
    }
  }
}
