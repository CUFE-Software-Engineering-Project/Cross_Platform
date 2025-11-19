// auth_remote_repository_test.dart

// ignore_for_file: unused_local_variable

import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lite_x/core/classes/PickedImage.dart';
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
  group('create (signup)', () {
    const testName = 'AserMohamed';
    const testEmail = 'asermohamed@gmail.com';
    const testDateOfBirth = '2004-11-11';

    test('should return success message on successful signup', () async {
      final apiResponse = {'message': 'Verification email sent'};

      when(
        mockDio.post(
          'api/auth/signup',
          data: {
            'name': testName,
            'email': testEmail,
            'dateOfBirth': testDateOfBirth,
          },
        ),
      ).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: 'api/auth/signup'),
          data: apiResponse,
          statusCode: 201,
        ),
      );

      final result = await authRepository.create(
        name: testName,
        email: testEmail,
        dateOfBirth: testDateOfBirth,
      );

      expect(result.isRight(), true);
      result.fold(
        (failure) => fail(
          'Test failed: Should have returned Right, but got Left($failure)',
        ),
        (message) {
          expect(message, 'Verification email sent');
        },
      );

      verify(
        mockDio.post(
          'api/auth/signup',
          data: {
            'name': testName,
            'email': testEmail,
            'dateOfBirth': testDateOfBirth,
          },
        ),
      ).called(1);
    });

    test('should return default message when message is missing', () async {
      final apiResponse = {};

      when(
        mockDio.post(
          'api/auth/signup',
          data: {
            'name': testName,
            'email': testEmail,
            'dateOfBirth': testDateOfBirth,
          },
        ),
      ).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: 'api/auth/signup'),
          data: apiResponse,
          statusCode: 201,
        ),
      );

      final result = await authRepository.create(
        name: testName,
        email: testEmail,
        dateOfBirth: testDateOfBirth,
      );

      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Test failed: Should have returned Right'),
        (message) {
          expect(message, 'Verification email sent');
        },
      );
    });

    test('should return AppFailure on DioException', () async {
      when(
        mockDio.post(
          'api/auth/signup',
          data: {
            'name': testName,
            'email': testEmail,
            'dateOfBirth': testDateOfBirth,
          },
        ),
      ).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: 'api/auth/signup'),
          message: 'Network error',
        ),
      );

      final result = await authRepository.create(
        name: testName,
        email: testEmail,
        dateOfBirth: testDateOfBirth,
      );

      expect(result.isLeft(), true);
      result.fold((failure) {
        expect(failure, isA<AppFailure>());
        expect(failure.message, 'Signup failed');
      }, (message) => fail('Test failed: Should have returned Left'));

      verify(
        mockDio.post(
          'api/auth/signup',
          data: {
            'name': testName,
            'email': testEmail,
            'dateOfBirth': testDateOfBirth,
          },
        ),
      ).called(1);
    });

    test('should return AppFailure on generic exception', () async {
      when(
        mockDio.post(
          'api/auth/signup',
          data: {
            'name': testName,
            'email': testEmail,
            'dateOfBirth': testDateOfBirth,
          },
        ),
      ).thenThrow(Exception('Unexpected error'));

      final result = await authRepository.create(
        name: testName,
        email: testEmail,
        dateOfBirth: testDateOfBirth,
      );

      expect(result.isLeft(), true);
      result.fold((failure) {
        expect(failure, isA<AppFailure>());
        expect(failure.message, contains('Exception'));
      }, (message) => fail('Test failed: Should have returned Left'));
    });
  });

  group('verifySignupEmail', () {
    const testEmail = 'test@example.com';
    const testCode = '123456';

    test('should return success message on successful verification', () async {
      final apiResponse = {'message': 'Verified successfully'};

      when(
        mockDio.post(
          'api/auth/verify-signup',
          data: {'email': testEmail, 'code': testCode},
        ),
      ).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: 'api/auth/verify-signup'),
          data: apiResponse,
          statusCode: 200,
        ),
      );

      final result = await authRepository.verifySignupEmail(
        email: testEmail,
        code: testCode,
      );

      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Test failed: Should have returned Right'),
        (message) {
          expect(message, 'Verified successfully');
        },
      );

      verify(
        mockDio.post(
          'api/auth/verify-signup',
          data: {'email': testEmail, 'code': testCode},
        ),
      ).called(1);
    });

    test('should return default message when message is missing', () async {
      final apiResponse = {};

      when(
        mockDio.post(
          'api/auth/verify-signup',
          data: {'email': testEmail, 'code': testCode},
        ),
      ).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: 'api/auth/verify-signup'),
          data: apiResponse,
          statusCode: 200,
        ),
      );

      final result = await authRepository.verifySignupEmail(
        email: testEmail,
        code: testCode,
      );

      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Test failed: Should have returned Right'),
        (message) {
          expect(message, 'Verified successfully');
        },
      );
    });

    test('should return AppFailure on DioException', () async {
      when(
        mockDio.post(
          'api/auth/verify-signup',
          data: {'email': testEmail, 'code': testCode},
        ),
      ).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: 'api/auth/verify-signup'),
          message: 'Invalid code',
        ),
      );

      final result = await authRepository.verifySignupEmail(
        email: testEmail,
        code: testCode,
      );

      expect(result.isLeft(), true);
      result.fold((failure) {
        expect(failure, isA<AppFailure>());
        expect(failure.message, 'Email verification failed');
      }, (message) => fail('Test failed: Should have returned Left'));

      verify(
        mockDio.post(
          'api/auth/verify-signup',
          data: {'email': testEmail, 'code': testCode},
        ),
      ).called(1);
    });

    test('should return AppFailure on generic exception', () async {
      when(
        mockDio.post(
          'api/auth/verify-signup',
          data: {'email': testEmail, 'code': testCode},
        ),
      ).thenThrow(Exception('Network timeout'));

      final result = await authRepository.verifySignupEmail(
        email: testEmail,
        code: testCode,
      );

      expect(result.isLeft(), true);
      result.fold((failure) {
        expect(failure, isA<AppFailure>());
        expect(failure.message, contains('Exception'));
      }, (message) => fail('Test failed: Should have returned Left'));
    });
  });

  group('signup (finalize)', () {
    const testEmail = 'asermohamed@gmail.com';
    const testPassword = 'ASERMOHAMED123***aaa';

    final userMap = {
      'id': '1',
      'name': 'Test User',
      'email': testEmail,
      'username': 'testuser',
      'dateOfBirth': '1990-01-01',
      'isEmailVerified': true,
      'isVerified': false,
    };

    final tokensMap = {
      'accessToken': 'fake_access_token_123456789',
      'refreshToken': 'fake_refresh_token_123456789',
    };

    final apiResponse = {'user': userMap, 'tokens': tokensMap};

    test(
      'should return (UserModel, TokensModel) on successful finalization',
      () async {
        when(
          mockDio.post(
            'api/auth/finalize_signup',
            data: {'email': testEmail, 'password': testPassword},
          ),
        ).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(path: 'api/auth/finalize_signup'),
            data: apiResponse,
            statusCode: 200,
          ),
        );

        final result = await authRepository.signup(
          email: testEmail,
          password: testPassword,
        );

        expect(result.isRight(), true);
        result.fold(
          (failure) => fail('Test failed: Should have returned Right'),
          (successData) {
            final (user, tokens) = successData;
            expect(user, isA<UserModel>());
            expect(user.email, testEmail);
            expect(user.name, 'Test User');
            expect(tokens, isA<TokensModel>());

            expect(tokens.accessToken, 'fake_access_token_123456789');
            expect(tokens.refreshToken, 'fake_refresh_token_123456789');
          },
        );
      },
    );

    test('should return AppFailure on DioException', () async {
      when(
        mockDio.post(
          'api/auth/finalize_signup',
          data: {'email': testEmail, 'password': testPassword},
        ),
      ).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: 'api/auth/finalize_signup'),
          message: 'Server error',
        ),
      );

      final result = await authRepository.signup(
        email: testEmail,
        password: testPassword,
      );

      expect(result.isLeft(), true);
      result.fold((failure) {
        expect(failure, isA<AppFailure>());
        expect(failure.message, 'Signup failed');
      }, (successData) => fail('Test failed: Should have returned Left'));

      verify(
        mockDio.post(
          'api/auth/finalize_signup',
          data: {'email': testEmail, 'password': testPassword},
        ),
      ).called(1);
    });

    test('should return AppFailure on generic exception', () async {
      when(
        mockDio.post(
          'api/auth/finalize_signup',
          data: {'email': testEmail, 'password': testPassword},
        ),
      ).thenThrow(Exception('Parse error'));

      final result = await authRepository.signup(
        email: testEmail,
        password: testPassword,
      );

      expect(result.isLeft(), true);
      result.fold((failure) {
        expect(failure, isA<AppFailure>());
        expect(failure.message, contains('Exception'));
      }, (successData) => fail('Test failed: Should have returned Left'));
    });

    test('should handle malformed response data', () async {
      final malformedResponse = {
        'user': {'id': '1'},
        'tokens': {},
      };

      when(
        mockDio.post(
          'api/auth/finalize_signup',
          data: {'email': testEmail, 'password': testPassword},
        ),
      ).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: 'api/auth/finalize_signup'),
          data: malformedResponse,
          statusCode: 200,
        ),
      );

      final result = await authRepository.signup(
        email: testEmail,
        password: testPassword,
      );

      expect(result.isLeft(), true);
      result.fold((failure) {
        expect(failure, isA<AppFailure>());
      }, (successData) => fail('Test failed: Should have returned Left'));
    });
  });
  group('login', () {
    const testEmail = 'asermohamed@gmail.com';
    const testPassword = 'ASERMOHAMED123***aaa';
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

  group('updateUsername', () {
    const testUsername = 'Aser_Mohamed_2025';
    final currentUser = UserModel(
      id: '1',
      name: 'Test User',
      email: 'test@example.com',
      username: 'oldusername',
      dob: '1990-01-01',
      isEmailVerified: false,
      isVerified: false,
    );

    final apiResponse = {
      'user': {'username': testUsername},
      'tokens': {'access': 'new_access_token', 'refresh': 'new_refresh_token'},
    };

    test('should return updated UserModel and new tokens', () async {
      when(
        mockDio.put(
          'api/auth/update_username',
          data: {'username': testUsername},
        ),
      ).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: 'api/auth/update_username'),
          data: apiResponse,
          statusCode: 200,
        ),
      );

      final result = await authRepository.updateUsername(
        currentUser: currentUser,
        Username: testUsername,
      );

      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Test failed: Should have returned Right'),
        (successData) {
          final (user, tokens) = successData;
          expect(user.username, testUsername);
          expect(user.id, currentUser.id);
          expect(user.email, currentUser.email);
          expect(tokens.accessToken, 'new_access_token');
          expect(tokens.refreshToken, 'new_refresh_token');
        },
      );
    });

    test('should return AppFailure on DioException', () async {
      when(
        mockDio.put(
          'api/auth/update_username',
          data: {'username': testUsername},
        ),
      ).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: 'api/auth/update_username'),
          message: 'Username already taken',
        ),
      );

      final result = await authRepository.updateUsername(
        currentUser: currentUser,
        Username: testUsername,
      );

      expect(result.isLeft(), true);
      result.fold((failure) {
        expect(failure, isA<AppFailure>());
        expect(failure.message, 'Failed to update username');
      }, (successData) => fail('Test failed: Should have returned Left'));
    });

    test('should return AppFailure on generic exception', () async {
      when(
        mockDio.put(
          'api/auth/update_username',
          data: {'username': testUsername},
        ),
      ).thenThrow(Exception('Parse error'));

      final result = await authRepository.updateUsername(
        currentUser: currentUser,
        Username: testUsername,
      );

      expect(result.isLeft(), true);
      result.fold((failure) {
        expect(failure, isA<AppFailure>());
        expect(failure.message, contains('Exception'));
      }, (successData) => fail('Test failed: Should have returned Left'));
    });
  });

  group('forget_password', () {
    const testEmail = 'asermohamed@gmail.com';

    test('should return success message', () async {
      final apiResponse = {'message': 'Reset code sent'};

      when(
        mockDio.post('api/auth/forget-password', data: {'email': testEmail}),
      ).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: 'api/auth/forget-password'),
          data: apiResponse,
        ),
      );

      final result = await authRepository.forget_password(email: testEmail);

      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Test failed: Should have returned Right'),
        (message) {
          expect(message, 'Reset code sent');
        },
      );
    });

    test('should return default message when message is missing', () async {
      final apiResponse = {};

      when(
        mockDio.post('api/auth/forget-password', data: {'email': testEmail}),
      ).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: 'api/auth/forget-password'),
          data: apiResponse,
        ),
      );

      final result = await authRepository.forget_password(email: testEmail);

      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Test failed: Should have returned Right'),
        (message) {
          expect(message, 'Reset code sent');
        },
      );
    });

    test('should return AppFailure on DioException', () async {
      when(
        mockDio.post('api/auth/forget-password', data: {'email': testEmail}),
      ).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: 'api/auth/forget-password'),
          message: 'Email not found',
        ),
      );

      final result = await authRepository.forget_password(email: testEmail);

      expect(result.isLeft(), true);
      result.fold((failure) {
        expect(failure, isA<AppFailure>());
        expect(failure.message, 'Forget password failed');
      }, (message) => fail('Test failed: Should have returned Left'));
    });

    test('should return AppFailure on generic exception', () async {
      when(
        mockDio.post('api/auth/forget-password', data: {'email': testEmail}),
      ).thenThrow(Exception('Network error'));

      final result = await authRepository.forget_password(email: testEmail);

      expect(result.isLeft(), true);
      result.fold((failure) {
        expect(failure, isA<AppFailure>());
        expect(failure.message, contains('Exception'));
      }, (message) => fail('Test failed: Should have returned Left'));
    });
  });

  group('verify_reset_code', () {
    const testEmail = 'asermohamed@gmail.com';
    const testCode = '123456';

    test('should return success message', () async {
      final apiResponse = {'message': 'Reset code verified'};

      when(
        mockDio.post(
          'api/auth/verify-reset-code',
          data: {'email': testEmail, 'code': testCode},
        ),
      ).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: 'api/auth/verify-reset-code'),
          data: apiResponse,
          statusCode: 200,
        ),
      );

      final result = await authRepository.verify_reset_code(
        email: testEmail,
        code: testCode,
      );

      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Test failed: Should have returned Right'),
        (message) {
          expect(message, 'Reset code verified');
        },
      );
    });

    test('should return default message when message is missing', () async {
      final apiResponse = {};

      when(
        mockDio.post(
          'api/auth/verify-reset-code',
          data: {'email': testEmail, 'code': testCode},
        ),
      ).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: 'api/auth/verify-reset-code'),
          data: apiResponse,
        ),
      );

      final result = await authRepository.verify_reset_code(
        email: testEmail,
        code: testCode,
      );

      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Test failed: Should have returned Right'),
        (message) {
          expect(message, 'Reset code verified');
        },
      );
    });

    test('should return AppFailure on DioException', () async {
      when(
        mockDio.post(
          'api/auth/verify-reset-code',
          data: {'email': testEmail, 'code': testCode},
        ),
      ).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: 'api/auth/verify-reset-code'),
          message: 'Invalid code',
        ),
      );

      final result = await authRepository.verify_reset_code(
        email: testEmail,
        code: testCode,
      );

      expect(result.isLeft(), true);
      result.fold((failure) {
        expect(failure, isA<AppFailure>());
        expect(failure.message, 'Verify reset code failed');
      }, (message) => fail('Test failed: Should have returned Left'));
    });

    test('should return AppFailure on generic exception', () async {
      when(
        mockDio.post(
          'api/auth/verify-reset-code',
          data: {'email': testEmail, 'code': testCode},
        ),
      ).thenThrow(Exception('Timeout'));

      final result = await authRepository.verify_reset_code(
        email: testEmail,
        code: testCode,
      );

      expect(result.isLeft(), true);
      result.fold((failure) {
        expect(failure, isA<AppFailure>());
        expect(failure.message, contains('Exception'));
      }, (message) => fail('Test failed: Should have returned Left'));
    });
  });

  group('reset_password', () {
    const testEmail = 'asermohamed@gmail.com';
    const testPassword = 'ASERMOHAMED123***aaa';

    final userMap = {
      'id': '1',
      'name': 'Test User',
      'email': testEmail,
      'username': 'testuser',
      'dateOfBirth': '2004-11-11',
      'isEmailVerified': false,
      'isVerified': false,
    };

    final apiResponse = {
      'user': userMap,
      'accesstoken': 'reset_access_token',
      'refresh_token': 'reset_refresh_token',
    };

    test('should return UserModel and TokensModel on success', () async {
      when(
        mockDio.post(
          'api/auth/reset-password',
          data: {'email': testEmail, 'password': testPassword},
        ),
      ).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: 'api/auth/reset-password'),
          data: apiResponse,
        ),
      );

      final result = await authRepository.reset_password(
        email: testEmail,
        password: testPassword,
      );

      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Test failed: Should have returned Right'),
        (successData) {
          final (user, tokens) = successData;
          expect(user, isA<UserModel>());
          expect(user.email, testEmail);
          expect(tokens, isA<TokensModel>());
          expect(tokens.accessToken, 'reset_access_token');
          expect(tokens.refreshToken, 'reset_refresh_token');
        },
      );

      verify(
        mockDio.post(
          'api/auth/reset-password',
          data: {'email': testEmail, 'password': testPassword},
        ),
      ).called(1);
    });

    test('should return AppFailure on DioException', () async {
      when(
        mockDio.post(
          'api/auth/reset-password',
          data: {'email': testEmail, 'password': testPassword},
        ),
      ).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: 'api/auth/reset-password'),
          message: 'Server error',
        ),
      );

      final result = await authRepository.reset_password(
        email: testEmail,
        password: testPassword,
      );

      expect(result.isLeft(), true);
      result.fold((failure) {
        expect(failure, isA<AppFailure>());
        expect(failure.message, 'Reset password failed');
      }, (successData) => fail('Test failed: Should have returned Left'));
    });

    test('should return AppFailure on generic exception', () async {
      when(
        mockDio.post(
          'api/auth/reset-password',
          data: {'email': testEmail, 'password': testPassword},
        ),
      ).thenThrow(Exception('Parse error'));

      final result = await authRepository.reset_password(
        email: testEmail,
        password: testPassword,
      );

      expect(result.isLeft(), true);
      result.fold((failure) {
        expect(failure, isA<AppFailure>());
        expect(failure.message, contains('Exception'));
      }, (successData) => fail('Test failed: Should have returned Left'));
    });
  });

  group('uploadProfilePhoto', () {
    test('should return AppFailure when no file is selected', () async {
      final pickedImage = PickedImage(file: null, name: 'test.jpg');

      final result = await authRepository.uploadProfilePhoto(
        pickedImage: pickedImage,
      );

      expect(result.isLeft(), true);
      result.fold((failure) {
        expect(failure, isA<AppFailure>());
        expect(failure.message, 'No file selected');
      }, (data) => fail('Test failed: Should have returned Left'));
    });

    test('should return mediaId and keyName on successful upload', () async {
      final mockFile = File('test.jpg');
      final pickedImage = PickedImage(file: mockFile, name: 'test.jpg');

      final uploadRequestResponse = {
        'url': 'https://presigned-url.com',
        'keyName': 'media/test-key-123',
      };

      final confirmResponse = {
        'newMedia': {'id': 'media-id-123', 'keyName': 'media/test-key-123'},
      };

      when(
        mockDio.post(
          'api/media/upload-request',
          data: {'fileName': 'test.jpg', 'contentType': 'image/jpeg'},
        ),
      ).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: 'api/media/upload-request'),
          data: uploadRequestResponse,
          statusCode: 200,
        ),
      );

      when(
        mockDio.post('api/media/confirm-upload/media/test-key-123'),
      ).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(
            path: 'api/media/confirm-upload/media/test-key-123',
          ),
          data: confirmResponse,
          statusCode: 200,
        ),
      );
    });

    test(
      'should return AppFailure on DioException during upload request',
      () async {
        final mockFile = File('test.jpg');
        final pickedImage = PickedImage(file: mockFile, name: 'test.jpg');

        when(
          mockDio.post(
            'api/media/upload-request',
            data: {'fileName': 'test.jpg', 'contentType': 'image/jpeg'},
          ),
        ).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: 'api/media/upload-request'),
            message: 'Server error',
          ),
        );
      },
    );
  });

  group('downloadMedia', () {
    const testMediaId = 'media-123';

    test('should return AppFailure on exception', () async {
      when(mockDio.get('api/media/download-request/$testMediaId')).thenThrow(
        DioException(
          requestOptions: RequestOptions(
            path: 'api/media/download-request/$testMediaId',
          ),
          message: 'Not found',
        ),
      );

      final result = await authRepository.downloadMedia(mediaId: testMediaId);

      expect(result.isLeft(), true);
      result.fold((failure) {
        expect(failure, isA<AppFailure>());
        expect(failure.message, contains('Download failed'));
      }, (file) => fail('Test failed: Should have returned Left'));
    });
  });
}
