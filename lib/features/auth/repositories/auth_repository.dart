import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../../../core/services/token_manager.dart';
import '../../../core/network/api_helper.dart';

class AuthRepository {
  static const String _baseUrl = 'http://192.168.1.20:8000/api/auth';

  Future<Map<String, String>> _getHeaders({bool requiresAuth = true}) async {
    final headers = {'Accept': 'application/json'};
    if (requiresAuth) {
      final token = await TokenManager.getToken();
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }
    return headers;
  }

  // ─── Login ──────────────────────────────────────────────────────────────────
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      print('[API_LOGIN] Logging in: $email');

      final response = await http
          .post(
            Uri.parse('$_baseUrl/login'),
            headers: {
              'Accept': 'application/json',
              'Content-Type': 'application/json',
            },
            body: json.encode({'email': email, 'password': password}),
          )
          .timeout(const Duration(seconds: 15));

      print('[API_LOGIN] Status Code: ${response.statusCode}');

      final decoded = json.decode(response.body);

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
        throw Exception(decoded['message'] ?? 'فشل تسجيل الدخول: ${response.statusCode}');
      }
    } on SocketException {
      throw Exception('تعذر الاتصال بالخادم، يرجى التحقق من الاتصال بالإنترنت');
    } on http.ClientException {
      throw Exception('تعذر الاتصال بالخادم، يرجى التحقق من الاتصال بالإنترنت');
    }
  }

  // ─── Register ───────────────────────────────────────────────────────────────
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
      print('[API_REGISTER] Registering user: $email');

      final request = http.MultipartRequest('POST', Uri.parse('$_baseUrl/register'));
      request.headers['Accept'] = 'application/json';

      request.fields['fname'] = fname;
      request.fields['lname'] = lname;
      request.fields['email'] = email;
      request.fields['password'] = password;
      request.fields['password_confirmation'] = passwordConfirmation;
      request.fields['phone'] = phone;
      request.fields['address'] = address;

      if (imagePath != null && imagePath.isNotEmpty) {
        request.files.add(await http.MultipartFile.fromPath('profile_image', imagePath));
      }

      final streamedResponse = await request.send().timeout(const Duration(seconds: 30));
      final response = await http.Response.fromStream(streamedResponse);

      print('[API_REGISTER] Status Code: ${response.statusCode}');

      final decoded = json.decode(response.body);

      if (response.statusCode == 201) {
        return decoded;
      } else if (response.statusCode == 422) {
        final errors = decoded['errors'] as Map<String, dynamic>?;
        if (errors != null && errors.isNotEmpty) {
          final firstField = errors.values.first;
          final firstMsg = firstField is List ? firstField.first : firstField;
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
          throw Exception('البريد الإلكتروني مسجل بالفعل، يرجى استخدام بريد آخر');
        }
        throw Exception('حدث خطأ في الخادم، يرجى المحاولة لاحقاً');
      } else {
        throw Exception(decoded['message'] ?? 'فشل التسجيل: ${response.statusCode}');
      }
    } on SocketException {
      throw Exception('تعذر الاتصال بالخادم، يرجى التحقق من الاتصال بالإنترنت');
    } on http.ClientException {
      throw Exception('تعذر الاتصال بالخادم، يرجى التحقق من الاتصال بالإنترنت');
    }
  }

  // ─── Fetch Me ───────────────────────────────────────────────────────────────
  Future<Map<String, dynamic>> fetchMe() async {
    try {
      final response = await ApiHelper.requestWithRetry(() async {
        final headers = await _getHeaders();
        return await http
            .get(Uri.parse('$_baseUrl/me'), headers: headers)
            .timeout(const Duration(seconds: 15));
      });

      print('[API_AUTH_ME] Status Code: ${response.statusCode}');
      final decoded = json.decode(response.body);

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

  // ─── Logout ─────────────────────────────────────────────────────────────────
  Future<String> logout() async {
    try {
      final response = await ApiHelper.requestWithRetry(() async {
        final headers = await _getHeaders();
        return await http
            .post(Uri.parse('$_baseUrl/logout'), headers: headers)
            .timeout(const Duration(seconds: 15));
      });

      print('[API_LOGOUT] Status Code: ${response.statusCode}');

      // Always clear local token regardless of API response
      await TokenManager.clearToken();

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        return decoded['message'] ?? 'تم تسجيل الخروج بنجاح';
      } else {
        return 'تم تسجيل الخروج بنجاح';
      }
    } on SocketException {
      await TokenManager.clearToken();
      throw Exception('تعذر الاتصال بالخادم، يرجى التحقق من الاتصال بالإنترنت');
    } on http.ClientException {
      await TokenManager.clearToken();
      throw Exception('تعذر الاتصال بالخادم، يرجى التحقق من الاتصال بالإنترنت');
    }
  }
  // ─── Refresh Token ──────────────────────────────────────────────────────────
  Future<String?> refreshToken() async {
    try {
      print('[API_REFRESH_TOKEN] Refreshing token...');
      final headers = await _getHeaders();

      final response = await http
          .post(Uri.parse('$_baseUrl/refresh-token'), headers: headers)
          .timeout(const Duration(seconds: 15));

      print('[API_REFRESH_TOKEN] Status Code: ${response.statusCode}');

      final decoded = json.decode(response.body);

      if (response.statusCode == 200) {
        final newToken = decoded['data']?['token'] as String?;
        if (newToken != null && newToken.isNotEmpty) {
          await TokenManager.saveToken(newToken);
          print('[API_REFRESH_TOKEN] Token refreshed successfully.');
          return newToken;
        }
      }
      
      // If refresh fails (e.g. 401 deeply expired), clear and force login
      await TokenManager.clearToken();
      return null;
    } catch (e) {
      print('[API_REFRESH_TOKEN] Error: $e');
      await TokenManager.clearToken();
      return null;
    }
  }
}
