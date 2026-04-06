import 'package:dio/dio.dart';
import '../services/local_storage_service.dart';

class AuthInterceptor extends Interceptor {
  final LocalStorageService localStorageService;

  AuthInterceptor(this.localStorageService);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await localStorageService.getToken();
    
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    
    return handler.next(options);
  }
}
