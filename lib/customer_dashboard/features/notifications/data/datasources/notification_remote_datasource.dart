import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/notification_model.dart';

abstract class NotificationRemoteDataSource {
  Future<List<NotificationModel>> getNotifications();
  Future<void> markAsRead(String notificationId);
  Future<void> markAllAsRead();
}

class NotificationRemoteDataSourceImpl implements NotificationRemoteDataSource {
  final Dio dio;

  NotificationRemoteDataSourceImpl(this.dio);

  @override
  Future<List<NotificationModel>> getNotifications() async {
    try {
      final response = await dio.get(ApiConstants.notifications);

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data is List 
            ? response.data 
            : (response.data['data'] ?? []);
        return data.map((e) => NotificationModel.fromJson(e)).toList();
      } else {
        throw ServerException(response.data['message'] ?? 'Failed to load notifications');
      }
    } on DioException catch (e) {
      throw ServerException(e.message ?? 'Network error');
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> markAsRead(String notificationId) async {
    try {
      final response = await dio.post(
        ApiConstants.markNotificationAsRead(notificationId),
      );

      if (response.statusCode != 200) {
        throw ServerException(response.data['message'] ?? 'Failed to mark notification as read');
      }
    } on DioException catch (e) {
      throw ServerException(e.message ?? 'Network error');
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> markAllAsRead() async {
    try {
      final response = await dio.post(ApiConstants.markAllNotificationsAsRead);

      if (response.statusCode != 200) {
        throw ServerException(response.data['message'] ?? 'Failed to mark all notifications as read');
      }
    } on DioException catch (e) {
      throw ServerException(e.message ?? 'Network error');
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
