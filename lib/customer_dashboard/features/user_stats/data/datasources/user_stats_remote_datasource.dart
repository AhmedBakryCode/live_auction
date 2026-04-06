import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/user_stats_model.dart';

abstract class UserStatsRemoteDataSource {
  Future<UserStatsModel> getUserStats();
}

class UserStatsRemoteDataSourceImpl implements UserStatsRemoteDataSource {
  final Dio dio;

  UserStatsRemoteDataSourceImpl(this.dio);

  @override
  Future<UserStatsModel> getUserStats() async {
    try {
      final response = await dio.get(ApiConstants.userStats);

      if (response.statusCode == 200) {
        return UserStatsModel.fromJson(response.data);
      } else {
        throw ServerException(response.data['message'] ?? 'Failed to load user stats');
      }
    } on DioException catch (e) {
      throw ServerException(e.message ?? 'Network error');
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
