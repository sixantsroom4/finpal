// core/errors/exceptions.dart
class ServerException implements Exception {
  final String message;
  ServerException([this.message = 'Server Error occurred']);
}

class CacheException implements Exception {
  final String message;
  CacheException([this.message = 'Cache Error occurred']);
}

class NetworkException implements Exception {
  final String message;
  NetworkException([this.message = 'Network Error occurred']);
}

class DatabaseException implements Exception {
  final String message;
  DatabaseException([this.message = 'Database Error occurred']);
}

class AuthException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;

  AuthException(
    this.message, {
    this.code,
    this.originalError,
  });

  @override
  String toString() =>
      'AuthException: $message${code != null ? ' (code: $code)' : ''}';
}
