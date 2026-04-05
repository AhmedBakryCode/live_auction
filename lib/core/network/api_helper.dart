import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../features/auth/repositories/auth_repository.dart';
import '../services/token_manager.dart';

class ApiHelper {
  // A helper to wrap requests with auto-refresh on 401 logic
  static Future<http.Response> requestWithRetry(
    Future<http.Response> Function() requestFn,
  ) async {
    final response = await requestFn();

    if (response.statusCode == 401) {
      print('[API_HELPER] Detected 401. Attempting Refresh Token...');
      // Try refreshing the token because the current one is expired
      final authRepo = AuthRepository();
      final newToken = await authRepo.refreshToken();

      if (newToken != null) {
        print('[API_HELPER] Token Refreshed. Retrying original request...');
        // Retry the original request after refreshing the token
        return await requestFn();
      } else {
        print('[API_HELPER] Token Refresh failed. Forcing logout.');
        await TokenManager.clearToken();
        throw Exception('انتهت صلاحية الجلسة، يرجى تسجيل الدخول مجدداً');
      }
    }

    return response;
  }
}
