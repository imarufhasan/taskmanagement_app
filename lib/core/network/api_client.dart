import 'package:dio/dio.dart';
import 'package:taskmanagement_app/core/constants/api_constants.dart';
import 'package:taskmanagement_app/core/network/api_exceptions.dart';
import 'package:taskmanagement_app/core/network/token_interceptor.dart';
import 'package:taskmanagement_app/core/storage/secure_storage_service.dart';

class ApiClient {
  late final Dio dio;
  final SecureStorageService storage;
  void Function()? onUnauthorized;

  ApiClient({
    required this.storage,
    this.onUnauthorized,
  }) {
    dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(seconds: 8),
        receiveTimeout: const Duration(seconds: 8),
        sendTimeout: const Duration(seconds: 8),
      ),
    );

    dio.interceptors.add(
      TokenInterceptor(
        dio: dio,
        storage: storage,
        onUnauthorized: () => onUnauthorized?.call(),
      ),
    );
  }

  void updateBaseUrl() {
    dio.options.baseUrl = ApiConstants.baseUrl;
  }

  Future<dynamic> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await dio.get(path, queryParameters: queryParameters);
      return response.data;
    } on DioException catch (e) {
      _handleDioError(e);
    }
  }

  Future<dynamic> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await dio.post(path, data: data, queryParameters: queryParameters);
      return response.data;
    } on DioException catch (e) {
      _handleDioError(e);
    }
  }

  Future<dynamic> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await dio.put(path, data: data, queryParameters: queryParameters);
      return response.data;
    } on DioException catch (e) {
      _handleDioError(e);
    }
  }

  Future<dynamic> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await dio.delete(path, data: data, queryParameters: queryParameters);
      return response.data;
    } on DioException catch (e) {
      _handleDioError(e);
    }
  }

  Never _handleDioError(DioException e) {
    String message = 'An unexpected error occurred';
    int? statusCode = e.response?.statusCode;
    dynamic data = e.response?.data;

    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout) {
      message = 'Connection timed out. Please check your internet connection.';
    } else if (e.type == DioExceptionType.connectionError) {
      message = 'Cannot connect to server at ${ApiConstants.baseUrl}. Ensure server is running and reachable.';
    } else if (e.response != null) {
      if (data is Map && data['message'] != null) {
        message = data['message'].toString();
      } else {
        message = 'Server responded with status $statusCode';
      }
    }

    throw ApiException(
      message: message,
      statusCode: statusCode,
      data: data,
    );
  }
}
