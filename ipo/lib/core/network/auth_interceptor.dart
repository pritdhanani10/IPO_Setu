import 'package:dio/dio.dart';
import 'package:ipo/core/services/secure_storage_service.dart';

class AuthInterceptor extends Interceptor {
  final SecureStorageService _storage;

  AuthInterceptor(this._storage);

  @override
  Future<void> onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await _storage.getToken();
    final userId = await _storage.getUserId();

    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
      options.headers['X-Firebase-Token'] = token;
    }
    if (userId != null) {
      options.headers['X-User-Id'] = userId;
    }

    return handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    return handler.next(err);
  }
}
