import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import '../../admin/auth/repositories/auth_repository.dart';
import '../services/token_manager.dart';
import '../utils/app_logger.dart';

class ApiHelper {
  // Global navigator key to allow navigation from anywhere
  static GlobalKey<NavigatorState>? navigatorKey;

  /// Wraps any HTTP request with auto token-refresh on 401.
  static Future<http.Response> requestWithRetry(
    Future<http.Response> Function() requestFn,
  ) async {
    final response = await requestFn();

    if (response.statusCode == 401) {
      AppLogger.warning('API_HELPER', 'Detected 401. Attempting token refresh...');
      final authRepo = AuthRepository();
      final newToken = await authRepo.refreshToken();

      if (newToken != null) {
        AppLogger.info('API_HELPER', 'Token refreshed. Retrying original request...');
        return await requestFn();
      } else {
        AppLogger.error('API_HELPER', 'Token refresh failed. Forcing logout.');
        await TokenManager.clearToken();
        _navigateToLogin();
        throw Exception('انتهت صلاحية الجلسة، يرجى تسجيل الدخول مجدداً');
      }
    }

    return response;
  }

  static void _navigateToLogin() {
    final context = navigatorKey?.currentContext;
    if (context != null) {
      Navigator.of(context).pushNamedAndRemoveUntil(
        '/login',
        (route) => false,
      );
    }
  }
}
