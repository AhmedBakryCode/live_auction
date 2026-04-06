import 'dio_client.dart';
import 'package:dio/dio.dart';

abstract class ApiService {
  Future<Response> getRequest(String path, {Map<String, dynamic>? queryParameters});
  Future<Response> postRequest(String path, {dynamic data});
}

class ApiServiceImpl implements ApiService {
  final DioClient dioClient;

  ApiServiceImpl(this.dioClient);

  @override
  Future<Response> getRequest(String path, {Map<String, dynamic>? queryParameters}) async {
    return await dioClient.get(path, queryParameters: queryParameters);
  }

  @override
  Future<Response> postRequest(String path, {dynamic data}) async {
    return await dioClient.post(path, data: data);
  }
}
