// auth_remote_repository_test.dart
import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lite_x/core/classes/PickedImage.dart';
import 'package:lite_x/features/auth/repositories/auth_remote_repository.dart';
import 'package:mockito/annotations.dart';
import 'package:lite_x/core/classes/AppFailure.dart';
import 'package:lite_x/core/models/TokensModel.dart';
import 'package:lite_x/core/models/usermodel.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'auth_remote_repository_test.mocks.dart';

const String testApiUrl = 'http://test-api.com/';
const MethodChannel urlLauncherChannel = MethodChannel(
  'plugins.flutter.io/url_launcher',
);
const MethodChannel googleSignInChannel = MethodChannel(
  'plugins.flutter.io/google_sign_in',
);

@GenerateMocks([Dio, DeepLinkWrapper, http.Client])
void main() {
  late MockDio mockDio;
  late MockDio mockDownloadDio;
  late MockDio mockUploadDio;
  late AuthRemoteRepository authRepository;
  late MockDeepLinkWrapper mockDeepLinkWrapper;
  late MockClient mockHttpClient;
  setUp(() {
    mockDio = MockDio();
    mockDownloadDio = MockDio();
    mockUploadDio = MockDio();
    mockDeepLinkWrapper = MockDeepLinkWrapper();
    mockHttpClient = MockClient();
    authRepository = AuthRemoteRepository(
      dio: mockDio,
      downloadDio: mockDownloadDio,
      uploadDio: mockUploadDio,
      deepLinkWrapper: mockDeepLinkWrapper,
      httpClient: mockHttpClient,
    );
    HttpOverrides.global = null;
    TestWidgetsFlutterBinding.ensureInitialized();
    const MethodChannel channel = MethodChannel(
      'plugins.flutter.io/path_provider',
    );

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
          return '.';
        });
    const MethodChannel pathProviderChannel = MethodChannel(
      'plugins.flutter.io/path_provider',
    );
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(pathProviderChannel, (_) async => '.');
  });
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    try {
      await dotenv.load(fileName: ".env");
    } catch (e) {}
    dotenv.env['API_URL'] = testApiUrl;
  });
  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('plugins.flutter.io/path_provider'),
          null,
        );
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(urlLauncherChannel, null);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(googleSignInChannel, null);
  });

  group('loginWithGithub', () {
    test('should return AppFailure when dotenv API_URL is null', () async {
      final oldValue = dotenv.env['API_URL'];
      dotenv.env.remove('API_URL');
      final result = await authRepository.loginWithGithub();
      expect(result.isLeft(), true);
      if (oldValue != null) dotenv.env['API_URL'] = oldValue;
    });
    test(
      'should return AppFailure if OAuth parameters are missing from Deep Link',
      () async {
        dotenv.env['API_URL'] = testApiUrl;
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(urlLauncherChannel, (call) async => true);
        final incompleteUri = Uri.parse(
          '${testApiUrl}oauth2/callback?token=access&missing-refresh&missing-user',
        );

        when(
          mockDeepLinkWrapper.waitForLink(),
        ).thenAnswer((_) async => incompleteUri);
        final result = await authRepository.loginWithGithub();
        expect(result.isLeft(), true);
        result.fold(
          (l) => expect(l.message, "OAuth error: missing parameters"),
          (r) => fail("Should be Left"),
        );
      },
    );
    test('should return Right (User) on successful Deep Link callback', () async {
      dotenv.env['API_URL'] = testApiUrl;
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(urlLauncherChannel, (call) async => true);
      final fullUserJson = jsonEncode({
        "id": "1",
        "name": "Test User",
        "email": "test@example.com",
        "username": "testuser",
        "dateOfBirth": "2000-01-01",
        "isEmailVerified": true,
        "isVerified": true,
        "newuser": false,
        "photo": null,
        "bio": null,
      });

      final successUri = Uri.parse(
        '${testApiUrl}oauth2/callback?token=access&refresh-token=refresh&user=${Uri.encodeComponent(fullUserJson)}',
      );

      when(
        mockDeepLinkWrapper.waitForLink(),
      ).thenAnswer((_) async => successUri);
      final result = await authRepository.loginWithGithub();
      result.fold(
        (l) => fail(
          'Test failed. Expected Right, got Left with message: ${l.message}',
        ),
        (r) => expect(true, true),
      );
    });
    test(
      'should return Left when Deep Link is null (User Cancelled)',
      () async {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(urlLauncherChannel, (call) async => true);
        when(mockDeepLinkWrapper.waitForLink()).thenAnswer((_) async => null);
        final result = await authRepository.loginWithGithub();
        expect(result.isLeft(), true);
        result.fold(
          (l) => expect(l.message, "Login cancelled by user"),
          (r) => fail("Should be Left"),
        );
      },
    );
    test('should return AppFailure when browser could not be opened', () async {
      dotenv.env['API_URL'] = testApiUrl;
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(urlLauncherChannel, (call) async => false);
      final result = await authRepository.loginWithGithub();
      expect(result.isLeft(), true);
      result.fold(
        (l) => expect(l.message, "Could not open browser"),
        (r) => fail("Should be Left"),
      );
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(urlLauncherChannel, null);
    });
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

  group('uploadProfilePhoto - Full Coverage', () {
    final dummyFile = File('test_image.jpg');
    final pickedImage = PickedImage(file: dummyFile, name: 'test_image.jpg');

    final uploadRequestData = {
      'url': 'https://s3.aws.com/upload-here',
      'keyName': 'temp/image123.jpg',
    };

    final confirmData = {
      'newMedia': {'id': 101, 'keyName': 'final/image101.jpg'},
    };

    test('should return Left when file is null', () async {
      final result = await authRepository.uploadProfilePhoto(
        pickedImage: PickedImage(file: null, name: 'test'),
      );

      expect(result.isLeft(), true);
      result.fold(
        (l) => expect(l.message, 'No file selected'),
        (r) => fail('Should be Left'),
      );
    });

    test('should return Left if upload-request fails', () async {
      if (!dummyFile.existsSync()) dummyFile.createSync();

      when(
        mockDio.post('api/media/upload-request', data: anyNamed('data')),
      ).thenThrow(DioException(requestOptions: RequestOptions(path: '')));

      final result = await authRepository.uploadProfilePhoto(
        pickedImage: pickedImage,
      );

      expect(result.isLeft(), true);
      result.fold(
        (l) => expect(l.message, 'Upload failed'),
        (r) => fail('Should be Left'),
      );

      if (dummyFile.existsSync()) dummyFile.deleteSync();
    });
    test('should return Left if PUT request to S3 fails', () async {
      if (!dummyFile.existsSync()) dummyFile.createSync();
      when(
        mockDio.post('api/media/upload-request', data: anyNamed('data')),
      ).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: ''),
          data: uploadRequestData,
          statusCode: 200,
        ),
      );
      when(
        mockUploadDio.put(any, data: anyNamed('data')),
      ).thenThrow(DioException(requestOptions: RequestOptions(path: '')));

      final result = await authRepository.uploadProfilePhoto(
        pickedImage: pickedImage,
      );

      expect(result.isLeft(), true);
      result.fold(
        (l) => expect(l.message, 'Upload failed'),
        (r) => fail('Should be Left'),
      );
      if (dummyFile.existsSync()) dummyFile.deleteSync();
    });

    test('should return Left if confirm-upload fails', () async {
      if (!dummyFile.existsSync()) dummyFile.createSync();

      when(
        mockDio.post('api/media/upload-request', data: anyNamed('data')),
      ).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: ''),
          data: uploadRequestData,
          statusCode: 200,
        ),
      );
      when(mockUploadDio.put(any, data: anyNamed('data'))).thenAnswer(
        (_) async =>
            Response(requestOptions: RequestOptions(path: ''), statusCode: 200),
      );
      when(
        mockDio.post(
          argThat(contains('api/media/confirm-upload')),
          data: anyNamed('data'),
        ),
      ).thenThrow(DioException(requestOptions: RequestOptions(path: '')));

      final result = await authRepository.uploadProfilePhoto(
        pickedImage: pickedImage,
      );

      expect(result.isLeft(), true);
      if (dummyFile.existsSync()) dummyFile.deleteSync();
    });

    test('should return mediaId and keyName on success', () async {
      if (!dummyFile.existsSync()) dummyFile.createSync();
      when(
        mockDio.post('api/media/upload-request', data: anyNamed('data')),
      ).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: ''),
          data: uploadRequestData,
          statusCode: 200,
        ),
      );
      when(mockUploadDio.put(any, data: anyNamed('data'))).thenAnswer(
        (_) async =>
            Response(requestOptions: RequestOptions(path: ''), statusCode: 200),
      );
      when(
        mockDio.post(argThat(contains('api/media/confirm-upload'))),
      ).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: ''),
          data: confirmData,
          statusCode: 200,
        ),
      );

      final result = await authRepository.uploadProfilePhoto(
        pickedImage: pickedImage,
      );

      expect(result.isRight(), true);
      result.fold((l) => fail('Should be Right'), (r) {
        expect(r['mediaId'], '101');
        expect(r['keyName'], 'final/image101.jpg');
      });
      if (dummyFile.existsSync()) dummyFile.deleteSync();
    });
    test(
      'should return Left if response parsing fails (e.g. null data)',
      () async {
        if (!dummyFile.existsSync()) dummyFile.createSync();
        when(
          mockDio.post('api/media/upload-request', data: anyNamed('data')),
        ).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(path: ''),
            data: uploadRequestData,
            statusCode: 200,
          ),
        );
        when(mockUploadDio.put(any, data: anyNamed('data'))).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(path: ''),
            statusCode: 200,
          ),
        );
        when(
          mockDio.post(argThat(contains('api/media/confirm-upload'))),
        ).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(path: ''),
            data: {},
            statusCode: 200,
          ),
        );

        final result = await authRepository.uploadProfilePhoto(
          pickedImage: pickedImage,
        );
        expect(result.isLeft(), true);
        result.fold((l) {
          expect(l.message, contains('null'));
        }, (r) => fail('Should be Left'));

        if (dummyFile.existsSync()) dummyFile.deleteSync();
      },
    );
  });

  group('downloadMedia - Full Coverage', () {
    const testMediaId = 'media-123';
    const testDownloadUrl = 'https://example.com/image.jpg';
    final testImageBytes = [0, 1, 2, 3];

    test('should return File on successful download sequence', () async {
      when(mockDio.get('api/media/download-request/$testMediaId')).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: ''),
          data: {'url': testDownloadUrl},
          statusCode: 200,
        ),
      );
      when(
        mockDownloadDio.get(testDownloadUrl, options: anyNamed('options')),
      ).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: testDownloadUrl),
          data: testImageBytes,
          statusCode: 200,
        ),
      );
      final result = await authRepository.downloadMedia(mediaId: testMediaId);
      expect(result.isRight(), true);
      result.fold((failure) => fail('Should differ'), (file) {
        expect(file, isA<File>());
      });
    });

    test(
      'should return AppFailure when the second request (image download) fails',
      () async {
        when(mockDio.get('api/media/download-request/$testMediaId')).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(path: ''),
            data: {'url': testDownloadUrl},
            statusCode: 200,
          ),
        );
        when(
          mockDownloadDio.get(testDownloadUrl, options: anyNamed('options')),
        ).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: testDownloadUrl),
            message: 'Download timeout',
          ),
        );
        final result = await authRepository.downloadMedia(mediaId: testMediaId);
        expect(result.isLeft(), true);
        result.fold((failure) {
          expect(failure.message, contains('Download failed'));
          expect(failure.message, contains('Download timeout'));
        }, (_) => fail('Should return Left'));
      },
    );
    test(
      'should return AppFailure when download URL is malformed or missing',
      () async {
        when(mockDio.get('api/media/download-request/$testMediaId')).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(path: ''),
            data: {'wrong_key': 'something'},
            statusCode: 200,
          ),
        );

        // Act
        final result = await authRepository.downloadMedia(mediaId: testMediaId);
        expect(result.isLeft(), true);
        result.fold(
          (failure) => expect(failure.message, contains('Download failed')),
          (_) => fail('Should return Left'),
        );
      },
    );
  });

  group('check_email', () {
    const testEmail = 'asermohamed@gmail.com';

    test('should return true when email exists', () async {
      final apiResponse = {'exists': true};

      when(
        mockDio.post('api/auth/getUser', data: {'email': testEmail}),
      ).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: 'api/auth/getUser'),
          data: apiResponse,
          statusCode: 200,
        ),
      );

      final result = await authRepository.check_email(email: testEmail);

      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Test failed: Should have returned Right'),
        (exists) {
          expect(exists, true);
        },
      );
    });

    test('should return false when email does not exist', () async {
      final apiResponse = {'exists': false};

      when(
        mockDio.post('api/auth/getUser', data: {'email': testEmail}),
      ).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: 'api/auth/getUser'),
          data: apiResponse,
          statusCode: 200,
        ),
      );

      final result = await authRepository.check_email(email: testEmail);

      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Test failed: Should have returned Right'),
        (exists) {
          expect(exists, false);
        },
      );
    });

    test('should return false when exists field is missing', () async {
      final apiResponse = {};

      when(
        mockDio.post('api/auth/getUser', data: {'email': testEmail}),
      ).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: 'api/auth/getUser'),
          data: apiResponse,
          statusCode: 200,
        ),
      );

      final result = await authRepository.check_email(email: testEmail);

      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Test failed: Should have returned Right'),
        (exists) {
          expect(exists, false);
        },
      );
    });

    test('should return AppFailure on DioException', () async {
      when(
        mockDio.post('api/auth/getUser', data: {'email': testEmail}),
      ).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: 'api/auth/getUser'),
          message: 'Network error',
        ),
      );

      final result = await authRepository.check_email(email: testEmail);

      expect(result.isLeft(), true);
      result.fold((failure) {
        expect(failure, isA<AppFailure>());
        expect(failure.message, 'Email check failed');
      }, (exists) => fail('Test failed: Should have returned Left'));
    });

    test('should return AppFailure on generic exception', () async {
      when(
        mockDio.post('api/auth/getUser', data: {'email': testEmail}),
      ).thenThrow(Exception('Unexpected error'));

      final result = await authRepository.check_email(email: testEmail);

      expect(result.isLeft(), true);
      result.fold((failure) {
        expect(failure, isA<AppFailure>());
        expect(failure.message, contains('Exception'));
      }, (exists) => fail('Test failed: Should have returned Left'));
    });
  });

  group('update_password', () {
    const testPassword = 'OldPassword123***';
    const testNewPassword = 'NewPassword123***';
    const testConfirmPassword = 'NewPassword123***';

    test(
      'should return success message on successful password update',
      () async {
        final apiResponse = {'message': 'Password updated successfully'};

        when(
          mockDio.post(
            'api/auth/change-password',
            data: {
              'password': testPassword,
              'newpassword': testNewPassword,
              'confirmPassword': testConfirmPassword,
            },
          ),
        ).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(path: 'api/auth/change-password'),
            data: apiResponse,
            statusCode: 200,
          ),
        );

        final result = await authRepository.update_password(
          password: testPassword,
          newpassword: testNewPassword,
          confirmPassword: testConfirmPassword,
        );

        expect(result.isRight(), true);
        result.fold(
          (failure) => fail('Test failed: Should have returned Right'),
          (message) {
            expect(message, 'Password updated successfully');
          },
        );
      },
    );

    test('should return default message when message is missing', () async {
      final apiResponse = {};

      when(
        mockDio.post(
          'api/auth/change-password',
          data: {
            'password': testPassword,
            'newpassword': testNewPassword,
            'confirmPassword': testConfirmPassword,
          },
        ),
      ).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: 'api/auth/change-password'),
          data: apiResponse,
          statusCode: 200,
        ),
      );

      final result = await authRepository.update_password(
        password: testPassword,
        newpassword: testNewPassword,
        confirmPassword: testConfirmPassword,
      );

      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Test failed: Should have returned Right'),
        (message) {
          expect(message, 'Password updated successfully');
        },
      );
    });

    test('should return AppFailure on DioException', () async {
      when(
        mockDio.post(
          'api/auth/change-password',
          data: {
            'password': testPassword,
            'newpassword': testNewPassword,
            'confirmPassword': testConfirmPassword,
          },
        ),
      ).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: 'api/auth/change-password'),
          message: 'Wrong password',
        ),
      );

      final result = await authRepository.update_password(
        password: testPassword,
        newpassword: testNewPassword,
        confirmPassword: testConfirmPassword,
      );

      expect(result.isLeft(), true);
      result.fold((failure) {
        expect(failure, isA<AppFailure>());
        expect(failure.message, 'update password failed');
      }, (message) => fail('Test failed: Should have returned Left'));
    });

    test('should return AppFailure on generic exception', () async {
      when(
        mockDio.post(
          'api/auth/change-password',
          data: {
            'password': testPassword,
            'newpassword': testNewPassword,
            'confirmPassword': testConfirmPassword,
          },
        ),
      ).thenThrow(Exception('Network timeout'));

      final result = await authRepository.update_password(
        password: testPassword,
        newpassword: testNewPassword,
        confirmPassword: testConfirmPassword,
      );

      expect(result.isLeft(), true);
      result.fold((failure) {
        expect(failure, isA<AppFailure>());
        expect(failure.message, contains('Exception'));
      }, (message) => fail('Test failed: Should have returned Left'));
    });
  });
  group('getCategories', () {
    test('should return list of categories on success', () async {
      final apiResponse = {
        'data': [
          {'id': '1', 'name': 'Tech', 'icon': 'tech.png'},
          {'id': '2', 'name': 'Business', 'icon': 'business.png'},
        ],
      };

      when(mockDio.get('api/explore/categories')).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: 'api/explore/categories'),
          data: apiResponse,
          statusCode: 200,
        ),
      );

      final result = await authRepository.getCategories();

      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Test failed: Should have returned Right'),
        (categories) {
          expect(categories.length, 2);
          expect(categories[0].name, 'Tech');
          expect(categories[1].name, 'Business');
        },
      );
    });

    test('should return AppFailure on exception', () async {
      when(mockDio.get('api/explore/categories')).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: 'api/explore/categories'),
          message: 'Network error',
        ),
      );

      final result = await authRepository.getCategories();

      expect(result.isLeft(), true);
      result.fold((failure) {
        expect(failure, isA<AppFailure>());
        expect(failure.message, 'Failed to load categories');
      }, (categories) => fail('Test failed: Should have returned Left'));
    });
  });
  group('saveUserInterests', () {
    final testInterests = {'Tech', 'Business', 'Sports'};

    test('should return success message on successful save', () async {
      final apiResponse = {'message': 'Interests saved'};

      when(
        mockDio.post(
          'api/explore/preferred-categories',
          data: {'categories': testInterests.toList()},
        ),
      ).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(
            path: 'api/explore/preferred-categories',
          ),
          data: apiResponse,
          statusCode: 200,
        ),
      );

      final result = await authRepository.saveUserInterests(testInterests);

      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Test failed: Should have returned Right'),
        (message) {
          expect(message, 'Interests saved');
        },
      );
    });

    test('should return default message when message is missing', () async {
      final apiResponse = {};

      when(
        mockDio.post(
          'api/explore/preferred-categories',
          data: {'categories': testInterests.toList()},
        ),
      ).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(
            path: 'api/explore/preferred-categories',
          ),
          data: apiResponse,
          statusCode: 200,
        ),
      );

      final result = await authRepository.saveUserInterests(testInterests);

      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Test failed: Should have returned Right'),
        (message) {
          expect(message, 'Interests saved');
        },
      );
    });

    test('should return AppFailure on exception', () async {
      when(
        mockDio.post(
          'api/explore/preferred-categories',
          data: {'categories': testInterests.toList()},
        ),
      ).thenThrow(
        DioException(
          requestOptions: RequestOptions(
            path: 'api/explore/preferred-categories',
          ),
          message: 'Server error',
        ),
      );

      final result = await authRepository.saveUserInterests(testInterests);

      expect(result.isLeft(), true);
      result.fold((failure) {
        expect(failure, isA<AppFailure>());
        expect(failure.message, 'Failed to save interests');
      }, (message) => fail('Test failed: Should have returned Left'));
    });
  });
  group('getUserInterests', () {
    test('should return list of interest names on success', () async {
      final apiResponse = {
        'preferredCategories': [
          {'name': 'Tech', 'id': '1'},
          {'name': 'Business', 'id': '2'},
        ],
      };

      when(mockDio.get('api/explore/preferred-categories')).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(
            path: 'api/explore/preferred-categories',
          ),
          data: apiResponse,
          statusCode: 200,
        ),
      );

      final result = await authRepository.getUserInterests();

      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Test failed: Should have returned Right'),
        (interests) {
          expect(interests.length, 2);
          expect(interests, ['Tech', 'Business']);
        },
      );
    });

    test('should return AppFailure on exception', () async {
      when(mockDio.get('api/explore/preferred-categories')).thenThrow(
        DioException(
          requestOptions: RequestOptions(
            path: 'api/explore/preferred-categories',
          ),
          message: 'Network error',
        ),
      );

      final result = await authRepository.getUserInterests();

      expect(result.isLeft(), true);
      result.fold((failure) {
        expect(failure, isA<AppFailure>());
        expect(failure.message, 'Failed to load interests');
      }, (interests) => fail('Test failed: Should have returned Left'));
    });
  });

  group('suggest_usernames', () {
    const testUsername = 'aser';

    test('should return list of username suggestions on success', () async {
      final apiResponse = {
        'suggestions': ['aser_1', 'aser_2', 'aser_123'],
      };

      when(
        mockDio.post(
          'api/auth/suggest-usernames',
          data: {'name': testUsername},
        ),
      ).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: 'api/auth/suggest-usernames'),
          data: apiResponse,
          statusCode: 200,
        ),
      );

      final result = await authRepository.suggest_usernames(
        username: testUsername,
      );

      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Test failed: Should have returned Right'),
        (suggestions) {
          expect(suggestions.length, 3);
          expect(suggestions, ['aser_1', 'aser_2', 'aser_123']);
        },
      );
    });

    test('should return empty list when suggestions is missing', () async {
      final apiResponse = {};

      when(
        mockDio.post(
          'api/auth/suggest-usernames',
          data: {'name': testUsername},
        ),
      ).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: 'api/auth/suggest-usernames'),
          data: apiResponse,
          statusCode: 200,
        ),
      );

      final result = await authRepository.suggest_usernames(
        username: testUsername,
      );

      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Test failed: Should have returned Right'),
        (suggestions) {
          expect(suggestions, []);
        },
      );
    });

    test('should return AppFailure on DioException', () async {
      when(
        mockDio.post(
          'api/auth/suggest-usernames',
          data: {'name': testUsername},
        ),
      ).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: 'api/auth/suggest-usernames'),
          message: 'Server error',
        ),
      );

      final result = await authRepository.suggest_usernames(
        username: testUsername,
      );

      expect(result.isLeft(), true);
      result.fold((failure) {
        expect(failure, isA<AppFailure>());
        expect(failure.message, 'Username suggestions failed');
      }, (suggestions) => fail('Test failed: Should have returned Left'));
    });

    test('should return AppFailure on generic exception', () async {
      when(
        mockDio.post(
          'api/auth/suggest-usernames',
          data: {'name': testUsername},
        ),
      ).thenThrow(Exception('Network timeout'));

      final result = await authRepository.suggest_usernames(
        username: testUsername,
      );

      expect(result.isLeft(), true);
      result.fold((failure) {
        expect(failure, isA<AppFailure>());
        expect(failure.message, contains('Exception'));
      }, (suggestions) => fail('Test failed: Should have returned Left'));
    });
  });
  group('setbirthdate', () {
    const testDay = '11';
    const testMonth = '11';
    const testYear = '2004';

    test('should return success message on successful birthdate set', () async {
      final apiResponse = {'message': 'Birthdate set successfully'};

      when(
        mockDio.post(
          'api/auth/set-birthdate',
          data: {'day': testDay, 'month': testMonth, 'year': testYear},
        ),
      ).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: 'api/auth/set-birthdate'),
          data: apiResponse,
          statusCode: 200,
        ),
      );

      final result = await authRepository.setbirthdate(
        day: testDay,
        month: testMonth,
        year: testYear,
      );

      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Test failed: Should have returned Right'),
        (message) {
          expect(message, 'Birthdate set successfully');
        },
      );
    });

    test('should return AppFailure on DioException', () async {
      when(
        mockDio.post(
          'api/auth/set-birthdate',
          data: {'day': testDay, 'month': testMonth, 'year': testYear},
        ),
      ).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: 'api/auth/set-birthdate'),
          message: 'Invalid date',
        ),
      );

      final result = await authRepository.setbirthdate(
        day: testDay,
        month: testMonth,
        year: testYear,
      );

      expect(result.isLeft(), true);
      result.fold((failure) {
        expect(failure, isA<AppFailure>());
        expect(failure.message, 'Failed to set birthdate');
      }, (message) => fail('Test failed: Should have returned Left'));
    });

    test('should return AppFailure on generic exception', () async {
      when(
        mockDio.post(
          'api/auth/set-birthdate',
          data: {'day': testDay, 'month': testMonth, 'year': testYear},
        ),
      ).thenThrow(Exception('Network error'));

      final result = await authRepository.setbirthdate(
        day: testDay,
        month: testMonth,
        year: testYear,
      );

      expect(result.isLeft(), true);
      result.fold((failure) {
        expect(failure, isA<AppFailure>());
        expect(failure.message, contains('Exception'));
      }, (message) => fail('Test failed: Should have returned Left'));
    });
  });

  group('update_email', () {
    const testNewEmail = 'asermohamed123@gmail.com';

    test('should return success message on successful email update', () async {
      final apiResponse = {'message': 'Email updated successfully'};

      when(
        mockDio.post('api/auth/change-email', data: {'newemail': testNewEmail}),
      ).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: 'api/auth/change-email'),
          data: apiResponse,
          statusCode: 200,
        ),
      );

      final result = await authRepository.update_email(newemail: testNewEmail);

      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Test failed: Should have returned Right'),
        (message) {
          expect(message, 'Email updated successfully');
        },
      );
    });

    test('should return default message when message is missing', () async {
      final apiResponse = {};

      when(
        mockDio.post('api/auth/change-email', data: {'newemail': testNewEmail}),
      ).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: 'api/auth/change-email'),
          data: apiResponse,
          statusCode: 200,
        ),
      );

      final result = await authRepository.update_email(newemail: testNewEmail);

      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Test failed: Should have returned Right'),
        (message) {
          expect(message, 'Email updated successfully');
        },
      );
    });

    test('should return AppFailure on DioException', () async {
      when(
        mockDio.post('api/auth/change-email', data: {'newemail': testNewEmail}),
      ).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: 'api/auth/change-email'),
          message: 'Email already in use',
        ),
      );

      final result = await authRepository.update_email(newemail: testNewEmail);

      expect(result.isLeft(), true);
      result.fold((failure) {
        expect(failure, isA<AppFailure>());
        expect(failure.message, 'update email failed');
      }, (message) => fail('Test failed: Should have returned Left'));
    });

    test('should return AppFailure on generic exception', () async {
      when(
        mockDio.post('api/auth/change-email', data: {'newemail': testNewEmail}),
      ).thenThrow(Exception('Server error'));

      final result = await authRepository.update_email(newemail: testNewEmail);

      expect(result.isLeft(), true);
      result.fold((failure) {
        expect(failure, isA<AppFailure>());
        expect(failure.message, contains('Exception'));
      }, (message) => fail('Test failed: Should have returned Left'));
    });
  });

  group('verify_new_email', () {
    const testNewEmail = 'asermohamed123@gmail.com';
    const testCode = '123456';

    test('should return success message on successful verification', () async {
      final apiResponse = {'message': 'updated email successfully'};

      when(
        mockDio.post(
          'api/auth/verify-new-email',
          data: {'email': testNewEmail, 'code': testCode},
        ),
      ).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: 'api/auth/verify-new-email'),
          data: apiResponse,
          statusCode: 200,
        ),
      );

      final result = await authRepository.verify_new_email(
        newemail: testNewEmail,
        code: testCode,
      );

      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Test failed: Should have returned Right'),
        (message) {
          expect(message, 'updated email successfully');
        },
      );
    });

    test('should return default message when message is missing', () async {
      final apiResponse = {};

      when(
        mockDio.post(
          'api/auth/verify-new-email',
          data: {'email': testNewEmail, 'code': testCode},
        ),
      ).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: 'api/auth/verify-new-email'),
          data: apiResponse,
          statusCode: 200,
        ),
      );

      final result = await authRepository.verify_new_email(
        newemail: testNewEmail,
        code: testCode,
      );

      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Test failed: Should have returned Right'),
        (message) {
          expect(message, 'updated email successfully');
        },
      );
    });

    test('should return AppFailure on DioException', () async {
      when(
        mockDio.post(
          'api/auth/verify-new-email',
          data: {'email': testNewEmail, 'code': testCode},
        ),
      ).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: 'api/auth/verify-new-email'),
          message: 'Invalid verification code',
        ),
      );

      final result = await authRepository.verify_new_email(
        newemail: testNewEmail,
        code: testCode,
      );

      expect(result.isLeft(), true);
      result.fold((failure) {
        expect(failure, isA<AppFailure>());
        expect(failure.message, 'Email update failed');
      }, (message) => fail('Test failed: Should have returned Left'));
    });

    test('should return AppFailure on generic exception', () async {
      when(
        mockDio.post(
          'api/auth/verify-new-email',
          data: {'email': testNewEmail, 'code': testCode},
        ),
      ).thenThrow(Exception('Network error'));

      final result = await authRepository.verify_new_email(
        newemail: testNewEmail,
        code: testCode,
      );

      expect(result.isLeft(), true);
      result.fold((failure) {
        expect(failure, isA<AppFailure>());
        expect(failure.message, contains('Exception'));
      }, (message) => fail('Test failed: Should have returned Left'));
    });
  });
  group('updateProfilePhoto', () {
    const testUserId = 'user-123';
    const testMediaId = 'media-456';

    test('should return success on successful update', () async {
      when(
        mockDio.patch('api/users/profile-picture/$testUserId/$testMediaId'),
      ).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(
            path: 'api/users/profile-picture/$testUserId/$testMediaId',
          ),
          statusCode: 200,
        ),
      );

      final result = await authRepository.updateProfilePhoto(
        testUserId,
        testMediaId,
      );

      expect(result.isRight(), true);
    });

    test('should return AppFailure on exception', () async {
      when(
        mockDio.patch('api/users/profile-picture/$testUserId/$testMediaId'),
      ).thenThrow(
        DioException(
          requestOptions: RequestOptions(
            path: 'api/users/profile-picture/$testUserId/$testMediaId',
          ),
          message: 'Server error',
        ),
      );

      final result = await authRepository.updateProfilePhoto(
        testUserId,
        testMediaId,
      );

      expect(result.isLeft(), true);
      result.fold((failure) {
        expect(failure, isA<AppFailure>());
        expect(failure.message, "couldn't update profile picture");
      }, (_) => fail('Test failed: Should have returned Left'));
    });
  });
  group('Edge Cases and Error Scenarios', () {
    test('create - should handle empty response data', () async {
      when(mockDio.post('api/auth/signup', data: anyNamed('data'))).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: 'api/auth/signup'),
          data: null,
          statusCode: 201,
        ),
      );

      final result = await authRepository.create(
        name: 'Test',
        email: 'test@test.com',
        dateOfBirth: '2000-01-01',
      );

      expect(result.isRight(), false);
    });

    test('signup - should handle missing tokens in response', () async {
      final malformedResponse = {
        'user': {
          'id': '1',
          'name': 'Test',
          'email': 'test@test.com',
          'username': 'test',
        },
        'tokens': null,
      };

      when(
        mockDio.post('api/auth/finalize_signup', data: anyNamed('data')),
      ).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: 'api/auth/finalize_signup'),
          data: malformedResponse,
          statusCode: 200,
        ),
      );

      final result = await authRepository.signup(
        email: 'test@test.com',
        password: 'password123',
      );

      expect(result.isLeft(), true);
    });

    test('login - should handle malformed user data', () async {
      final malformedResponse = {
        'user': {'id': '1'},
        'Token': 'token',
        'Refresh_token': 'refresh',
      };

      when(mockDio.post('api/auth/login', data: anyNamed('data'))).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: 'api/auth/login'),
          data: malformedResponse,
          statusCode: 200,
        ),
      );

      final result = await authRepository.login(
        email: 'test@test.com',
        password: 'password',
      );

      expect(result.isLeft(), true);
    });

    test('updateUsername - should handle missing tokens in response', () async {
      final currentUser = UserModel(
        id: '1',
        name: 'Test',
        email: 'test@test.com',
        username: 'old',
        dob: '1990-01-01',
        isEmailVerified: false,
        isVerified: false,
      );

      when(
        mockDio.put('api/auth/update_username', data: anyNamed('data')),
      ).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: 'api/auth/update_username'),
          data: {
            'user': {'username': 'newusername'},
            'tokens': null,
          },
          statusCode: 200,
        ),
      );

      final result = await authRepository.updateUsername(
        currentUser: currentUser,
        Username: 'newusername',
      );

      expect(result.isLeft(), true);
    });

    test('reset_password - should handle null user data', () async {
      when(
        mockDio.post('api/auth/reset-password', data: anyNamed('data')),
      ).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: 'api/auth/reset-password'),
          data: {
            'user': null,
            'accesstoken': 'token',
            'refresh_token': 'refresh',
          },
        ),
      );

      final result = await authRepository.reset_password(
        email: 'test@test.com',
        password: 'newpassword',
      );

      expect(result.isLeft(), true);
    });

    test('getCategories - should handle empty data array', () async {
      when(mockDio.get('api/explore/categories')).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: 'api/explore/categories'),
          data: {'data': []},
          statusCode: 200,
        ),
      );

      final result = await authRepository.getCategories();

      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Test failed: Should have returned Right'),
        (categories) {
          expect(categories, isEmpty);
        },
      );
    });

    test('getCategories - should handle malformed category data', () async {
      when(mockDio.get('api/explore/categories')).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: 'api/explore/categories'),
          data: {
            'data': [
              {'id': '1'},
            ],
          },
          statusCode: 200,
        ),
      );

      final result = await authRepository.getCategories();

      expect(result.isLeft(), true);
    });

    test(
      'getUserInterests - should handle empty preferred categories',
      () async {
        when(mockDio.get('api/explore/preferred-categories')).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(
              path: 'api/explore/preferred-categories',
            ),
            data: {'preferredCategories': []},
            statusCode: 200,
          ),
        );

        final result = await authRepository.getUserInterests();

        expect(result.isRight(), true);
        result.fold(
          (failure) => fail('Test failed: Should have returned Right'),
          (interests) {
            expect(interests, isEmpty);
          },
        );
      },
    );

    test('getUserInterests - should handle null preferredCategories', () async {
      when(mockDio.get('api/explore/preferred-categories')).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(
            path: 'api/explore/preferred-categories',
          ),
          data: {'preferredCategories': null},
          statusCode: 200,
        ),
      );

      final result = await authRepository.getUserInterests();

      expect(result.isLeft(), true);
    });

    test('saveUserInterests - should handle empty set', () async {
      when(
        mockDio.post(
          'api/explore/preferred-categories',
          data: {'categories': []},
        ),
      ).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(
            path: 'api/explore/preferred-categories',
          ),
          data: {'message': 'Interests saved'},
          statusCode: 200,
        ),
      );

      final result = await authRepository.saveUserInterests({});

      expect(result.isRight(), true);
    });
  });

  group('getMediaType', () {
    test('should return correct media type for jpg', () {
      final result = authRepository.getMediaType('image.jpg');
      expect(result, 'image/jpeg');
    });

    test('should return correct media type for jpeg', () {
      final result = authRepository.getMediaType('photo.jpeg');
      expect(result, 'image/jpeg');
    });

    test('should return correct media type for png', () {
      final result = authRepository.getMediaType('image.png');
      expect(result, 'image/png');
    });

    test('should return correct media type for gif', () {
      final result = authRepository.getMediaType('animation.gif');
      expect(result, 'image/gif');
    });

    test('should return correct media type for webp', () {
      final result = authRepository.getMediaType('image.webp');
      expect(result, 'image/webp');
    });

    test('should return default media type for unknown extension', () {
      final result = authRepository.getMediaType('file.xyz');
      expect(result, 'image/jpeg');
    });

    test('should handle uppercase extensions', () {
      final result = authRepository.getMediaType('IMAGE.PNG');
      expect(result, 'image/png');
    });

    test('should handle mixed case extensions', () {
      final result = authRepository.getMediaType('photo.JpEg');
      expect(result, 'image/jpeg');
    });
  });
  group('uploadProfilePhoto - Complete Flow', () {
    test('should handle successful complete upload flow', () async {});

    test('should return AppFailure when upload request fails', () async {
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

      final result = await authRepository.uploadProfilePhoto(
        pickedImage: pickedImage,
      );

      expect(result.isLeft(), true);
      result.fold((failure) {
        expect(failure, isA<AppFailure>());
        expect(failure.message, 'Upload failed');
      }, (data) => fail('Test failed: Should have returned Left'));
    });

    test('should handle different image types correctly', () {
      expect(authRepository.getMediaType('image.jpg'), 'image/jpeg');
      expect(authRepository.getMediaType('image.jpeg'), 'image/jpeg');
      expect(authRepository.getMediaType('image.png'), 'image/png');
      expect(authRepository.getMediaType('image.gif'), 'image/gif');
      expect(authRepository.getMediaType('image.webp'), 'image/webp');
      expect(authRepository.getMediaType('image.unknown'), 'image/jpeg');
    });

    test('should return AppFailure when confirm upload fails', () async {});
  });
  group('File Handling Edge Cases', () {
    test('getMediaType - should handle files without extension', () {
      final result = authRepository.getMediaType('imagefile');
      expect(result, 'image/jpeg');
    });

    test('getMediaType - should handle files with multiple dots', () {
      final result = authRepository.getMediaType('my.image.file.png');
      expect(result, 'image/png');
    });

    test('getMediaType - should handle empty string', () {
      final result = authRepository.getMediaType('');
      expect(result, 'image/jpeg');
    });
  });
  group('registerFcmToken', () {
    const testFcmToken = 'fcm_token_123456789';

    test('should return success message on successful registration', () async {
      final apiResponse = {'message': 'FCM registered successfully'};

      when(
        mockDio.post('api/users/fcm-token', data: anyNamed('data')),
      ).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: 'api/users/fcm-token'),
          data: apiResponse,
          statusCode: 200,
        ),
      );

      final result = await authRepository.registerFcmToken(
        fcmToken: testFcmToken,
      );

      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Test failed: Should have returned Right'),
        (message) {
          expect(message, 'FCM registered successfully');
        },
      );
    });

    test('should return default message when message is missing', () async {
      final apiResponse = {};

      when(
        mockDio.post('api/users/fcm-token', data: anyNamed('data')),
      ).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: 'api/users/fcm-token'),
          data: apiResponse,
          statusCode: 200,
        ),
      );

      final result = await authRepository.registerFcmToken(
        fcmToken: testFcmToken,
      );

      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Test failed: Should have returned Right'),
        (message) {
          expect(message, 'FCM registered successfully');
        },
      );
    });

    test('should return AppFailure on DioException with response', () async {
      when(
        mockDio.post('api/users/fcm-token', data: anyNamed('data')),
      ).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: 'api/users/fcm-token'),
          response: Response(
            requestOptions: RequestOptions(path: 'api/users/fcm-token'),
            data: {'message': 'Token registration failed'},
            statusCode: 400,
          ),
          message: 'Bad request',
        ),
      );

      final result = await authRepository.registerFcmToken(
        fcmToken: testFcmToken,
      );

      expect(result.isLeft(), true);
      result.fold((failure) {
        expect(failure, isA<AppFailure>());
        expect(failure.message, contains('FCM registration failed'));
      }, (message) => fail('Test failed: Should have returned Left'));
    });

    test('should return AppFailure on DioException without response', () async {
      when(
        mockDio.post('api/users/fcm-token', data: anyNamed('data')),
      ).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: 'api/users/fcm-token'),
          message: 'Connection timeout',
        ),
      );

      final result = await authRepository.registerFcmToken(
        fcmToken: testFcmToken,
      );

      expect(result.isLeft(), true);
      result.fold((failure) {
        expect(failure, isA<AppFailure>());
        expect(failure.message, 'FCM registration failed');
      }, (message) => fail('Test failed: Should have returned Left'));
    });

    test('should return AppFailure on generic exception', () async {
      when(
        mockDio.post('api/users/fcm-token', data: anyNamed('data')),
      ).thenThrow(Exception('Unexpected error'));

      final result = await authRepository.registerFcmToken(
        fcmToken: testFcmToken,
      );

      expect(result.isLeft(), true);
      result.fold((failure) {
        expect(failure, isA<AppFailure>());
        expect(failure.message, contains('Exception'));
      }, (message) => fail('Test failed: Should have returned Left'));
    });
    test(
      'should extract error from "errors" field when "message" is missing',
      () async {
        when(
          mockDio.post('api/users/fcm-token', data: anyNamed('data')),
        ).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: 'api/users/fcm-token'),
            response: Response(
              requestOptions: RequestOptions(path: 'api/users/fcm-token'),
              data: {'errors': 'Invalid token format'},
              statusCode: 422,
            ),
          ),
        );

        final result = await authRepository.registerFcmToken(
          fcmToken: testFcmToken,
        );

        expect(result.isLeft(), true);
        result.fold((failure) {
          expect(
            failure.message,
            'FCM registration failed: Invalid token format',
          );
        }, (_) => fail('Should be Left'));
      },
    );

    test(
      'should fallback to data.toString() when message and errors are missing',
      () async {
        when(
          mockDio.post('api/users/fcm-token', data: anyNamed('data')),
        ).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: 'api/users/fcm-token'),
            response: Response(
              requestOptions: RequestOptions(path: 'api/users/fcm-token'),
              data: {'unknown_error': 123},
              statusCode: 500,
            ),
          ),
        );

        final result = await authRepository.registerFcmToken(
          fcmToken: testFcmToken,
        );

        expect(result.isLeft(), true);
        result.fold((failure) {
          expect(
            failure.message,
            'FCM registration failed: {unknown_error: 123}',
          );
        }, (_) => fail('Should be Left'));
      },
    );

    test('should use statusMessage when response data is NOT a Map', () async {
      when(
        mockDio.post('api/users/fcm-token', data: anyNamed('data')),
      ).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: 'api/users/fcm-token'),
          response: Response(
            requestOptions: RequestOptions(path: 'api/users/fcm-token'),
            data: "  error",
            statusMessage: 'Server Error',
            statusCode: 500,
          ),
        ),
      );

      final result = await authRepository.registerFcmToken(
        fcmToken: testFcmToken,
      );

      expect(result.isLeft(), true);
      result.fold((failure) {
        expect(failure.message, 'FCM registration failed: Server Error');
      }, (_) => fail('Should be Left'));
    });

    test('should use statusMessage when response data is null', () async {
      when(
        mockDio.post('api/users/fcm-token', data: anyNamed('data')),
      ).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: 'api/users/fcm-token'),
          response: Response(
            requestOptions: RequestOptions(path: 'api/users/fcm-token'),
            data: null,
            statusMessage: 'Service Unavailable',
            statusCode: 503,
          ),
        ),
      );

      final result = await authRepository.registerFcmToken(
        fcmToken: testFcmToken,
      );

      expect(result.isLeft(), true);
      result.fold((failure) {
        expect(failure.message, 'FCM registration failed: Service Unavailable');
      }, (_) => fail('Should be Left'));
    });
  });
  group('signInWithGoogleAndroid', () {
    void mockGoogleChannel({bool cancel = false}) {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(googleSignInChannel, (
            MethodCall methodCall,
          ) async {
            if (methodCall.method == 'init') return null;
            if (methodCall.method == 'signIn') {
              if (cancel) return null;
              return {
                'email': 'test@gmail.com',
                'id': '123',
                'displayName': 'Test User',
                'photoUrl': null,
              };
            }
            if (methodCall.method == 'getTokens') {
              return {
                'idToken': 'fake_google_id_token',
                'accessToken': 'fake_access_token',
              };
            }
            return null;
          });
    }

    test(
      'should return Left when Google Sign In is canceled by user',
      () async {
        mockGoogleChannel(cancel: true);
        final result = await authRepository.signInWithGoogleAndroid();
        expect(result.isLeft(), true);
        result.fold(
          (l) => expect(l.message, 'Google login canceled'),
          (r) => fail('Should be Left'),
        );
      },
    );

    test('should return AppFailure when dotenv API_URL is missing', () async {
      mockGoogleChannel(cancel: false);
      dotenv.env.remove('API_URL');
      final result = await authRepository.signInWithGoogleAndroid();
      expect(result.isLeft(), true);
      result.fold((failure) {
        expect(failure.message, anyOf(contains('Null'), contains('API_URL')));
      }, (_) => fail('Expected failure'));
    });

    test(
      'should return Right (Success) when Backend returns 200 and Valid JSON',
      () async {
        // 1. ضمان وجود API_URL
        dotenv.env['API_URL'] = testApiUrl;

        mockGoogleChannel(cancel: false);

        final successJson = jsonEncode({
          "user": {
            "id": "1",
            "name": "Aser",
            "email": "aser@test.com",
            "username": "aser_1",
            "dateOfBirth": "2000-01-01",
            "isEmailVerified": true,
            "isVerified": false,
            "newuser": true,
          },
          "token": "access_token_123",
          "refreshToken": "refresh_token_123",
        });

        when(
          mockHttpClient.post(
            any,
            headers: anyNamed('headers'),
            body: anyNamed('body'),
          ),
        ).thenAnswer((_) async => http.Response(successJson, 200));

        final result = await authRepository.signInWithGoogleAndroid();

        expect(result.isRight(), true);
        result.fold((l) => fail('Should be Right: ${l.message}'), (r) {
          final (user, tokens, isNewUser) = r;
          expect(user.email, 'aser@test.com');
          expect(tokens.accessToken, 'access_token_123');
          expect(isNewUser, true);
        });
      },
    );

    test(
      'should return Left when Backend returns non-200 status code',
      () async {
        // 1. ضمان وجود API_URL
        dotenv.env['API_URL'] = testApiUrl;

        mockGoogleChannel(cancel: false);

        when(
          mockHttpClient.post(
            any,
            headers: anyNamed('headers'),
            body: anyNamed('body'),
          ),
        ).thenAnswer((_) async => http.Response('Internal Server Error', 500));

        final result = await authRepository.signInWithGoogleAndroid();

        expect(result.isLeft(), true);
        result.fold(
          (l) => expect(l.message, 'Internal Server Error'),
          (r) => fail('Should be Left'),
        );
      },
    );

    test('should return Left when Backend returns malformed JSON', () async {
      // 1. ضمان وجود API_URL
      dotenv.env['API_URL'] = testApiUrl;

      mockGoogleChannel(cancel: false);

      final badJson = jsonEncode({"user": {}});
      when(
        mockHttpClient.post(
          any,
          headers: anyNamed('headers'),
          body: anyNamed('body'),
        ),
      ).thenAnswer((_) async => http.Response(badJson, 200));

      final result = await authRepository.signInWithGoogleAndroid();

      expect(result.isLeft(), true);
      result.fold(
        (l) => expect(l.message, contains("type 'Null' is not a subtype")),
        (r) => fail('Should be Left'),
      );
    });
  });
}
