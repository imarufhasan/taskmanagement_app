import 'package:dio/dio.dart';
import 'package:taskmanagement_app/core/constants/api_constants.dart';
import 'package:taskmanagement_app/core/storage/secure_storage_service.dart';

class TokenInterceptor extends QueuedInterceptor {
  final Dio dio;
  final SecureStorageService storage;
  final void Function()? onUnauthorized;

  TokenInterceptor({
    required this.dio,
    required this.storage,
    this.onUnauthorized,
  });

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (!options.headers.containsKey('Authorization')) {
      final token = await storage.getAccessToken();
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }
    options.headers['Content-Type'] = 'application/json';
    return handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final isUnauthorized = err.response?.statusCode == 401;
    final isAuthEndpoint = err.requestOptions.path.contains('/auth/login') ||
        err.requestOptions.path.contains('/auth/register') ||
        err.requestOptions.path.contains('/auth/refresh-token');

    if (isUnauthorized && !isAuthEndpoint) {
      final refreshToken = await storage.getRefreshToken();

      if (refreshToken != null && refreshToken.isNotEmpty) {
        try {
          final refreshDio = Dio(
            BaseOptions(
              baseUrl: ApiConstants.baseUrl,
              connectTimeout: const Duration(seconds: 10),
              receiveTimeout: const Duration(seconds: 10),
            ),
          );

          final response = await refreshDio.post(
            ApiConstants.refreshToken,
            data: {'refreshToken': refreshToken},
          );

          if (response.statusCode == 200 && response.data['status'] == true) {
            final newAccessToken = response.data['accessToken'] ?? response.data['token'];
            final newRefreshToken = response.data['refreshToken'] ?? refreshToken;

            if (newAccessToken != null) {
              await storage.saveTokens(
                accessToken: newAccessToken,
                refreshToken: newRefreshToken,
              );

              final reqOptions = err.requestOptions;
              reqOptions.headers['Authorization'] = 'Bearer $newAccessToken';

              final retryResponse = await dio.fetch(reqOptions);
              return handler.resolve(retryResponse);
            }
          }
        } on DioException catch (refreshErr) {
          final isRefreshInvalid = refreshErr.response?.statusCode == 401 ||
              refreshErr.response?.statusCode == 400 ||
              refreshErr.response?.statusCode == 403;

          // Only wipe session if the server explicitly rejected the refresh token
          if (isRefreshInvalid) {
            await storage.clearAll();
            onUnauthorized?.call();
          }
          return handler.next(err);
        } catch (_) {
          return handler.next(err);
        }
      } else {
        await storage.clearAll();
        onUnauthorized?.call();
      }
    }

    return handler.next(err);
  }
}
