import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/dashboard_stats.dart';
import '../../../core/config/app_config.dart';
import '../../../core/network/api_client.dart';
import '../../../core/utils/app_logger.dart';

class DashboardRepository extends ApiClient {
  Future<DashboardStats> fetchDashboardStats() async {
    try {
      AppLogger.info('DASHBOARD', 'Fetching dashboard stats...');
      final response = await apiGet(AppConfig.dashboardEndpoint);
      AppLogger.network(
        'DASHBOARD',
        response.statusCode,
        AppConfig.dashboardEndpoint,
      );

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body) as Map<String, dynamic>;
        final statsData = decoded['statistics'] ?? decoded['data'];
        if (statsData == null) {
          throw Exception('لم يتم العثور على بيانات في الاستجابة');
        }
        return DashboardStats.fromJson(statsData as Map<String, dynamic>);
      }

      final body = json.decode(response.body) as Map<String, dynamic>?;
      throwApiError(response.statusCode, body);
    } catch (e) {
      AppLogger.error('DASHBOARD', 'Error fetching stats', e);
      if (e is http.ClientException) {
        throw Exception(
          'تعذر الاتصال بالخادم، يرجى التحقق من الاتصال بالإنترنت',
        );
      }
      rethrow;
    }
  }
}
