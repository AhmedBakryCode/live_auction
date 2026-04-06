import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> login({required String email, required String password});

  Future<UserModel> register({
    required String email,
    required String password,
    required String name,
    String? phone,
  });

  Future<void> logout();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio dio;

  AuthRemoteDataSourceImpl(this.dio);

  @override
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    try {
      debugPrint('🔵 LOGIN API CALL STARTING...');
      debugPrint('🔵 URL: ${ApiConstants.baseUrl}${ApiConstants.login}');
      debugPrint('🔵 EMAIL: $email');

      final response = await dio.post(
        ApiConstants.login,
        data: {'email': email, 'password': password},
      );

      debugPrint('🟢 RESPONSE STATUS: ${response.statusCode}');
      debugPrint('🟢 RESPONSE DATA: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return UserModel.fromJson(response.data);
      } else {
        throw ServerException(response.data['message'] ?? 'Login failed');
      }
    } on DioException catch (e) {
      debugPrint('🔴 DIO ERROR: ${e.message}');
      debugPrint('🔴 ERROR TYPE: ${e.type}');
      if (e.response != null) {
        debugPrint('🔴 RESPONSE STATUS: ${e.response?.statusCode}');
        debugPrint('🔴 RESPONSE DATA: ${e.response?.data}');
      }
      if (e.response?.statusCode == 401) {
        throw UnauthorisedException(
          e.response?.data['message'] ?? 'Invalid credentials',
        );
      } else if (e.response?.statusCode == 400) {
        throw BadRequestException(
          e.response?.data['message'] ?? 'Invalid request',
        );
      }
      throw ServerException(e.message);
    } catch (e) {
      debugPrint('🔴 UNEXPECTED ERROR: $e');
      throw ServerException(e.toString());
    }
  }

  @override
  Future<UserModel> register({
    required String email,
    required String password,
    required String name,
    String? phone,
  }) async {
    try {
      final response = await dio.post(
        ApiConstants.register,
        data: {
          'email': email,
          'password': password,
          'name': name,
          if (phone != null) 'phone': phone,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return UserModel.fromJson(response.data['data'] ?? response.data);
      } else {
        throw ServerException(
          response.data['message'] ?? 'Registration failed',
        );
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        throw BadRequestException(
          e.response?.data['message'] ?? 'Invalid request',
        );
      }
      throw ServerException(e.message);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> logout() async {
    try {
      await dio.post(ApiConstants.logout);
    } on DioException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
