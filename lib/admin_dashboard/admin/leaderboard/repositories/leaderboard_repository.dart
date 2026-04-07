import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/leaderboard_model.dart';
import '../../../core/config/app_config.dart';
import '../../../core/network/api_client.dart';
import '../../../core/utils/app_logger.dart';

class LeaderboardRepository extends ApiClient {
  Future<LeaderboardData> fetchLeaderboard() async {
    try {
      AppLogger.info('LEADERBOARD', 'Fetching leaderboard...');
      final response = await apiGet(AppConfig.leaderboardEndpoint);
      AppLogger.network(
        'LEADERBOARD',
        response.statusCode,
        AppConfig.leaderboardEndpoint,
      );

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body) as Map<String, dynamic>;
        final data = decoded['data'];
        if (data == null) {
          throw Exception('لم يتم العثور على بيانات المتصدرين');
        }
        return LeaderboardData.fromJson(data as Map<String, dynamic>);
      }

      final body = json.decode(response.body) as Map<String, dynamic>?;
      throwApiError(response.statusCode, body);
    } catch (e) {
      AppLogger.error('LEADERBOARD', 'Error fetching leaderboard', e);
      if (e is http.ClientException) {
        throw Exception('تعذر الاتصال بالخادم، يرجى التحقق من الاتصال');
      }
      rethrow;
    }
  }
}
