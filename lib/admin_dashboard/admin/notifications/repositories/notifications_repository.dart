import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/notification_model.dart';
import '../../../core/config/app_config.dart';
import '../../../core/network/api_client.dart';
import '../../../core/utils/app_logger.dart';

class NotificationsRepository extends ApiClient {
  Future<List<NotificationModel>> fetchNotifications() async {
    try {
      AppLogger.info('NOTIFICATIONS', 'Fetching notifications...');
      final response = await apiGet(AppConfig.notificationsEndpoint);
      AppLogger.network(
        'NOTIFICATIONS',
        response.statusCode,
        AppConfig.notificationsEndpoint,
      );

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body) as Map<String, dynamic>;
        final List<dynamic> data = decoded['data'] as List<dynamic>? ?? [];
        return data
            .map(
              (json) =>
                  NotificationModel.fromJson(json as Map<String, dynamic>),
            )
            .toList();
      }

      final body = json.decode(response.body) as Map<String, dynamic>?;
      throwApiError(response.statusCode, body);
    } catch (e) {
      AppLogger.error('NOTIFICATIONS', 'Error fetching notifications', e);
      if (e is http.ClientException) {
        throw Exception('تعذر الاتصال بالخادم، يرجى التحقق من الاتصال');
      }
      rethrow;
    }
  }

  // ─── Mark As Read ─────────────────────────────────────────────────────────
  Future<String> markAsRead(int id) async {
    try {
      AppLogger.info('NOTIFICATIONS', 'Marking notification $id as read...');
      final response = await apiPostJson(
        '${AppConfig.notificationsEndpoint}/$id/read',
        {},
      );
      AppLogger.network(
        'NOTIFICATIONS_READ',
        response.statusCode,
        '${AppConfig.notificationsEndpoint}/$id/read',
      );

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body) as Map<String, dynamic>;
        return decoded['message'] as String? ?? 'تم تعليم الإشعار كمقروء';
      } else if (response.statusCode == 404) {
        throw Exception('الإشعار غير موجود');
      }
      final body = json.decode(response.body) as Map<String, dynamic>?;
      throwApiError(response.statusCode, body);
    } catch (e) {
      AppLogger.error('NOTIFICATIONS', 'Error marking notification $id as read', e);
      if (e is http.ClientException) {
        throw Exception('تعذر الاتصال بالخادم، يرجى التحقق من الاتصال');
      }
      rethrow;
    }
  }

  // ─── Mark All As Read ─────────────────────────────────────────────────────
  Future<String> markAllAsRead() async {
    try {
      AppLogger.info('NOTIFICATIONS', 'Marking all notifications as read...');
      final response = await apiPostJson(AppConfig.readAllNotificationsEndpoint, {});
      AppLogger.network(
        'NOTIFICATIONS_READ_ALL',
        response.statusCode,
        AppConfig.readAllNotificationsEndpoint,
      );

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body) as Map<String, dynamic>;
        return decoded['message'] as String? ?? 'تم تعليم جميع الإشعارات كمقروءة';
      }
      final body = json.decode(response.body) as Map<String, dynamic>?;
      throwApiError(response.statusCode, body);
    } catch (e) {
      AppLogger.error('NOTIFICATIONS', 'Error marking all as read', e);
      if (e is http.ClientException) {
        throw Exception('تعذر الاتصال بالخادم، يرجى التحقق من الاتصال');
      }
      rethrow;
    }
  }

  // ─── Unread Count ─────────────────────────────────────────────────────────
  Future<int> fetchUnreadCount() async {
    try {
      AppLogger.info('NOTIFICATIONS', 'Fetching unread count...');
      final response = await apiGet(AppConfig.unreadNotificationsEndpoint);
      AppLogger.network(
        'NOTIFICATIONS_UNREAD',
        response.statusCode,
        AppConfig.unreadNotificationsEndpoint,
      );

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body) as Map<String, dynamic>;
        final data = decoded['data'] as Map<String, dynamic>?;
        return (data?['count'] as num?)?.toInt() ?? 0;
      }
      return 0;
    } catch (e) {
      AppLogger.error('NOTIFICATIONS', 'Error fetching unread count', e);
      return 0; // Fail silently for badge count
    }
  }
}
