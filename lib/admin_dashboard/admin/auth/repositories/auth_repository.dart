import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../../../core/config/app_config.dart';
import '../../../core/services/token_manager.dart';
import '../../../core/network/api_helper.dart';
import '../../../core/utils/app_logger.dart';

class AuthRepository {
  Future<Map<String, String>> _getHeaders({bool requiresAuth = true}) async {
    final headers = <String, String>{'Accept': 'application/json'};
    if (requiresAuth) {
      final token = await TokenManager.getToken();
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }
    return headers;
  }

  // ─── Login ────────────────────────────────────────────────────────────────
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      AppLogger.info('AUTH', 'Logging in: $email');

      final response = await http
          .post(
            Uri.parse(AppConfig.loginEndpoint),
            headers: {
              'Accept': 'application/json',
              'Content-Type': 'application/json',
            },
            body: json.encode({'email': email, 'password': password}),
          )
          .timeout(AppConfig.defaultTimeout);

      AppLogger.network('AUTH_LOGIN', response.statusCode, AppConfig.loginEndpoint);

      final decoded = json.decode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200) {
        final token = decoded['data']?['token'] as String?;
        if (token == null || token.isEmpty) {
          throw Exception('لم يتم استلام رمز المصادقة من السيرفر');
        }
        await TokenManager.saveToken(token);
        return decoded;
      } else if (response.statusCode == 401 || response.statusCode == 422) {
        throw Exception(decoded['message'] ?? 'بيانات الدخول غير صحيحة');
      } else {
        throw Exception(
          decoded['message'] ?? 'فشل تسجيل الدخول: ${response.statusCode}',
        );
      }
    } on SocketException {
      throw Exception('تعذر الاتصال بالخادم، يرجى التحقق من الاتصال بالإنترنت');
    } on http.ClientException {
      throw Exception('تعذر الاتصال بالخادم، يرجى التحقق من الاتصال بالإنترنت');
    }
  }

  // ─── Register ─────────────────────────────────────────────────────────────
  Future<Map<String, dynamic>> register({
    required String fname,
    required String lname,
    required String email,
    required String password,
    required String passwordConfirmation,
    required String phone,
    required String address,
    String? imagePath,
  }) async {
    try {
      AppLogger.info('AUTH', 'Registering user: $email');

      final request = http.MultipartRequest(
        'POST',
        Uri.parse(AppConfig.registerEndpoint),
      );
      request.headers['Accept'] = 'application/json';
      request.fields['fname'] = fname;
      request.fields['lname'] = lname;
      request.fields['email'] = email;
      request.fields['password'] = password;
      request.fields['password_confirmation'] = passwordConfirmation;
      request.fields['phone'] = phone;
      request.fields['address'] = address;

      if (imagePath != null && imagePath.isNotEmpty) {
        request.files.add(
          await http.MultipartFile.fromPath('profile_image', imagePath),
        );
      }

      final streamedResponse =
          await request.send().timeout(AppConfig.uploadTimeout);
      final response = await http.Response.fromStream(streamedResponse);

      AppLogger.network(
        'AUTH_REGISTER',
        response.statusCode,
        AppConfig.registerEndpoint,
      );

      final decoded = json.decode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 201) {
        return decoded;
      } else if (response.statusCode == 422) {
        final errors = decoded['errors'] as Map<String, dynamic>?;
        if (errors != null && errors.isNotEmpty) {
          final firstField = errors.values.first;
          final firstMsg =
              firstField is List ? firstField.first : firstField;
          throw Exception(firstMsg.toString());
        }
        throw Exception(decoded['message'] ?? 'خطأ في البيانات المدخلة');
      } else if (response.statusCode == 409) {
        throw Exception('البريد الإلكتروني مسجل بالفعل');
      } else if (response.statusCode == 500) {
        final body = response.body.toLowerCase();
        if (body.contains('duplicate entry') ||
            body.contains('uniqueconstraintviolation') ||
            body.contains('users_email_unique')) {
          throw Exception(
            'البريد الإلكتروني مسجل بالفعل، يرجى استخدام بريد آخر',
          );
        }
        throw Exception('حدث خطأ في الخادم، يرجى المحاولة لاحقاً');
      } else {
        throw Exception(
          decoded['message'] ?? 'فشل التسجيل: ${response.statusCode}',
        );
      }
    } on SocketException {
      throw Exception('تعذر الاتصال بالخادم، يرجى التحقق من الاتصال بالإنترنت');
    } on http.ClientException {
      throw Exception('تعذر الاتصال بالخادم، يرجى التحقق من الاتصال بالإنترنت');
    }
  }

  // ─── Fetch Me ─────────────────────────────────────────────────────────────
  Future<Map<String, dynamic>> fetchMe() async {
    try {
      final response = await ApiHelper.requestWithRetry(() async {
        final headers = await _getHeaders();
        return await http
            .get(Uri.parse(AppConfig.meEndpoint), headers: headers)
            .timeout(AppConfig.defaultTimeout);
      });

      AppLogger.network('AUTH_ME', response.statusCode, AppConfig.meEndpoint);
      final decoded = json.decode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200) {
        return decoded['data'] as Map<String, dynamic>;
      } else {
        throw Exception(decoded['message'] ?? 'فشل جلب بيانات المستخدم');
      }
    } on SocketException {
      throw Exception('تعذر الاتصال بالخادم، يرجى التحقق من الاتصال بالإنترنت');
    } on http.ClientException {
      throw Exception('تعذر الاتصال بالخادم، يرجى التحقق من الاتصال بالإنترنت');
    }
  }

  // ─── Logout ───────────────────────────────────────────────────────────────
  Future<String> logout() async {
    try {
      final response = await ApiHelper.requestWithRetry(() async {
        final headers = await _getHeaders();
        return await http
            .post(Uri.parse(AppConfig.logoutEndpoint), headers: headers)
            .timeout(AppConfig.defaultTimeout);
      });

      AppLogger.network(
        'AUTH_LOGOUT',
        response.statusCode,
        AppConfig.logoutEndpoint,
      );

      // Always clear local token regardless of API response
      await TokenManager.clearToken();

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body) as Map<String, dynamic>;
        return decoded['message'] ?? 'تم تسجيل الخروج بنجاح';
      }
      return 'تم تسجيل الخروج بنجاح';
    } on SocketException {
      await TokenManager.clearToken();
      throw Exception('تعذر الاتصال بالخادم، يرجى التحقق من الاتصال بالإنترنت');
    } on http.ClientException {
      await TokenManager.clearToken();
      throw Exception('تعذر الاتصال بالخادم، يرجى التحقق من الاتصال بالإنترنت');
    }
  }

  // ─── Refresh Token ────────────────────────────────────────────────────────
  Future<String?> refreshToken() async {
    try {
      AppLogger.info('AUTH', 'Refreshing token...');
      final headers = await _getHeaders();

      final response = await http
          .post(Uri.parse(AppConfig.refreshTokenEndpoint), headers: headers)
          .timeout(AppConfig.defaultTimeout);

      AppLogger.network(
        'AUTH_REFRESH',
        response.statusCode,
        AppConfig.refreshTokenEndpoint,
      );

      final decoded = json.decode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200) {
        final newToken = decoded['data']?['token'] as String?;
        if (newToken != null && newToken.isNotEmpty) {
          await TokenManager.saveToken(newToken);
          AppLogger.info('AUTH', 'Token refreshed successfully.');
          return newToken;
        }
      }

      await TokenManager.clearToken();
      return null;
    } catch (e) {
      AppLogger.error('AUTH_REFRESH', 'Error refreshing token', e);
      await TokenManager.clearToken();
      return null;
    }
  }

  // ─── Update Profile ───────────────────────────────────────────────────────
  Future<Map<String, dynamic>> updateProfile({
    String? fname,
    String? lname,
    String? phone,
    String? address,
    String? password,
    String? passwordConfirmation,
    String? imagePath,
  }) async {
    try {
      AppLogger.info('AUTH', 'Updating profile...');

      final request = http.MultipartRequest(
        'POST',
        Uri.parse(AppConfig.updateProfileEndpoint),
      );

      final headers = await _getHeaders();
      request.headers.addAll(headers);

      // Send ONLY non-empty fields (partial update)
      if (fname != null && fname.isNotEmpty) request.fields['fname'] = fname;
      if (lname != null && lname.isNotEmpty) request.fields['lname'] = lname;
      if (phone != null && phone.isNotEmpty) request.fields['phone'] = phone;
      if (address != null && address.isNotEmpty) request.fields['address'] = address;
      if (password != null && password.isNotEmpty) {
        request.fields['password'] = password;
        request.fields['password_confirmation'] = passwordConfirmation ?? password;
      }

      // Image only if changed
      if (imagePath != null && imagePath.isNotEmpty) {
        request.files.add(
          await http.MultipartFile.fromPath('profile_image', imagePath),
        );
      }

      final streamedResponse = await request.send().timeout(AppConfig.uploadTimeout);
      final response = await http.Response.fromStream(streamedResponse);

      AppLogger.network('AUTH_UPDATE_PROFILE', response.statusCode, AppConfig.updateProfileEndpoint);

      final decoded = json.decode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200) {
        return decoded['data'] as Map<String, dynamic>? ?? decoded;
      } else if (response.statusCode == 422) {
        final errors = decoded['errors'] as Map<String, dynamic>?;
        if (errors != null && errors.isNotEmpty) {
          final firstField = errors.values.first;
          final firstMsg = firstField is List ? firstField.first : firstField;
          throw Exception(firstMsg.toString());
        }
        throw Exception(decoded['message'] ?? 'خطأ في البيانات المدخلة');
      } else if (response.statusCode == 401) {
        await TokenManager.clearToken();
        throw Exception('انتهت صلاحية الجلسة، يرجى تسجيل الدخول مجدداً');
      } else {
        throw Exception(decoded['message'] ?? 'فشل تحديث الملف الشخصي');
      }
    } on SocketException {
      throw Exception('تعذر الاتصال بالخادم، يرجى التحقق من الاتصال بالإنترنت');
    } on http.ClientException {
      throw Exception('تعذر الاتصال بالخادم، يرجى التحقق من الاتصال بالإنترنت');
    }
  }
}
