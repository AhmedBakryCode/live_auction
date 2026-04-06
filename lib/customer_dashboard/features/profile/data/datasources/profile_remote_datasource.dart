import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/user_profile_model.dart';
import '../../domain/entities/user_profile.dart';

abstract class ProfileRemoteDataSource {
  Future<UserProfileModel> getProfile();
  Future<UserProfileModel> updateProfile(UpdateProfileRequest request);
  Future<void> changePassword(ChangePasswordRequest request);
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final Dio dio;

  ProfileRemoteDataSourceImpl(this.dio);

  @override
  Future<UserProfileModel> getProfile() async {
    try {
      final response = await dio.get(ApiConstants.profile);

      if (response.statusCode == 200) {
        return UserProfileModel.fromJson(response.data);
      } else {
        throw ServerException(
          response.data['message'] ?? 'Failed to load profile',
        );
      }
    } on DioException catch (e) {
      throw ServerException(e.message ?? 'Network error');
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<UserProfileModel> updateProfile(UpdateProfileRequest request) async {
    try {
      late dynamic data;

      // Use FormData if profile image is being uploaded
      if (request.profileImage != null && request.profileImage!.isNotEmpty) {
        final formData = FormData.fromMap({
          'fname': request.firstName,
          'lname': request.lastName,
          'phone': request.phone,
          'address': request.address,
          if (request.password != null && request.password!.isNotEmpty) ...{
            'password': request.password,
            'password_confirmation': request.passwordConfirmation,
          },
          'profile_image': await MultipartFile.fromFile(
            request.profileImage!,
            filename: request.profileImage!.split('/').last,
          ),
        });
        data = formData;
      } else {
        // Use JSON if no image
        data = request.toJson();
      }

      final response = await dio.post(ApiConstants.updateProfile, data: data);

      if (response.statusCode == 200) {
        return UserProfileModel.fromJson(response.data);
      } else {
        throw ServerException(
          response.data['message'] ?? 'Failed to update profile',
        );
      }
    } on DioException catch (e) {
      throw ServerException(e.message ?? 'Network error');
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> changePassword(ChangePasswordRequest request) async {
    try {
      final response = await dio.post(
        ApiConstants.changePassword,
        data: request.toJson(),
      );

      if (response.statusCode != 200) {
        throw ServerException(
          response.data['message'] ?? 'Failed to change password',
        );
      }
    } on DioException catch (e) {
      throw ServerException(e.message ?? 'Network error');
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
