import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../services/token_manager.dart';
import '../config/app_config.dart';
import 'api_helper.dart';

/// Base HTTP client shared by ALL repositories.
/// Eliminates the duplicated `_getHeaders()` and error-handling
/// boilerplate that was copy-pasted across every repository.
abstract class ApiClient {
  // ─── Headers ──────────────────────────────────────────────────────────────

  /// Returns standard JSON headers, optionally including the Bearer token.
  Future<Map<String, String>> getJsonHeaders({bool requiresAuth = true}) async {
    final headers = <String, String>{'Accept': 'application/json'};
    if (requiresAuth) {
      final token = await TokenManager.getToken();
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }
    return headers;
  }

  /// Returns JSON headers + Content-Type for JSON body requests.
  Future<Map<String, String>> getJsonBodyHeaders({bool requiresAuth = true}) async {
    final headers = await getJsonHeaders(requiresAuth: requiresAuth);
    headers['Content-Type'] = 'application/json';
    return headers;
  }

  // ─── Request Wrappers ────────────────────────────────────────────────────

  Future<http.Response> apiGet(String url) async {
    return ApiHelper.requestWithRetry(() async {
      final headers = await getJsonHeaders();
      return await http
          .get(Uri.parse(url), headers: headers)
          .timeout(AppConfig.defaultTimeout);
    });
  }

  Future<http.Response> apiGetWithParams(
    String url,
    Map<String, String> queryParams,
  ) async {
    return ApiHelper.requestWithRetry(() async {
      final headers = await getJsonHeaders();
      final uri = Uri.parse(url).replace(queryParameters: queryParams);
      return await http
          .get(uri, headers: headers)
          .timeout(AppConfig.defaultTimeout);
    });
  }

  Future<http.Response> apiPostJson(
    String url,
    Map<String, dynamic> body,
  ) async {
    return ApiHelper.requestWithRetry(() async {
      final headers = await getJsonBodyHeaders();
      return await http
          .post(Uri.parse(url), headers: headers, body: json.encode(body))
          .timeout(AppConfig.defaultTimeout);
    });
  }

  Future<http.Response> apiDelete(String url) async {
    return ApiHelper.requestWithRetry(() async {
      final headers = await getJsonHeaders();
      return await http
          .delete(Uri.parse(url), headers: headers)
          .timeout(AppConfig.defaultTimeout);
    });
  }

  // ─── Error Handling ───────────────────────────────────────────────────────

  /// Throws a user-friendly Arabic error for a failed HTTP status code.
  Never throwApiError(int statusCode, Map<String, dynamic>? body) {
    final serverMessage = body?['message'] as String?;
    switch (statusCode) {
      case 401:
        TokenManager.clearToken();
        throw Exception('انتهت صلاحية الجلسة، يرجى تسجيل الدخول مجدداً');
      case 403:
        throw Exception(serverMessage ?? 'عفواً، ليس لديك صلاحية للوصول');
      case 404:
        throw Exception(serverMessage ?? 'العنصر المطلوب غير موجود');
      case 422:
        throw Exception(serverMessage ?? 'خطأ في البيانات المدخلة');
      case 500:
        throw Exception('حدث خطأ في الخادم، يرجى المحاولة لاحقاً');
      default:
        throw Exception(
          serverMessage ?? 'حدث خطأ غير متوقع (كود: $statusCode)',
        );
    }
  }

  /// Re-throws socket/client exceptions as Arabic network error messages.
  Never throwNetworkError(Object e) {
    if (e is SocketException || e is http.ClientException) {
      throw Exception(
        'تعذر الاتصال بالخادم، يرجى التحقق من الاتصال بالإنترنت',
      );
    }
    // ignore: only_throw_errors
    throw e;
  }

  /// Extracts the first validation error message from a 422 response.
  String? extractValidationError(Map<String, dynamic>? body) {
    final errors = body?['errors'] as Map<String, dynamic>?;
    if (errors != null && errors.isNotEmpty) {
      final firstEntry = errors.values.first;
      if (firstEntry is List && firstEntry.isNotEmpty) {
        return firstEntry.first.toString();
      }
    }
    return null;
  }
}
