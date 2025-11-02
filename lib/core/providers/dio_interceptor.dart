import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lite_x/core/constants/server_constants.dart';
import 'package:lite_x/features/auth/repositories/auth_local_repository.dart';
import 'package:lite_x/features/auth/repositories/auth_remote_repository.dart';
import 'package:lite_x/features/auth/view_model/auth_view_model.dart';

final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(BASE_OPTIONS);
  dio.interceptors.add(AuthInterceptor(ref));
  return dio;
});

class AuthInterceptor extends Interceptor {
  final Ref _ref;
  bool _isRefreshing = false;
  final List<Completer<void>> _refreshCompleters = [];
  static final Dio _retryDio = Dio(BASE_OPTIONS)..interceptors.clear();

  AuthInterceptor(this._ref);

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    try {
      // Skip certain endpoints that don't require check of tokens
      if (_shouldSkipAuth(options.path)) {
        return handler.next(options);
      }

      final authLocalRepository_Provider = _ref.read(
        authLocalRepositoryProvider,
      );
      final tokens = authLocalRepository_Provider.getTokens();

      if (tokens == null) {
        return handler.next(options);
      }

      if (tokens.isAccessTokenExpired) {
        if (tokens.isRefreshTokenExpired) {
          print("AuthInterceptor: Refresh token expired, logging out...");
          await _handleLogout();
          return handler.reject(
            DioException(
              requestOptions: options,
              error: 'Session expired. Please login again.',
              type: DioExceptionType.cancel,
            ),
          );
        }

        try {
          await _waitForRefresh();
        } catch (e) {
          print("AuthInterceptor: Refresh failed in onRequest - $e");
          await _handleLogout();
          return handler.reject(
            DioException(
              requestOptions: options,
              error: 'Failed to refresh token. Please login again.',
              type: DioExceptionType.cancel,
            ),
          );
        }

        final updatedTokens = authLocalRepository_Provider.getTokens();
        if (updatedTokens != null && !updatedTokens.isAccessTokenExpired) {
          options.headers['Authorization'] =
              'Bearer ${updatedTokens.accessToken}';
        } else {
          await _handleLogout();
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
    } catch (e, stackTrace) {
      print("AuthInterceptor: Unexpected error in onRequest - $e");
      print("StackTrace: $stackTrace");

      return handler.next(options);
    }
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    try {
      if (err.response?.statusCode == 401) {
        final authLocalRepository_Provider = _ref.read(
          authLocalRepositoryProvider,
        );
        final tokens = authLocalRepository_Provider.getTokens();

        if (tokens == null || tokens.isRefreshTokenExpired) {
          print("AuthInterceptor: Cannot refresh, logging out...");
          await _handleLogout();
          return handler.next(err);
        }

        try {
          await _waitForRefresh();

          final updatedTokens = authLocalRepository_Provider.getTokens();
          if (updatedTokens != null && !updatedTokens.isAccessTokenExpired) {
            final opts = err.requestOptions;
            opts.headers['Authorization'] =
                'Bearer ${updatedTokens.accessToken}';

            try {
              final response = await _retryDio.fetch(opts);
              return handler.resolve(response);
            } catch (retryError) {
              print("AuthInterceptor: Retry request failed - $retryError");
              await _handleLogout();
              return handler.next(err);
            }
          } else {
            await _handleLogout();
            return handler.next(err);
          }
        } catch (e) {
          print("AuthInterceptor: Refresh failed in onError - $e");
          await _handleLogout();
          return handler.next(err);
        }
      }
      return handler.next(err);
    } catch (e, stackTrace) {
      print("AuthInterceptor: Unexpected error in onError - $e");
      print("StackTrace: $stackTrace");
      return handler.next(err);
    }
  }

  // Wait for token refresh to complete
  Future<void> _waitForRefresh() async {
    if (_isRefreshing) {
      final completer = Completer<void>();
      _refreshCompleters.add(completer);
      return completer.future;
    }

    _isRefreshing = true;

    try {
      await _performRefresh().timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw Exception("Token refresh timed out"),
      );

      for (final completer in _refreshCompleters) {
        if (!completer.isCompleted) {
          completer.complete();
        }
      }
    } catch (e, st) {
      for (final completer in _refreshCompleters) {
        if (!completer.isCompleted) {
          completer.completeError(e, st);
        }
      }
      rethrow;
    } finally {
      _isRefreshing = false;
      _refreshCompleters.clear();
    }
  }

  // Perform the actual token refresh
  Future<void> _performRefresh() async {
    print("AuthInterceptor: Starting token refresh...");

    try {
      final authLocalRepository_Provider = _ref.read(
        authLocalRepositoryProvider,
      );
      final authRemoteRepository_Provider = _ref.read(
        authRemoteRepositoryProvider,
      );
      final currentTokens = authLocalRepository_Provider.getTokens();

      if (currentTokens == null) {
        print("AuthInterceptor: No tokens to refresh");
        throw Exception("No tokens available");
      }

      if (currentTokens.isRefreshTokenExpired) {
        print("AuthInterceptor: Refresh token expired");
        await _handleLogout();
        throw Exception("Refresh token expired");
      }

      final result = await authRemoteRepository_Provider.refreshToken(
        currentTokens.refreshToken,
        currentTokens.refreshTokenExpiry,
      );

      await result.fold(
        (failure) async {
          print("AuthInterceptor: Refresh failed - ${failure.message}");
          await _handleLogout();
          throw Exception("Token refresh failed: ${failure.message}");
        },
        (newTokens) async {
          await authLocalRepository_Provider.saveTokens(newTokens);
          print("AuthInterceptor: Token refreshed successfully");
        },
      );
    } catch (e, stackTrace) {
      print("AuthInterceptor: _performRefresh error - $e");
      print("StackTrace: $stackTrace");
      rethrow;
    }
  }

  // Handle logout when tokens are invalid
  Future<void> _handleLogout() async {
    try {
      final authLocalRepository_Provider = _ref.read(
        authLocalRepositoryProvider,
      );
      await authLocalRepository_Provider.clearTokens();
      await authLocalRepository_Provider.clearUser();

      try {
        _ref.invalidate(authViewModelProvider);
      } catch (e) {
        print("AuthInterceptor: Error invalidating provider - $e");
      }

      print("AuthInterceptor: User logged out");
    } catch (e, stackTrace) {
      print("AuthInterceptor: Logout error - $e");
      print("StackTrace: $stackTrace");
    }
  }

  // Check if request should be skipped
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
