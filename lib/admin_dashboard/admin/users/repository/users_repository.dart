import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';
import '../../../core/config/app_config.dart';
import '../../../core/network/api_client.dart';
import '../../../core/utils/app_logger.dart';

class UsersRepository extends ApiClient {
  // ─── List Users ───────────────────────────────────────────────────────────
  Future<UsersResponse> fetchUsers({int page = 1}) async {
    try {
      AppLogger.info('USERS', 'Fetching users page $page...');
      final response = await apiGet('${AppConfig.adminUsersEndpoint}?page=$page');
      AppLogger.network('USERS', response.statusCode, AppConfig.adminUsersEndpoint);

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body) as Map<String, dynamic>;
        return UsersResponse.fromJson(decoded);
      }

      final body = json.decode(response.body) as Map<String, dynamic>?;
      throwApiError(response.statusCode, body);
    } catch (e) {
      AppLogger.error('USERS', 'Error fetching users', e);
      if (e is http.ClientException) {
        throw Exception('تعذر الاتصال بالخادم، يرجى التحقق من الاتصال');
      }
      rethrow;
    }
  }

  // ─── Create User ──────────────────────────────────────────────────────────
  Future<UserModel> createUser({
    required String fname,
    required String lname,
    required String email,
    required String password,
    required String passwordConfirmation,
    String? phone,
    String? address,
    String? imagePath,
  }) async {
    try {
      final headers = await getJsonHeaders();
      final request = http.MultipartRequest(
        'POST',
        Uri.parse(AppConfig.adminUsersEndpoint),
      );
      request.headers.addAll(headers);

      request.fields['fname'] = fname;
      request.fields['lname'] = lname;
      request.fields['email'] = email;
      request.fields['password'] = password;
      request.fields['password_confirmation'] = passwordConfirmation;
      if (phone != null) request.fields['phone'] = phone;
      if (address != null) request.fields['address'] = address;

      if (imagePath != null && imagePath.isNotEmpty) {
        request.files.add(
          await http.MultipartFile.fromPath('profile_image', imagePath),
        );
      }

      final streamed =
          await request.send().timeout(AppConfig.uploadTimeout);
      final response = await http.Response.fromStream(streamed);

      AppLogger.network(
        'USERS_CREATE',
        response.statusCode,
        AppConfig.adminUsersEndpoint,
      );

      final decoded = json.decode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 201) {
        return UserModel.fromJson(decoded['data'] as Map<String, dynamic>);
      } else if (response.statusCode == 422) {
        final firstError = extractValidationError(decoded);
        throw Exception(
          firstError ?? decoded['message'] ?? 'خطأ في البيانات المدخلة',
        );
      }

      final errorMsg =
          decoded['message'] ?? 'فشل إنشاء المستخدم: ${response.statusCode}';
      if (errorMsg.contains('Duplicate entry') &&
          errorMsg.contains('users_email_unique')) {
        throw Exception(
          'هذا البريد الإلكتروني مسجل مسبقاً، يرجى استخدام بريد آخر.',
        );
      }
      throw Exception(errorMsg);
    } catch (e) {
      AppLogger.error('USERS_CREATE', 'Error creating user', e);
      if (e is http.ClientException) {
        throw Exception('تعذر الاتصال بالخادم، يرجى التحقق من الاتصال');
      }
      rethrow;
    }
  }

  // ─── Fetch Single User ────────────────────────────────────────────────────
  Future<UserModel> fetchUserById(int id) async {
    try {
      AppLogger.info('USERS', 'Fetching user id=$id...');
      final response = await apiGet('${AppConfig.adminUsersEndpoint}/$id');
      AppLogger.network('USERS', response.statusCode, '${AppConfig.adminUsersEndpoint}/$id');

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body) as Map<String, dynamic>;
        return UserModel.fromJson(decoded['data'] as Map<String, dynamic>);
      }

      final body = json.decode(response.body) as Map<String, dynamic>?;
      throwApiError(response.statusCode, body);
    } catch (e) {
      AppLogger.error('USERS', 'Error fetching user $id', e);
      if (e is http.ClientException) {
        throw Exception('تعذر الاتصال بالخادم، يرجى التحقق من الاتصال');
      }
      rethrow;
    }
  }

  // ─── Delete User ──────────────────────────────────────────────────────────
  Future<bool> deleteUser(int id) async {
    try {
      AppLogger.info('USERS', 'Deleting user id=$id...');
      final response = await apiDelete('${AppConfig.adminUsersEndpoint}/$id');
      AppLogger.network('USERS_DELETE', response.statusCode, '${AppConfig.adminUsersEndpoint}/$id');

      if (response.statusCode == 200 || response.statusCode == 204) {
        return true;
      } else if (response.statusCode == 500) {
        final body = response.body.toLowerCase();
        if (body.contains('integrity constraint violation') ||
            body.contains('1451 cannot delete or update a parent row')) {
          throw Exception(
            'لا يمكن حذف هذا المستخدم نظراً لارتباطه ببيانات أخرى في النظام.',
          );
        }
        throw Exception('حدث خطأ في الخادم أثناء محاولة الحذف.');
      }

      final body = json.decode(response.body) as Map<String, dynamic>?;
      throwApiError(response.statusCode, body);
    } catch (e) {
      AppLogger.error('USERS_DELETE', 'Error deleting user $id', e);
      if (e is http.ClientException) {
        throw Exception('تعذر الاتصال بالخادم، يرجى التحقق من الاتصال');
      }
      rethrow;
    }
  }

  // ─── Update User ──────────────────────────────────────────────────────────
  Future<UserModel> updateUser(
    int id, {
    String? fname,
    String? lname,
    String? email,
    String? password,
    String? passwordConfirmation,
    String? phone,
    String? address,
    String? imagePath,
  }) async {
    try {
      AppLogger.info('USERS', 'Updating user id=$id...');
      final headers = await getJsonHeaders();
      
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('${AppConfig.adminUsersEndpoint}/$id'),
      );
      request.headers.addAll(headers);

      if (fname != null && fname.isNotEmpty) request.fields['fname'] = fname;
      if (lname != null && lname.isNotEmpty) request.fields['lname'] = lname;
      if (email != null && email.isNotEmpty) request.fields['email'] = email;
      if (password != null && password.isNotEmpty) {
        request.fields['password'] = password;
        request.fields['password_confirmation'] = passwordConfirmation ?? password;
      }
      if (phone != null && phone.isNotEmpty) request.fields['phone'] = phone;
      if (address != null && address.isNotEmpty) request.fields['address'] = address;

      if (imagePath != null && imagePath.isNotEmpty) {
        request.files.add(
          await http.MultipartFile.fromPath('profile_image', imagePath),
        );
      }

      final streamed = await request.send().timeout(AppConfig.uploadTimeout);
      final response = await http.Response.fromStream(streamed);

      AppLogger.network('USERS_UPDATE', response.statusCode, '${AppConfig.adminUsersEndpoint}/$id');

      final decoded = json.decode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200) {
        return UserModel.fromJson(decoded['data'] as Map<String, dynamic>? ?? decoded);
      } else if (response.statusCode == 422) {
        final firstError = extractValidationError(decoded);
        throw Exception(firstError ?? decoded['message'] ?? 'خطأ في البيانات المدخلة');
      } else if (response.statusCode == 404) {
        throw Exception('المستخدم غير موجود أو تم حذفه');
      }

      final errorMsg = decoded['message'] ?? 'فشل تحديث المستخدم: ${response.statusCode}';
      if (errorMsg.contains('Duplicate entry') && errorMsg.contains('users_email_unique')) {
        throw Exception('هذا البريد الإلكتروني مسجل مسبقاً، يرجى استخدام بريد آخر.');
      }
      throw Exception(errorMsg);
    } catch (e) {
      AppLogger.error('USERS_UPDATE', 'Error updating user $id', e);
      if (e is http.ClientException) {
        throw Exception('تعذر الاتصال بالخادم، يرجى التحقق من الاتصال');
      }
      rethrow;
    }
  }

}
