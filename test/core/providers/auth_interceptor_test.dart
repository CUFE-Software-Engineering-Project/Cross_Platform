import 'package:dio/dio.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lite_x/core/models/TokensModel.dart';
import 'package:lite_x/core/providers/dio_interceptor.dart';
import 'package:lite_x/features/auth/repositories/auth_local_repository.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'auth_interceptor_test.mocks.dart';

@GenerateMocks([
  AuthLocalRepository,
  Dio,
  RequestInterceptorHandler,
  ErrorInterceptorHandler,
])
void main() {
  late MockAuthLocalRepository mockAuthRepo;
  late MockDio mockRefreshDio;
  late MockRequestInterceptorHandler mockRequestHandler;
  late MockErrorInterceptorHandler mockErrorHandler;
  late ProviderContainer container;
  late AuthInterceptor authInterceptor;
  final setupRefProvider = Provider((ref) => ref);

  TokensModel createTokens({
    bool accessExpired = false,
    bool refreshExpired = false,
  }) {
    final now = DateTime.now();
    return TokensModel(
      accessToken: 'access_token_123',
      refreshToken: 'refresh_token_123',
      accessTokenExpiry: now.add(Duration(minutes: accessExpired ? -10 : 10)),
      refreshTokenExpiry: now.add(Duration(days: refreshExpired ? -1 : 1)),
    );
  }

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    mockAuthRepo = MockAuthLocalRepository();
    mockRefreshDio = MockDio();
    mockRequestHandler = MockRequestInterceptorHandler();
    mockErrorHandler = MockErrorInterceptorHandler();
    container = ProviderContainer(
      overrides: [
        authLocalRepositoryProvider.overrideWithValue(mockAuthRepo),
        refreshDioProvider.overrideWithValue(mockRefreshDio),
        // Don't override authViewModelProvider - let it fail gracefully in tests
      ],
    );
    final ref = container.read(setupRefProvider);
    authInterceptor = AuthInterceptor(ref);
  });

  tearDown(() {
    container.dispose();
  });

  group('AuthInterceptor - onError 401 - Logout Scenarios', () {
    test('logs out when tokens are null on 401', () async {
      final err = DioException(
        requestOptions: RequestOptions(path: '/api/protected'),
        response: Response(
          requestOptions: RequestOptions(path: ''),
          statusCode: 401,
        ),
        type: DioExceptionType.badResponse,
      );

      when(mockAuthRepo.getTokens()).thenReturn(null);
      when(mockAuthRepo.clearTokens()).thenAnswer((_) async {});
      when(mockAuthRepo.clearUser()).thenAnswer((_) async {});

      await authInterceptor.onError(err, mockErrorHandler);

      verify(mockAuthRepo.clearTokens()).called(1);
      verify(mockAuthRepo.clearUser()).called(1);
      verify(mockErrorHandler.next(err)).called(1);
      verifyNever(mockRefreshDio.post(any, data: anyNamed('data')));
    });

    test('logs out when refresh token is expired on 401', () async {
      final err = DioException(
        requestOptions: RequestOptions(path: '/api/protected'),
        response: Response(
          requestOptions: RequestOptions(path: ''),
          statusCode: 401,
        ),
        type: DioExceptionType.badResponse,
      );

      final expiredRefreshTokens = createTokens(
        accessExpired: true,
        refreshExpired: true,
      );

      when(mockAuthRepo.getTokens()).thenReturn(expiredRefreshTokens);
      when(mockAuthRepo.clearTokens()).thenAnswer((_) async {});
      when(mockAuthRepo.clearUser()).thenAnswer((_) async {});

      await authInterceptor.onError(err, mockErrorHandler);

      verify(mockAuthRepo.clearTokens()).called(1);
      verify(mockAuthRepo.clearUser()).called(1);
      verify(mockErrorHandler.next(err)).called(1);
      verifyNever(mockRefreshDio.post(any, data: anyNamed('data')));
    });

    test('logs out when refresh fails on 401', () {
      fakeAsync((async) {
        final err = DioException(
          requestOptions: RequestOptions(path: '/api/protected'),
          response: Response(
            requestOptions: RequestOptions(path: ''),
            statusCode: 401,
          ),
          type: DioExceptionType.badResponse,
        );

        final tokens = createTokens(accessExpired: false);

        when(mockAuthRepo.getTokens()).thenReturn(tokens);
        when(mockAuthRepo.clearTokens()).thenAnswer((_) async {});
        when(mockAuthRepo.clearUser()).thenAnswer((_) async {});

        // Mock refresh to fail
        when(
          mockRefreshDio.post(
            any,
            data: anyNamed('data'),
            options: anyNamed('options'),
          ),
        ).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: ''),
            type: DioExceptionType.badResponse,
          ),
        );

        authInterceptor.onError(err, mockErrorHandler);
        async.elapse(const Duration(seconds: 1));

        verify(mockAuthRepo.clearTokens()).called(greaterThanOrEqualTo(1));
        verify(mockAuthRepo.clearUser()).called(greaterThanOrEqualTo(1));
        verify(mockErrorHandler.next(err)).called(1);
      });
    });

    test('logs out when tokens are invalid after successful refresh', () {
      fakeAsync((async) {
        final err = DioException(
          requestOptions: RequestOptions(path: '/api/protected'),
          response: Response(
            requestOptions: RequestOptions(path: ''),
            statusCode: 401,
          ),
          type: DioExceptionType.badResponse,
        );

        final tokens = createTokens(accessExpired: false);

        int getTokensCalls = 0;
        when(mockAuthRepo.getTokens()).thenAnswer((_) {
          getTokensCalls++;
          // Return tokens initially, then null after refresh
          if (getTokensCalls <= 2) return tokens;
          return null;
        });

        when(mockAuthRepo.clearTokens()).thenAnswer((_) async {});
        when(mockAuthRepo.clearUser()).thenAnswer((_) async {});
        when(mockAuthRepo.saveTokens(any)).thenAnswer((_) async {});

        when(
          mockRefreshDio.post(
            any,
            data: anyNamed('data'),
            options: anyNamed('options'),
          ),
        ).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(path: ''),
            data: {'access_token': 'new_token'},
            statusCode: 200,
          ),
        );

        authInterceptor.onError(err, mockErrorHandler);
        async.elapse(const Duration(seconds: 6));

        verify(mockAuthRepo.clearTokens()).called(greaterThanOrEqualTo(1));
        verify(mockAuthRepo.clearUser()).called(greaterThanOrEqualTo(1));
        verify(mockErrorHandler.next(err)).called(1);
      });
    });

    test('logs out when access token is still expired after refresh', () {
      fakeAsync((async) {
        final err = DioException(
          requestOptions: RequestOptions(path: '/api/protected'),
          response: Response(
            requestOptions: RequestOptions(path: ''),
            statusCode: 401,
          ),
          type: DioExceptionType.badResponse,
        );

        final tokens = createTokens(accessExpired: false);
        final stillExpiredTokens = createTokens(accessExpired: true);

        int getTokensCalls = 0;
        when(mockAuthRepo.getTokens()).thenAnswer((_) {
          getTokensCalls++;
          if (getTokensCalls <= 2) return tokens;
          return stillExpiredTokens;
        });

        when(mockAuthRepo.clearTokens()).thenAnswer((_) async {});
        when(mockAuthRepo.clearUser()).thenAnswer((_) async {});
        when(mockAuthRepo.saveTokens(any)).thenAnswer((_) async {});

        when(
          mockRefreshDio.post(
            any,
            data: anyNamed('data'),
            options: anyNamed('options'),
          ),
        ).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(path: ''),
            data: {'access_token': 'new_token'},
            statusCode: 200,
          ),
        );

        authInterceptor.onError(err, mockErrorHandler);
        async.elapse(const Duration(seconds: 6));

        verify(mockAuthRepo.clearTokens()).called(greaterThanOrEqualTo(1));
        verify(mockAuthRepo.clearUser()).called(greaterThanOrEqualTo(1));
        verify(mockErrorHandler.next(err)).called(1);
      });
    });

    test('logs out when retry request fails with 401', () {
      fakeAsync((async) {
        final err = DioException(
          requestOptions: RequestOptions(path: '/api/protected'),
          response: Response(
            requestOptions: RequestOptions(path: ''),
            statusCode: 401,
          ),
          type: DioExceptionType.badResponse,
        );

        final tokens = createTokens(accessExpired: false);
        final newTokens = createTokens(
          accessExpired: false,
        ).copyWith(accessToken: 'new_tk');

        int getTokensCalls = 0;
        when(mockAuthRepo.getTokens()).thenAnswer((_) {
          getTokensCalls++;
          if (getTokensCalls <= 2) return tokens;
          return newTokens;
        });

        when(mockAuthRepo.clearTokens()).thenAnswer((_) async {});
        when(mockAuthRepo.clearUser()).thenAnswer((_) async {});
        when(mockAuthRepo.saveTokens(any)).thenAnswer((_) async {});

        when(
          mockRefreshDio.post(
            any,
            data: anyNamed('data'),
            options: anyNamed('options'),
          ),
        ).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(path: ''),
            data: {'access_token': 'new_tk'},
            statusCode: 200,
          ),
        );

        // Mock fetch to return 401 again
        when(mockRefreshDio.fetch(any)).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: ''),
            response: Response(
              requestOptions: RequestOptions(path: ''),
              statusCode: 401,
            ),
            type: DioExceptionType.badResponse,
          ),
        );

        authInterceptor.onError(err, mockErrorHandler);
        async.elapse(const Duration(seconds: 6));

        verify(mockAuthRepo.clearTokens()).called(greaterThanOrEqualTo(1));
        verify(mockAuthRepo.clearUser()).called(greaterThanOrEqualTo(1));
        verify(mockErrorHandler.next(err)).called(1);
      });
    });

    test('handles retry request failure with non-401 error', () {
      fakeAsync((async) {
        final err = DioException(
          requestOptions: RequestOptions(path: '/api/protected'),
          response: Response(
            requestOptions: RequestOptions(path: ''),
            statusCode: 401,
          ),
          type: DioExceptionType.badResponse,
        );

        final tokens = createTokens(accessExpired: false);
        final newTokens = createTokens(
          accessExpired: false,
        ).copyWith(accessToken: 'new_tk');

        int getTokensCalls = 0;
        when(mockAuthRepo.getTokens()).thenAnswer((_) {
          getTokensCalls++;
          if (getTokensCalls <= 2) return tokens;
          return newTokens;
        });

        when(mockAuthRepo.saveTokens(any)).thenAnswer((_) async {});

        when(
          mockRefreshDio.post(
            any,
            data: anyNamed('data'),
            options: anyNamed('options'),
          ),
        ).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(path: ''),
            data: {'access_token': 'new_tk'},
            statusCode: 200,
          ),
        );

        // Mock fetch to fail with 500 error
        when(mockRefreshDio.fetch(any)).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: ''),
            response: Response(
              requestOptions: RequestOptions(path: ''),
              statusCode: 500,
            ),
            type: DioExceptionType.badResponse,
          ),
        );

        authInterceptor.onError(err, mockErrorHandler);
        async.elapse(const Duration(seconds: 6));

        verify(mockErrorHandler.next(err)).called(1);
        // Should NOT logout on non-401 errors
        verifyNever(mockAuthRepo.clearTokens());
        verifyNever(mockAuthRepo.clearUser());
      });
    });

    test('handles retry request failure with generic exception', () {
      fakeAsync((async) {
        final err = DioException(
          requestOptions: RequestOptions(path: '/api/protected'),
          response: Response(
            requestOptions: RequestOptions(path: ''),
            statusCode: 401,
          ),
          type: DioExceptionType.badResponse,
        );

        final tokens = createTokens(accessExpired: false);
        final newTokens = createTokens(
          accessExpired: false,
        ).copyWith(accessToken: 'new_tk');

        int getTokensCalls = 0;
        when(mockAuthRepo.getTokens()).thenAnswer((_) {
          getTokensCalls++;
          if (getTokensCalls <= 2) return tokens;
          return newTokens;
        });

        when(mockAuthRepo.saveTokens(any)).thenAnswer((_) async {});

        when(
          mockRefreshDio.post(
            any,
            data: anyNamed('data'),
            options: anyNamed('options'),
          ),
        ).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(path: ''),
            data: {'access_token': 'new_tk'},
            statusCode: 200,
          ),
        );

        // Mock fetch to throw a generic exception
        when(mockRefreshDio.fetch(any)).thenThrow(Exception('Network error'));

        authInterceptor.onError(err, mockErrorHandler);
        async.elapse(const Duration(seconds: 6));

        verify(mockErrorHandler.next(err)).called(1);
        verifyNever(mockAuthRepo.clearTokens());
        verifyNever(mockAuthRepo.clearUser());
      });
    });
  });

  group('AuthInterceptor - onRequest Logout Scenarios', () {
    test('logs out when refresh fails during request', () {
      fakeAsync((async) {
        final options = RequestOptions(path: '/api/user');
        final expiredTokens = createTokens(accessExpired: true);

        when(mockAuthRepo.getTokens()).thenReturn(expiredTokens);
        when(mockAuthRepo.clearTokens()).thenAnswer((_) async {});
        when(mockAuthRepo.clearUser()).thenAnswer((_) async {});

        when(
          mockRefreshDio.post(
            any,
            data: anyNamed('data'),
            options: anyNamed('options'),
          ),
        ).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: ''),
            type: DioExceptionType.connectionTimeout,
          ),
        );

        authInterceptor.onRequest(options, mockRequestHandler);
        async.elapse(const Duration(seconds: 1));

        verify(mockAuthRepo.clearTokens()).called(greaterThanOrEqualTo(1));
        verify(mockAuthRepo.clearUser()).called(greaterThanOrEqualTo(1));
        verify(mockRequestHandler.reject(any)).called(1);
      });
    });

    test('logs out when tokens are invalid after refresh in onRequest', () {
      fakeAsync((async) {
        final options = RequestOptions(path: '/api/user');
        final expiredTokens = createTokens(accessExpired: true);

        int callCount = 0;
        when(mockAuthRepo.getTokens()).thenAnswer((_) {
          callCount++;
          if (callCount <= 2) return expiredTokens;
          return null; // Invalid after refresh
        });

        when(mockAuthRepo.clearTokens()).thenAnswer((_) async {});
        when(mockAuthRepo.clearUser()).thenAnswer((_) async {});
        when(mockAuthRepo.saveTokens(any)).thenAnswer((_) async {});

        when(
          mockRefreshDio.post(
            any,
            data: anyNamed('data'),
            options: anyNamed('options'),
          ),
        ).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(path: ''),
            data: {'access_token': 'new_token'},
            statusCode: 200,
          ),
        );

        authInterceptor.onRequest(options, mockRequestHandler);
        async.elapse(const Duration(seconds: 6));

        verify(mockAuthRepo.clearTokens()).called(greaterThanOrEqualTo(1));
        verify(mockAuthRepo.clearUser()).called(greaterThanOrEqualTo(1));
        verify(mockRequestHandler.reject(any)).called(1);
      });
    });

    test('logs out when access token still expired after refresh', () {
      fakeAsync((async) {
        final options = RequestOptions(path: '/api/user');
        final expiredTokens = createTokens(accessExpired: true);
        final stillExpired = createTokens(accessExpired: true);

        int callCount = 0;
        when(mockAuthRepo.getTokens()).thenAnswer((_) {
          callCount++;
          if (callCount <= 2) return expiredTokens;
          return stillExpired;
        });

        when(mockAuthRepo.clearTokens()).thenAnswer((_) async {});
        when(mockAuthRepo.clearUser()).thenAnswer((_) async {});
        when(mockAuthRepo.saveTokens(any)).thenAnswer((_) async {});

        when(
          mockRefreshDio.post(
            any,
            data: anyNamed('data'),
            options: anyNamed('options'),
          ),
        ).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(path: ''),
            data: {'access_token': 'new_token'},
            statusCode: 200,
          ),
        );

        authInterceptor.onRequest(options, mockRequestHandler);
        async.elapse(const Duration(seconds: 6));

        verify(mockAuthRepo.clearTokens()).called(greaterThanOrEqualTo(1));
        verify(mockAuthRepo.clearUser()).called(greaterThanOrEqualTo(1));
        verify(mockRequestHandler.reject(any)).called(1);
      });
    });
  });

  group('AuthInterceptor - Edge Cases', () {
    test('handles logout with AuthViewModel error gracefully', () async {
      final options = RequestOptions(path: '/api/user');
      final expiredTokens = createTokens(
        accessExpired: true,
        refreshExpired: true,
      );

      when(mockAuthRepo.getTokens()).thenReturn(expiredTokens);
      when(mockAuthRepo.clearTokens()).thenAnswer((_) async {});
      when(mockAuthRepo.clearUser()).thenAnswer((_) async {});

      // AuthViewModel access will throw since we can't properly mock it
      // The code should catch and continue

      await authInterceptor.onRequest(options, mockRequestHandler);

      verify(mockAuthRepo.clearTokens()).called(1);
      verify(mockAuthRepo.clearUser()).called(1);
      verify(mockRequestHandler.reject(any)).called(1);
    });

    test('passes through non-401 errors unchanged', () async {
      final err = DioException(
        requestOptions: RequestOptions(path: '/api/fail'),
        response: Response(
          requestOptions: RequestOptions(path: ''),
          statusCode: 500,
        ),
      );

      await authInterceptor.onError(err, mockErrorHandler);

      verify(mockErrorHandler.next(err)).called(1);
      verifyNever(mockAuthRepo.clearTokens());
      verifyNever(mockAuthRepo.clearUser());
      verifyNever(mockRefreshDio.post(any, data: anyNamed('data')));
    });

    test('passes through errors without response', () async {
      final err = DioException(
        requestOptions: RequestOptions(path: '/api/fail'),
        type: DioExceptionType.connectionTimeout,
      );

      await authInterceptor.onError(err, mockErrorHandler);

      verify(mockErrorHandler.next(err)).called(1);
      verifyNever(mockAuthRepo.clearTokens());
    });
  });
}

extension TokenCopy on TokensModel {
  TokensModel copyWith({
    String? accessToken,
    String? refreshToken,
    DateTime? accessTokenExpiry,
    DateTime? refreshTokenExpiry,
  }) {
    return TokensModel(
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
      accessTokenExpiry: accessTokenExpiry ?? this.accessTokenExpiry,
      refreshTokenExpiry: refreshTokenExpiry ?? this.refreshTokenExpiry,
    );
  }
}
