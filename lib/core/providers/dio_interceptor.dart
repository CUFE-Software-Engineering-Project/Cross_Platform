import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:lite_x/core/constants/server_constants.dart';
import 'package:lite_x/core/models/TokensModel.dart';
import 'package:lite_x/features/auth/repositories/auth_local_repository.dart';
import 'package:lite_x/features/auth/view_model/auth_view_model.dart';

final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(BASE_OPTIONS);
  dio.interceptors.add(AuthInterceptor(ref));
  return dio;
});

final refreshDioProvider = Provider<Dio>((ref) {
  return Dio(BASE_OPTIONS);
});

class AuthInterceptor extends Interceptor {
  final Ref _ref;
  bool _isRefreshing = false;
  final List<Completer<bool>> _refreshCompleters = [];

  static const _deviceIdStorageKey = 'device_id';
  static const _deviceIdHeader = 'x-device-id';
  static const _uuid = Uuid();

  AuthInterceptor(this._ref);

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Some backend routes require a device identifier. Postman may include this
    // via headers/environment, while the app may not.
    // Send a stable per-install id on every request.
    try {
      final deviceId = await _getOrCreateDeviceId();
      options.headers[_deviceIdHeader] = deviceId;
    } catch (e) {
      // Do not block network calls if persistence fails.
      print('AuthInterceptor: Failed to set device id header - $e');
    }

    if (_shouldSkipAuth(options.path)) {
      return handler.next(options);
    }

    final authLocalRepository = _ref.read(authLocalRepositoryProvider);
    final tokens = authLocalRepository.getTokens();
    if (tokens == null) {
      print("AuthInterceptor: No tokens found");
      return handler.next(options);
    }
    if (tokens.isAccessTokenExpired) {
      if (tokens.isRefreshTokenExpired) {
        print("AuthInterceptor: Refresh token expired");
        await _handlelogout();
        return handler.reject(
          DioException(
            requestOptions: options,
            error: 'Session expired. Please login again.',
            type: DioExceptionType.cancel,
          ),
        );
      }
      final refreshSuccess = await _waitForRefresh();

      if (!refreshSuccess) {
        print("AuthInterceptor: Token refresh failed");
        await _handlelogout();
        return handler.reject(
          DioException(
            requestOptions: options,
            error: 'Failed to refresh token. Please login again.',
            type: DioExceptionType.cancel,
          ),
        );
      }
      final updatedTokens = authLocalRepository.getTokens();
      if (updatedTokens != null && !updatedTokens.isAccessTokenExpired) {
        options.headers['Authorization'] =
            'Bearer ${updatedTokens.accessToken}';
        print("AuthInterceptor: Using refreshed token");
      } else {
        print("AuthInterceptor: No valid tokens after refresh");
        await _handlelogout();
        return handler.reject(
          DioException(
            requestOptions: options,
            error: 'Failed to refresh token. Please login again.',
            type: DioExceptionType.cancel,
          ),
        );
      }
    } else {
      options.headers['Authorization'] = 'Bearer ${tokens.accessToken}';
    }

    return handler.next(options);
  }

  Future<String> _getOrCreateDeviceId() async {
    final prefs = await SharedPreferences.getInstance();
    final existing = prefs.getString(_deviceIdStorageKey);
    if (existing != null && existing.trim().isNotEmpty) {
      return existing;
    }

    final created = _uuid.v4();
    await prefs.setString(_deviceIdStorageKey, created);
    return created;
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode == 401) {
      print("AuthInterceptor: 401 error detected");

      final authLocalRepository = _ref.read(authLocalRepositoryProvider);
      final tokens = authLocalRepository.getTokens();
      if (tokens == null || tokens.isRefreshTokenExpired) {
        print("AuthInterceptor: Cannot refresh");
        await _handlelogout();
        return handler.next(err);
      }
      final refreshSuccess = await _waitForRefresh();

      if (!refreshSuccess) {
        print("AuthInterceptor: Retry failed");
        await _handlelogout();
        return handler.next(err);
      }

      final updatedTokens = authLocalRepository.getTokens();
      if (updatedTokens != null && !updatedTokens.isAccessTokenExpired) {
        print("AuthInterceptor: Retrying request");

        try {
          final opts = err.requestOptions;
          opts.headers['Authorization'] = 'Bearer ${updatedTokens.accessToken}';
          final retryDio = _ref.read(refreshDioProvider);
          final response = await retryDio.fetch(opts);
          return handler.resolve(response);
        } catch (e) {
          print("AuthInterceptor: Retry request failed - $e");
          if (e is DioException && e.response?.statusCode == 401) {
            print("AuthInterceptor: Retry got 401, logging out");
            await _handlelogout();
          }
          return handler.next(err);
        }
      } else {
        print("AuthInterceptor: No valid tokens after refresh");
        await _handlelogout();
        return handler.next(err);
      }
    }
    return handler.next(err);
  }

  Future<bool> _waitForRefresh() async {
    if (_isRefreshing) {
      print("AuthInterceptor: Refresh in progress, waiting...");
      final completer = Completer<bool>();
      _refreshCompleters.add(completer);
      final result = await completer.future;
      print("AuthInterceptor: Refresh completed with result: $result");
      return result;
    } else {
      _isRefreshing = true;
      bool success = false;

      success = await _performRefresh();

      _isRefreshing = false;

      for (final completer in _refreshCompleters) {
        if (!completer.isCompleted) {
          completer.complete(success);
        }
      }
      _refreshCompleters.clear();

      return success;
    }
  }

  Future<bool> _performRefresh() async {
    print("AuthInterceptor: Starting token refresh...");

    final authLocalRepository = _ref.read(authLocalRepositoryProvider);
    final currentTokens = authLocalRepository.getTokens();

    if (currentTokens == null) {
      print("AuthInterceptor: No tokens to refresh");
      return false;
    }

    if (currentTokens.isRefreshTokenExpired) {
      print("AuthInterceptor: Refresh token expired");
      await _handlelogout();
      return false;
    }

    final refreshDio = _ref.read(refreshDioProvider);

    try {
      final response = await refreshDio.post(
        'api/auth/refresh',
        data: {'refresh_token': currentTokens.refreshToken},
        options: Options(headers: {'Content-Type': 'application/json'}),
      );

      final newAccessToken = response.data['access_token'] as String?;
      if (newAccessToken == null) {
        print(
          "AuthInterceptor: Refresh response did not contain new access token",
        );
        return false;
      }

      final newTokens = TokensModel(
        accessToken: newAccessToken,
        refreshToken: currentTokens.refreshToken,
        accessTokenExpiry: DateTime.now().add(const Duration(minutes: 60)),
        refreshTokenExpiry: currentTokens.refreshTokenExpiry,
      );

      await authLocalRepository.saveTokens(newTokens);
      print("AuthInterceptor: Token refreshed successfully");
      return true;
    } on DioException catch (e) {
      print("AuthInterceptor: Refresh failed - ${e.message}");
      await _handlelogout();
      return false;
    } catch (e) {
      print("AuthInterceptor: Refresh failed - $e");
      return false;
    }
  }

  Future<void> _handlelogout() async {
    try {
      final authLocalRepo = _ref.read(authLocalRepositoryProvider);
      await authLocalRepo.clearTokens();
      await authLocalRepo.clearUser();

      try {
        _ref.read(authViewModelProvider.notifier).resetState();
      } catch (e) {
        print("AuthInterceptor: Error resetting AuthViewModel state - $e");
      }

      print("AuthInterceptor: User logged out");
    } catch (e, stackTrace) {
      print("AuthInterceptor: Logout error - $e");
      print("StackTrace: $stackTrace");
    }
  }

  bool _shouldSkipAuth(String path) {
    const skipPaths = [
      'auth/signup',
      'auth/verify-signup',
      'auth/finalize_signup',
      'auth/login',
      'auth/refresh',
      'auth/getUser',
      'auth/forget-password',
      'auth/verify-reset-code',
      'auth/reset-password',
    ];
    return skipPaths.any((skipPath) => path.contains(skipPath));
  }
}
