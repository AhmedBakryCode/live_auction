class ServerException implements Exception {
  final String? message;
  ServerException([this.message]);
}

class CacheException implements Exception {}

class NetworkException implements Exception {}

class UnauthorisedException implements Exception {
  final String? message;
  UnauthorisedException([this.message]);
}

class BadRequestException implements Exception {
  final String? message;
  BadRequestException([this.message]);
}
