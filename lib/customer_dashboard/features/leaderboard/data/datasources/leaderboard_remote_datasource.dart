import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/leaderboard_model.dart';

abstract class LeaderboardRemoteDataSource {
  Future<LeaderboardDataModel> getLeaderboard();
}

class LeaderboardRemoteDataSourceImpl implements LeaderboardRemoteDataSource {
  final Dio dio;

  LeaderboardRemoteDataSourceImpl(this.dio);

  @override
  Future<LeaderboardDataModel> getLeaderboard() async {
    try {
      final response = await dio.get(ApiConstants.leaderboard);

      if (response.statusCode == 200) {
        return LeaderboardDataModel.fromJson(response.data);
      } else {
        throw ServerException(
          response.data['message'] ?? 'Failed to load leaderboard',
        );
      }
    } on DioException catch (e) {
      throw ServerException(e.message ?? 'Network error');
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
