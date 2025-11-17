// auth_remote_repository_test.dart

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lite_x/features/auth/repositories/auth_remote_repository.dart';
import 'package:mockito/annotations.dart';
import 'package:lite_x/core/classes/AppFailure.dart';
import 'package:lite_x/core/models/TokensModel.dart';
import 'package:lite_x/core/models/usermodel.dart';
import 'package:mockito/mockito.dart';
import 'auth_remote_repository_test.mocks.dart';

@GenerateMocks([Dio])
void main() {
  late MockDio mockDio;
  late AuthRemoteRepository authRepository;
  setUp(() {
    mockDio = MockDio();
    authRepository = AuthRemoteRepository(dio: mockDio);
  });
  group('login', () {
    const testEmail = 'test@example.com';
    const testPassword = 'password123';
    final userMap = {
      'id': '1',
      'name': 'Test User',
      'email': testEmail,
      'username': 'testuser',
    };
    final tokensMap = {
      'Token': 'fake_access_token_123456789',
      'Refresh_token': 'fake_refresh_token_123456789',
    };

    final apiResponse = {'user': userMap, ...tokensMap};

    final userModel = UserModel.fromMap(userMap);
    final tokensModel = TokensModel.fromMap_login(apiResponse);

    test(
      'should return (UserModel, TokensModel) on successful login',
      () async {
        when(
          mockDio.post(
            'api/auth/login',
            data: {'email': testEmail, 'password': testPassword},
          ),
        ).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(path: 'api/auth/login'),
            data: apiResponse,
            statusCode: 200,
          ),
        );

        final result = await authRepository.login(
          email: testEmail,
          password: testPassword,
        );

        expect(result.isRight(), true);
        result.fold(
          (failure) => fail(
            'Test failed: Should have returned Right, but got Left($failure)',
          ),
          (successData) {
            final (user, tokens) = successData;
            expect(user, userModel);
            expect(tokens.accessToken, tokensModel.accessToken);
            expect(tokens.refreshToken, tokensModel.refreshToken);
          },
        );
        verify(
          mockDio.post(
            'api/auth/login',
            data: {'email': testEmail, 'password': testPassword},
          ),
        ).called(1);
      },
    );

    test('should return AppFailure on DioException', () async {
      when(
        mockDio.post(
          'api/auth/login',
          data: {'email': testEmail, 'password': testPassword},
        ),
      ).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: 'api/auth/login'),
          message: 'Connection error',
        ),
      );

      final result = await authRepository.login(
        email: testEmail,
        password: testPassword,
      );

      expect(result.isLeft(), true);

      result.fold(
        (failure) {
          expect(failure, isA<AppFailure>());
          expect(failure.message, 'Login failed');
        },
        (successData) =>
            fail('Test failed: Should have returned Left, but got Right'),
      );
    });

    test(
      'should return AppFailure with "Wrong Password" on generic exception',
      () async {
        when(
          mockDio.post(
            'api/auth/login',
            data: {'email': testEmail, 'password': testPassword},
          ),
        ).thenThrow(Exception(' error'));

        final result = await authRepository.login(
          email: testEmail,
          password: testPassword,
        );

        result.fold((failure) {
          expect(failure.message, 'Wrong Password');
        }, (successData) => fail('Test failed: Should have returned Left'));
      },
    );
  });
}
