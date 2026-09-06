import 'package:dio/dio.dart';
import 'package:ipo/core/constants/api_endpoints.dart';
import 'package:ipo/core/services/secure_storage_service.dart';
import 'package:ipo/core/network/auth_interceptor.dart';
import 'package:ipo/core/network/api_exception.dart';

class DioClient {
  late final Dio dio;

  DioClient(SecureStorageService storage) {
    dio = Dio(
      BaseOptions(
        baseUrl: ApiEndpoints.baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    dio.interceptors.add(AuthInterceptor(storage));
    dio.interceptors.add(LogInterceptor(
      requestBody: false,
      responseBody: false,
      error: true,
    ));
  }

  ApiException handleDioError(DioException error) {
    if (error.response != null && error.response?.data is Map) {
      final data = error.response!.data as Map;
      final msg = data['message']?.toString();
      if (msg != null && msg.isNotEmpty) {
        return ApiException(message: msg, statusCode: error.response?.statusCode);
      }
    }

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
        return ApiException(message: 'Connection timed out. Please check your network.');
      case DioExceptionType.connectionError:
        return ApiException(message: 'Unable to connect to server. Please try again later.');
      default:
        return ApiException(
          message: error.message ?? 'An unexpected network error occurred.',
          statusCode: error.response?.statusCode,
        );
    }
  }
}
