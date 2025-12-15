// auth_view_model_test.dart
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:lite_x/core/classes/AppFailure.dart';
import 'package:lite_x/core/models/TokensModel.dart';
import 'package:lite_x/core/models/usermodel.dart';
import 'package:lite_x/core/providers/current_user_provider.dart';
import 'package:lite_x/features/auth/models/ExploreCategory.dart';
import 'package:lite_x/features/auth/repositories/auth_local_repository.dart';
import 'package:lite_x/features/auth/repositories/auth_remote_repository.dart';
import 'package:lite_x/features/auth/view_model/auth_state.dart';
import 'package:lite_x/features/auth/view_model/auth_view_model.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:riverpod/riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:lite_x/core/classes/PickedImage.dart';
import 'auth_view_model_test.mocks.dart';

@GenerateMocks([AuthRemoteRepository, AuthLocalRepository])
void main() {
  late MockAuthRemoteRepository mockRemoteRepository;
  late MockAuthLocalRepository mockLocalRepository;
  late ProviderContainer container;

  setUpAll(() async {
    provideDummy<Either<AppFailure, Map<String, dynamic>>>(
      right(<String, dynamic>{}),
    );
    provideDummy<Either<AppFailure, List<ExploreCategory>>>(right([]));
    provideDummy<Either<AppFailure, File>>(right(File('dummy')));
    provideDummy<Either<AppFailure, void>>(right(null));
    provideDummy<Either<AppFailure, List<String>>>(right(<String>[]));
    provideDummy<Either<AppFailure, String>>(right('dummy string'));
    provideDummy<Either<AppFailure, bool>>(right(true));
    provideDummy<Either<AppFailure, (UserModel, TokensModel)>>(
      right((
        UserModel(
          id: '1',
          name: 'aser',
          email: 'aser@test.com',
          username: 'aser',
          dob: '2000-01-01',
          isEmailVerified: false,
          isVerified: false,
        ),
        TokensModel(
          accessToken: 'access_token_123',
          refreshToken: 'refresh_token_123',
          accessTokenExpiry: DateTime.now(),
          refreshTokenExpiry: DateTime.now(),
        ),
      )),
    );
    provideDummy<Either<AppFailure, (UserModel, TokensModel, bool)>>(
      right((
        UserModel(
          id: '1',
          name: 'aser',
          email: 'aser@test.com',
          username: 'aser',
          dob: '2000-01-01',
          isEmailVerified: false,
          isVerified: false,
        ),
        TokensModel(
          accessToken: 'access_token_123',
          refreshToken: 'refresh_token_123',
          accessTokenExpiry: DateTime.now(),
          refreshTokenExpiry: DateTime.now(),
        ),
        false,
      )),
    );
  });

  setUp(() {
    mockRemoteRepository = MockAuthRemoteRepository();
    mockLocalRepository = MockAuthLocalRepository();
    when(mockLocalRepository.getUser()).thenReturn(null);
    when(mockLocalRepository.getTokens()).thenReturn(null);

    container = ProviderContainer(
      overrides: [
        authRemoteRepositoryProvider.overrideWithValue(mockRemoteRepository),
        authLocalRepositoryProvider.overrideWithValue(mockLocalRepository),
      ],
    );
    container.read(authViewModelProvider);
  });

  tearDown(() {
    container.dispose();
  });

  group('createAccount', () {
    const testName = 'AserMohamed';
    const testEmail = 'asermohamed@gmail.com';
    const testDateOfBirth = '2004-11-11';

    test(
      'should update state to success on successful account creation',
      () async {
        when(
          mockRemoteRepository.create(
            name: testName,
            email: testEmail,
            dateOfBirth: testDateOfBirth,
          ),
        ).thenAnswer((_) async => right('Verification email sent'));
        await Future.delayed(const Duration(milliseconds: 500));

        final viewModel = container.read(authViewModelProvider.notifier);

        await viewModel.createAccount(
          name: testName,
          email: testEmail,
          dateOfBirth: testDateOfBirth,
        );

        final state = container.read(authViewModelProvider);
        expect(state.type, AuthStateType.success);
        expect(state.message, 'Verification email sent');

        verify(
          mockRemoteRepository.create(
            name: testName,
            email: testEmail,
            dateOfBirth: testDateOfBirth,
          ),
        ).called(1);
      },
    );

    test('should update state to error on failure', () async {
      when(
        mockRemoteRepository.create(
          name: testName,
          email: testEmail,
          dateOfBirth: testDateOfBirth,
        ),
      ).thenAnswer((_) async => left(AppFailure(message: 'Signup failed')));

      await Future.delayed(const Duration(milliseconds: 500));

      final viewModel = container.read(authViewModelProvider.notifier);

      await viewModel.createAccount(
        name: testName,
        email: testEmail,
        dateOfBirth: testDateOfBirth,
      );

      final state = container.read(authViewModelProvider);
      expect(state.type, AuthStateType.error);
      expect(state.message, 'Signup failed');
    });
  });

  group('verifySignupEmail', () {
    const testEmail = 'asermohamed@gmail.com';
    const testCode = '123456';

    test(
      'should update state to verified on successful verification',
      () async {
        when(
          mockRemoteRepository.verifySignupEmail(
            email: testEmail,
            code: testCode,
          ),
        ).thenAnswer((_) async => right('Verified successfully'));
        await Future.delayed(const Duration(milliseconds: 500));

        final viewModel = container.read(authViewModelProvider.notifier);

        await viewModel.verifySignupEmail(email: testEmail, code: testCode);

        final state = container.read(authViewModelProvider);
        expect(state.type, AuthStateType.verified);
        expect(state.message, 'Verified successfully');

        verify(
          mockRemoteRepository.verifySignupEmail(
            email: testEmail,
            code: testCode,
          ),
        ).called(1);
      },
    );

    test('should update state to error on verification failure', () async {
      when(
        mockRemoteRepository.verifySignupEmail(
          email: testEmail,
          code: testCode,
        ),
      ).thenAnswer(
        (_) async => left(AppFailure(message: 'Invalid verification code')),
      );

      await Future.delayed(const Duration(milliseconds: 500));

      final viewModel = container.read(authViewModelProvider.notifier);

      await viewModel.verifySignupEmail(email: testEmail, code: testCode);

      final state = container.read(authViewModelProvider);
      expect(state.type, AuthStateType.error);
      expect(state.message, 'Invalid verification code');
    });
  });

  group('finalizeSignup', () {
    const testEmail = 'asermohamed@gmail.com';
    const testPassword = 'ASERMOHAMED123***aaa';

    final testUser = UserModel(
      id: '1',
      name: 'Test User',
      email: testEmail,
      username: 'testuser',
      dob: '2004-11-11',
      isEmailVerified: true,
      isVerified: false,
    );

    final testTokens = TokensModel(
      accessToken: 'access_token_123',
      refreshToken: 'refresh_token_123',
      accessTokenExpiry: DateTime.now().add(const Duration(hours: 1)),
      refreshTokenExpiry: DateTime.now().add(const Duration(days: 30)),
    );

    test('should save user and tokens and update state on success', () async {
      when(
        mockRemoteRepository.signup(email: testEmail, password: testPassword),
      ).thenAnswer((_) async => right((testUser, testTokens)));

      when(
        mockLocalRepository.saveUser(any),
      ).thenAnswer((_) async => Future.value());
      when(
        mockLocalRepository.saveTokens(any),
      ).thenAnswer((_) async => Future.value());

      await Future.delayed(const Duration(milliseconds: 500));

      final viewModel = container.read(authViewModelProvider.notifier);

      await viewModel.finalizeSignup(email: testEmail, password: testPassword);

      await Future.delayed(const Duration(milliseconds: 100));

      final state = container.read(authViewModelProvider);
      expect(state.type, AuthStateType.authenticated);
      expect(state.message, 'Signup successful');

      verify(mockLocalRepository.saveUser(testUser)).called(1);
      verify(mockLocalRepository.saveTokens(testTokens)).called(1);

      final currentUser = container.read(currentUserProvider);
      expect(currentUser, testUser);
    });

    test('should update state to error on signup failure', () async {
      when(
        mockRemoteRepository.signup(email: testEmail, password: testPassword),
      ).thenAnswer((_) async => left(AppFailure(message: 'Signup failed')));

      await Future.delayed(const Duration(milliseconds: 500));

      final viewModel = container.read(authViewModelProvider.notifier);

      await viewModel.finalizeSignup(email: testEmail, password: testPassword);

      final state = container.read(authViewModelProvider);
      expect(state.type, AuthStateType.error);
      expect(state.message, 'Signup failed');

      verifyNever(mockLocalRepository.saveUser(any));
      verifyNever(mockLocalRepository.saveTokens(any));
    });
  });
  group('login', () {
    const testEmail = 'asermohamed@gmail.com';
    const testPassword = 'ASERMOHAMED123***aaa';

    final testUser = UserModel(
      id: '1',
      name: 'Test User',
      email: testEmail,
      username: 'testuser',
      dob: '2004-11-11',
      isEmailVerified: true,
      isVerified: false,
    );

    final testTokens = TokensModel(
      accessToken: 'access_token_123daefsgrdjtjsgtjyjj',
      refreshToken: 'refresh_token_123ggggggrsyyfjfvgd',
      accessTokenExpiry: DateTime.now().add(const Duration(hours: 1)),
      refreshTokenExpiry: DateTime.now().add(const Duration(days: 30)),
    );

    test(
      'should save user and tokens and update state on successful login',
      () async {
        when(
          mockRemoteRepository.login(email: testEmail, password: testPassword),
        ).thenAnswer((_) async => right((testUser, testTokens)));
        when(
          mockRemoteRepository.getUserInterests(),
        ).thenAnswer((_) async => right(["Tech", "Business"]));

        when(
          mockLocalRepository.saveUser(any),
        ).thenAnswer((_) async => Future.value());
        when(
          mockLocalRepository.saveTokens(any),
        ).thenAnswer((_) async => Future.value());

        await Future.delayed(const Duration(milliseconds: 500));

        final viewModel = container.read(authViewModelProvider.notifier);

        await viewModel.login(email: testEmail, password: testPassword);
        await Future.delayed(const Duration(milliseconds: 50));

        final state = container.read(authViewModelProvider);
        expect(state.type, AuthStateType.authenticated);
        expect(state.message, 'Login successful');

        verify(mockLocalRepository.saveUser(any)).called(2);
        verify(mockLocalRepository.saveTokens(testTokens)).called(1);

        final currentUser = container.read(currentUserProvider);
        expect(currentUser?.email, testUser.email);
        expect(currentUser?.id, testUser.id);
        expect(currentUser?.username, testUser.username);
        expect(currentUser?.interests, {"Tech", "Business"});
      },
    );

    test('should update state to error on login failure', () async {
      when(
        mockRemoteRepository.login(email: testEmail, password: testPassword),
      ).thenAnswer(
        (_) async => left(AppFailure(message: 'Invalid credentials')),
      );

      await Future.delayed(const Duration(milliseconds: 500));

      final viewModel = container.read(authViewModelProvider.notifier);

      await viewModel.login(email: testEmail, password: testPassword);

      final state = container.read(authViewModelProvider);
      expect(state.type, AuthStateType.error);
      expect(state.message, 'Invalid credentials');

      verifyNever(mockLocalRepository.saveUser(any));
      verifyNever(mockLocalRepository.saveTokens(any));
    });

    test('should handle login with interests fetch failure', () async {
      when(
        mockRemoteRepository.login(email: testEmail, password: testPassword),
      ).thenAnswer((_) async => right((testUser, testTokens)));
      when(mockRemoteRepository.getUserInterests()).thenAnswer(
        (_) async => left(AppFailure(message: 'Failed to load interests')),
      );

      when(
        mockLocalRepository.saveUser(any),
      ).thenAnswer((_) async => Future.value());
      when(
        mockLocalRepository.saveTokens(any),
      ).thenAnswer((_) async => Future.value());

      await Future.delayed(const Duration(milliseconds: 500));

      final viewModel = container.read(authViewModelProvider.notifier);

      await viewModel.login(email: testEmail, password: testPassword);
      await Future.delayed(const Duration(milliseconds: 50));

      final state = container.read(authViewModelProvider);
      expect(state.type, AuthStateType.authenticated);
      expect(state.message, 'Login successful');
    });
  });

  group('logout', () {
    test('should clear user and tokens on logout', () async {
      when(
        mockLocalRepository.clearUser(),
      ).thenAnswer((_) async => Future.value());
      when(
        mockLocalRepository.clearTokens(),
      ).thenAnswer((_) async => Future.value());

      await Future.delayed(const Duration(milliseconds: 500));

      final viewModel = container.read(authViewModelProvider.notifier);

      await viewModel.logout();

      final state = container.read(authViewModelProvider);
      expect(state.type, AuthStateType.unauthenticated);

      verify(mockLocalRepository.clearUser()).called(1);
      verify(mockLocalRepository.clearTokens()).called(1);

      final currentUser = container.read(currentUserProvider);
      expect(currentUser, null);
    });
    test('should not crash if logout throws exception', () async {
      when(
        mockLocalRepository.clearTokens(),
      ).thenThrow(Exception('Disk error'));
      final viewModel = container.read(authViewModelProvider.notifier);
      await viewModel.logout();
      final state = container.read(authViewModelProvider);
      expect(state.type, isNotNull);
    });
  });

  group('checkEmail', () {
    const testEmail = 'asermohamed@gmail.com';

    test('should update state to success when email exists', () async {
      when(
        mockRemoteRepository.check_email(email: testEmail),
      ).thenAnswer((_) async => right(true));

      await Future.delayed(const Duration(milliseconds: 500));

      final viewModel = container.read(authViewModelProvider.notifier);

      await viewModel.checkEmail(email: testEmail);

      final state = container.read(authViewModelProvider);
      expect(state.type, AuthStateType.success);
      expect(state.message, 'Email found');

      verify(mockRemoteRepository.check_email(email: testEmail)).called(1);
    });

    test('should update state to error when email does not exist', () async {
      when(
        mockRemoteRepository.check_email(email: testEmail),
      ).thenAnswer((_) async => right(false));

      await Future.delayed(const Duration(milliseconds: 500));

      final viewModel = container.read(authViewModelProvider.notifier);

      await viewModel.checkEmail(email: testEmail);

      final state = container.read(authViewModelProvider);
      expect(state.type, AuthStateType.error);
      expect(state.message, 'Email not found. Please create an account.');
    });

    test('should update state to error on email check failure', () async {
      when(
        mockRemoteRepository.check_email(email: testEmail),
      ).thenAnswer((_) async => left(AppFailure(message: 'Network error')));

      await Future.delayed(const Duration(milliseconds: 500));

      final viewModel = container.read(authViewModelProvider.notifier);

      await viewModel.checkEmail(email: testEmail);

      final state = container.read(authViewModelProvider);
      expect(state.type, AuthStateType.error);
      expect(state.message, 'Failed to check email. Please try again.');
    });
  });

  group('forgetPassword', () {
    const testEmail = 'asermohamed@gmail.com';

    test(
      'should update state to success on successful password reset request',
      () async {
        when(
          mockRemoteRepository.forget_password(email: testEmail),
        ).thenAnswer((_) async => right('Reset code sent'));

        await Future.delayed(const Duration(milliseconds: 500));

        final viewModel = container.read(authViewModelProvider.notifier);

        await viewModel.forgetPassword(email: testEmail);

        final state = container.read(authViewModelProvider);
        expect(state.type, AuthStateType.success);
        expect(state.message, 'Reset code sent');

        verify(
          mockRemoteRepository.forget_password(email: testEmail),
        ).called(1);
      },
    );

    test('should update state to error on password reset failure', () async {
      when(
        mockRemoteRepository.forget_password(email: testEmail),
      ).thenAnswer((_) async => left(AppFailure(message: 'Email not found')));

      await Future.delayed(const Duration(milliseconds: 500));

      final viewModel = container.read(authViewModelProvider.notifier);

      await viewModel.forgetPassword(email: testEmail);

      final state = container.read(authViewModelProvider);
      expect(state.type, AuthStateType.error);
      expect(state.message, 'Email not found');
    });
  });

  group('verifyResetCode', () {
    const testEmail = 'asermohamed@gmail.com';
    const testCode = '123456';

    test(
      'should update state to awaitingPassword on successful verification',
      () async {
        when(
          mockRemoteRepository.verify_reset_code(
            email: testEmail,
            code: testCode,
          ),
        ).thenAnswer((_) async => right('Code verified'));

        await Future.delayed(const Duration(milliseconds: 500));

        final viewModel = container.read(authViewModelProvider.notifier);

        await viewModel.verifyResetCode(email: testEmail, code: testCode);

        final state = container.read(authViewModelProvider);
        expect(state.type, AuthStateType.awaitingPassword);
        expect(state.message, 'Code verified');

        verify(
          mockRemoteRepository.verify_reset_code(
            email: testEmail,
            code: testCode,
          ),
        ).called(1);
      },
    );

    test('should update state to error on verification failure', () async {
      when(
        mockRemoteRepository.verify_reset_code(
          email: testEmail,
          code: testCode,
        ),
      ).thenAnswer((_) async => left(AppFailure(message: 'Invalid code')));

      await Future.delayed(const Duration(milliseconds: 500));

      final viewModel = container.read(authViewModelProvider.notifier);

      await viewModel.verifyResetCode(email: testEmail, code: testCode);

      final state = container.read(authViewModelProvider);
      expect(state.type, AuthStateType.error);
      expect(state.message, 'Invalid code');
    });
  });

  group('resetPassword', () {
    const testEmail = 'asermohamed@gmail.com';
    const testPassword = 'NewPassword123***';

    final testUser = UserModel(
      id: '1',
      name: 'Test User',
      email: testEmail,
      username: 'testuser',
      dob: '2004-11-11',
      isEmailVerified: true,
      isVerified: false,
    );

    final testTokens = TokensModel(
      accessToken: 'access_token_123',
      refreshToken: 'refresh_token_123',
      accessTokenExpiry: DateTime.now().add(const Duration(hours: 1)),
      refreshTokenExpiry: DateTime.now().add(const Duration(days: 30)),
    );

    test('should save user and tokens on successful password reset', () async {
      when(
        mockRemoteRepository.reset_password(
          email: testEmail,
          password: testPassword,
        ),
      ).thenAnswer((_) async => right((testUser, testTokens)));

      when(
        mockLocalRepository.saveUser(any),
      ).thenAnswer((_) async => Future.value());
      when(
        mockLocalRepository.saveTokens(any),
      ).thenAnswer((_) async => Future.value());

      await Future.delayed(const Duration(milliseconds: 500));

      final viewModel = container.read(authViewModelProvider.notifier);

      await viewModel.resetPassword(email: testEmail, password: testPassword);
      await Future.delayed(const Duration(milliseconds: 50));

      final state = container.read(authViewModelProvider);
      expect(state.type, AuthStateType.success);
      expect(state.message, 'Reset_Password successful');

      verify(mockLocalRepository.saveUser(testUser)).called(1);
      verify(mockLocalRepository.saveTokens(testTokens)).called(1);

      final currentUser = container.read(currentUserProvider);
      expect(currentUser, testUser);
    });

    test('should update state to error on password reset failure', () async {
      when(
        mockRemoteRepository.reset_password(
          email: testEmail,
          password: testPassword,
        ),
      ).thenAnswer((_) async => left(AppFailure(message: 'Reset failed')));

      await Future.delayed(const Duration(milliseconds: 500));

      final viewModel = container.read(authViewModelProvider.notifier);

      await viewModel.resetPassword(email: testEmail, password: testPassword);

      final state = container.read(authViewModelProvider);
      expect(state.type, AuthStateType.error);
      expect(state.message, 'Reset failed');

      verifyNever(mockLocalRepository.saveUser(any));
      verifyNever(mockLocalRepository.saveTokens(any));
    });
  });

  group('updatePassword', () {
    const testPassword = 'OldPassword123***';
    const testNewPassword = 'NewPassword123***';
    const testConfirmPassword = 'NewPassword123***';

    test(
      'should update state to success on successful password update',
      () async {
        when(
          mockRemoteRepository.update_password(
            password: testPassword,
            newpassword: testNewPassword,
            confirmPassword: testConfirmPassword,
          ),
        ).thenAnswer((_) async => right('Password updated successfully'));

        await Future.delayed(const Duration(milliseconds: 500));

        final viewModel = container.read(authViewModelProvider.notifier);

        await viewModel.updatePassword(
          password: testPassword,
          newpassword: testNewPassword,
          confirmPassword: testConfirmPassword,
        );

        final state = container.read(authViewModelProvider);
        expect(state.type, AuthStateType.success);
        expect(state.message, 'Password updated successfully');

        verify(
          mockRemoteRepository.update_password(
            password: testPassword,
            newpassword: testNewPassword,
            confirmPassword: testConfirmPassword,
          ),
        ).called(1);
      },
    );

    test('should update state to error on password update failure', () async {
      when(
        mockRemoteRepository.update_password(
          password: testPassword,
          newpassword: testNewPassword,
          confirmPassword: testConfirmPassword,
        ),
      ).thenAnswer(
        (_) async => left(AppFailure(message: 'Current password is incorrect')),
      );

      await Future.delayed(const Duration(milliseconds: 500));

      final viewModel = container.read(authViewModelProvider.notifier);

      await viewModel.updatePassword(
        password: testPassword,
        newpassword: testNewPassword,
        confirmPassword: testConfirmPassword,
      );

      final state = container.read(authViewModelProvider);
      expect(state.type, AuthStateType.error);
      expect(state.message, 'Current password is incorrect');
    });
  });

  group('updateEmail', () {
    const testNewEmail = 'oliver_1@gmail.com';

    test(
      'should update state to awaitingVerification on successful email update request',
      () async {
        when(
          mockRemoteRepository.update_email(newemail: testNewEmail),
        ).thenAnswer((_) async => right('Verification code sent'));

        await Future.delayed(const Duration(milliseconds: 500));

        final viewModel = container.read(authViewModelProvider.notifier);

        await viewModel.updateEmail(newEmail: testNewEmail);

        final state = container.read(authViewModelProvider);
        expect(state.type, AuthStateType.awaitingVerification);
        expect(state.message, 'Verification code sent');

        verify(
          mockRemoteRepository.update_email(newemail: testNewEmail),
        ).called(1);
      },
    );

    test('should update state to error on email update failure', () async {
      when(
        mockRemoteRepository.update_email(newemail: testNewEmail),
      ).thenAnswer(
        (_) async => left(AppFailure(message: 'Email already exists')),
      );

      await Future.delayed(const Duration(milliseconds: 500));

      final viewModel = container.read(authViewModelProvider.notifier);

      await viewModel.updateEmail(newEmail: testNewEmail);

      final state = container.read(authViewModelProvider);
      expect(state.type, AuthStateType.error);
      expect(state.message, 'Email already exists');
    });
  });

  group('verifyNewEmail', () {
    const testNewEmail = 'aser_123_mohamed@gmail.com';
    const testCode = '123456';

    final testUser = UserModel(
      id: '1',
      name: 'aser mohamed',
      email: 'aser@gmail.com',
      username: 'aser_1',
      dob: '2004-11-11',
      isEmailVerified: true,
      isVerified: false,
    );

    test('should update user email on successful verification', () async {
      when(
        mockRemoteRepository.verify_new_email(
          newemail: testNewEmail,
          code: testCode,
        ),
      ).thenAnswer((_) async => right('Email verified successfully'));

      when(mockLocalRepository.getUser()).thenReturn(testUser);
      when(
        mockLocalRepository.saveUser(any),
      ).thenAnswer((_) async => Future.value());

      await Future.delayed(const Duration(milliseconds: 500));

      container.read(currentUserProvider.notifier).adduser(testUser);

      final viewModel = container.read(authViewModelProvider.notifier);

      await viewModel.verifyNewEmail(newEmail: testNewEmail, code: testCode);

      final state = container.read(authViewModelProvider);
      expect(state.type, AuthStateType.success);
      expect(state.message, 'Email verified successfully');

      final currentUser = container.read(currentUserProvider);
      expect(currentUser?.email, testNewEmail);

      verify(mockLocalRepository.saveUser(any)).called(1);
    });

    test('should update state to error on verification failure', () async {
      when(
        mockRemoteRepository.verify_new_email(
          newemail: testNewEmail,
          code: testCode,
        ),
      ).thenAnswer((_) async => left(AppFailure(message: 'Invalid code')));

      await Future.delayed(const Duration(milliseconds: 500));

      final viewModel = container.read(authViewModelProvider.notifier);

      await viewModel.verifyNewEmail(newEmail: testNewEmail, code: testCode);

      final state = container.read(authViewModelProvider);
      expect(state.type, AuthStateType.error);
      expect(state.message, 'Invalid code');
    });

    test('should handle error when user not found', () async {
      when(
        mockRemoteRepository.verify_new_email(
          newemail: testNewEmail,
          code: testCode,
        ),
      ).thenAnswer((_) async => right('Email verified successfully'));

      when(mockLocalRepository.getUser()).thenReturn(null);

      await Future.delayed(const Duration(milliseconds: 500));

      final viewModel = container.read(authViewModelProvider.notifier);

      await viewModel.verifyNewEmail(newEmail: testNewEmail, code: testCode);

      final state = container.read(authViewModelProvider);
      expect(state.type, AuthStateType.error);
      expect(state.message, 'User not found to update email');
    });

    test(
      'should handle exception while updating user after verification',
      () async {
        when(
          mockRemoteRepository.verify_new_email(
            newemail: testNewEmail,
            code: testCode,
          ),
        ).thenAnswer((_) async => right('Email verified successfully'));
        when(mockLocalRepository.getUser()).thenReturn(testUser);
        when(
          mockLocalRepository.saveUser(any),
        ).thenThrow(Exception('Hive write failed'));

        await Future.delayed(const Duration(milliseconds: 500));

        container.read(currentUserProvider.notifier).adduser(testUser);

        final viewModel = container.read(authViewModelProvider.notifier);

        await viewModel.verifyNewEmail(newEmail: testNewEmail, code: testCode);

        final state = container.read(authViewModelProvider);

        expect(state.type, AuthStateType.error);
        expect(state.message, contains('Failed to update email'));
      },
    );
  });
  group('updateUsername', () {
    const testUsername = 'oliver_1';

    final testUser = UserModel(
      id: '1',
      name: 'aser mohamed',
      email: 'aser@gmail.com',
      username: 'oliver',
      dob: '2004-11-11',
      isEmailVerified: true,
      isVerified: false,
    );

    final updatedUser = testUser.copyWith(username: testUsername);

    final testTokens = TokensModel(
      accessToken: 'new_access_token',
      refreshToken: 'new_refresh_token',
      accessTokenExpiry: DateTime.now().add(const Duration(hours: 1)),
      refreshTokenExpiry: DateTime.now().add(const Duration(days: 30)),
    );

    test('should update username and save user on success', () async {
      when(
        mockRemoteRepository.updateUsername(
          currentUser: testUser,
          Username: testUsername,
        ),
      ).thenAnswer((_) async => right((updatedUser, testTokens)));

      when(
        mockLocalRepository.saveUser(any),
      ).thenAnswer((_) async => Future.value());
      when(
        mockLocalRepository.saveTokens(any),
      ).thenAnswer((_) async => Future.value());

      await Future.delayed(const Duration(milliseconds: 500));

      container.read(currentUserProvider.notifier).adduser(testUser);

      final viewModel = container.read(authViewModelProvider.notifier);

      await viewModel.updateUsername(username: testUsername);

      final state = container.read(authViewModelProvider);
      expect(state.type, AuthStateType.success);
      expect(state.message, 'Username updated successfully');

      verify(mockLocalRepository.saveUser(updatedUser)).called(1);
      verify(mockLocalRepository.saveTokens(testTokens)).called(1);

      final currentUser = container.read(currentUserProvider);
      expect(currentUser?.username, testUsername);
    });

    test('should update state to error on username update failure', () async {
      when(
        mockRemoteRepository.updateUsername(
          currentUser: testUser,
          Username: testUsername,
        ),
      ).thenAnswer(
        (_) async => left(AppFailure(message: 'Username already taken')),
      );

      await Future.delayed(const Duration(milliseconds: 500));

      container.read(currentUserProvider.notifier).adduser(testUser);

      final viewModel = container.read(authViewModelProvider.notifier);

      await viewModel.updateUsername(username: testUsername);

      final state = container.read(authViewModelProvider);
      expect(state.type, AuthStateType.error);
      expect(state.message, 'Username already taken');
    });

    test('should update state to error when user not found', () async {
      await Future.delayed(const Duration(milliseconds: 500));

      final viewModel = container.read(authViewModelProvider.notifier);

      await viewModel.updateUsername(username: testUsername);

      final state = container.read(authViewModelProvider);
      expect(state.type, AuthStateType.error);
      expect(state.message, 'User not found');
    });
  });

  group('saveInterests', () {
    final testInterests = {'coding', 'gaming', 'reading'};

    final testUser = UserModel(
      id: '1',
      name: 'aser mohamed',
      email: 'aser@gmail.com',
      username: 'aser_1',
      dob: '2004-11-11',
      isEmailVerified: true,
      isVerified: false,
    );

    test('should save interests and update user on success', () async {
      when(
        mockRemoteRepository.saveUserInterests(testInterests),
      ).thenAnswer((_) async => right("Interests saved successfully"));
      when(
        mockLocalRepository.saveUser(any),
      ).thenAnswer((_) async => Future.value());

      await Future.delayed(const Duration(milliseconds: 500));

      container.read(currentUserProvider.notifier).adduser(testUser);

      final viewModel = container.read(authViewModelProvider.notifier);

      await viewModel.saveInterests(testInterests);

      final state = container.read(authViewModelProvider);
      expect(state.type, AuthStateType.success);
      expect(state.message, 'Interests saved successfully');

      verify(mockLocalRepository.saveUser(any)).called(1);

      final currentUser = container.read(currentUserProvider);
      expect(currentUser?.interests, testInterests);
    });

    test('should update state to error when user not found', () async {
      await Future.delayed(const Duration(milliseconds: 500));

      final viewModel = container.read(authViewModelProvider.notifier);

      await viewModel.saveInterests(testInterests);

      final state = container.read(authViewModelProvider);
      expect(state.type, AuthStateType.error);
      expect(state.message, 'User not found!');
    });

    test('should handle failure from remote repository', () async {
      when(
        mockRemoteRepository.saveUserInterests(testInterests),
      ).thenAnswer((_) async => left(AppFailure(message: 'Failed to save')));

      await Future.delayed(const Duration(milliseconds: 500));

      container.read(currentUserProvider.notifier).adduser(testUser);

      final viewModel = container.read(authViewModelProvider.notifier);

      await viewModel.saveInterests(testInterests);

      final state = container.read(authViewModelProvider);
      expect(state.type, AuthStateType.error);
      expect(state.message, 'Failed to save');
    });
    test('should handle unexpected exception and set error state', () async {
      when(
        mockRemoteRepository.saveUserInterests(testInterests),
      ).thenThrow(Exception('Unexpected error'));

      await Future.delayed(const Duration(milliseconds: 500));

      container.read(currentUserProvider.notifier).adduser(testUser);

      final viewModel = container.read(authViewModelProvider.notifier);

      await viewModel.saveInterests(testInterests);
      final state = container.read(authViewModelProvider);

      expect(state.type, AuthStateType.error);
      expect(state.message, contains('Unexpected error'));
    });
  });

  group('uploadProfilePhoto', () {
    final testUser = UserModel(
      id: '1',
      name: 'aser',
      email: 'aser@test.com',
      username: 'aser',
      dob: '2000-01-01',
      isEmailVerified: false,
      isVerified: false,
    );
    test('should upload and update profile photo successfully', () async {
      final pickedImage = PickedImage(name: 'test.jpg', file: File('test.jpg'));

      final uploadData = {'mediaId': '123', 'keyName': 'test_key'};
      final downloadedFile = File('/tmp/test.jpg');

      when(
        mockRemoteRepository.uploadProfilePhoto(pickedImage: pickedImage),
      ).thenAnswer((_) async => right(uploadData));

      when(
        mockRemoteRepository.downloadMedia(mediaId: '123'),
      ).thenAnswer((_) async => right(downloadedFile));

      when(
        mockRemoteRepository.updateProfilePhoto('1', '123'),
      ).thenAnswer((_) async => right(null));

      when(
        mockLocalRepository.saveUser(any),
      ).thenAnswer((_) async => Future.value());

      await Future.delayed(const Duration(milliseconds: 500));

      container.read(currentUserProvider.notifier).adduser(testUser);

      final viewModel = container.read(authViewModelProvider.notifier);

      await viewModel.uploadProfilePhoto(pickedImage);
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);

      final state = container.read(authViewModelProvider);

      expect(state.type, AuthStateType.success);
      expect(state.message, 'Profile photo updated successfully');

      verify(mockLocalRepository.saveUser(any)).called(1);
    });

    test('should handle upload failure', () async {
      final pickedImage = PickedImage(name: 'test.jpg', file: File('test.jpg'));

      when(
        mockRemoteRepository.uploadProfilePhoto(pickedImage: pickedImage),
      ).thenAnswer((_) async => left(AppFailure(message: 'Upload failed')));

      await Future.delayed(const Duration(milliseconds: 500));

      final viewModel = container.read(authViewModelProvider.notifier);

      await viewModel.uploadProfilePhoto(pickedImage);

      final state = container.read(authViewModelProvider);
      expect(state.type, AuthStateType.error);
      expect(state.message, 'Upload failed');
    });

    test('should handle download failure', () async {
      final pickedImage = PickedImage(name: 'test.jpg', file: File('test.jpg'));

      final uploadData = {'mediaId': '123', 'keyName': 'test_key'};

      when(
        mockRemoteRepository.uploadProfilePhoto(pickedImage: pickedImage),
      ).thenAnswer((_) async => right(uploadData));
      when(
        mockRemoteRepository.downloadMedia(mediaId: '123'),
      ).thenAnswer((_) async => left(AppFailure(message: 'Download failed')));

      await Future.delayed(const Duration(milliseconds: 500));

      final viewModel = container.read(authViewModelProvider.notifier);

      await viewModel.uploadProfilePhoto(pickedImage);

      final state = container.read(authViewModelProvider);
      expect(state.type, AuthStateType.error);
      expect(state.message, 'Upload done but download failed!');
    });

    test('should handle backend update failure', () async {
      final pickedImage = PickedImage(name: 'test.jpg', file: File('test.jpg'));

      final uploadData = {'mediaId': '123', 'keyName': 'test_key'};
      final downloadedFile = File('/tmp/test.jpg');

      when(
        mockRemoteRepository.uploadProfilePhoto(pickedImage: pickedImage),
      ).thenAnswer((_) async => right(uploadData));
      when(
        mockRemoteRepository.downloadMedia(mediaId: '123'),
      ).thenAnswer((_) async => right(downloadedFile));
      when(
        mockRemoteRepository.updateProfilePhoto('1', '123'),
      ).thenAnswer((_) async => left(AppFailure(message: 'Update failed')));

      await Future.delayed(const Duration(milliseconds: 500));

      container.read(currentUserProvider.notifier).adduser(testUser);

      final viewModel = container.read(authViewModelProvider.notifier);

      await viewModel.uploadProfilePhoto(pickedImage);

      final state = container.read(authViewModelProvider);
      expect(state.type, AuthStateType.error);
      expect(state.message, 'Uploaded but backend update failed');
    });
  });
  group('suggestUsernames', () {
    const testUsername = 'aser';

    test('should return list of username suggestions on success', () async {
      final suggestions = ['aser_1', 'aser_2', 'aser_3'];
      when(
        mockRemoteRepository.suggest_usernames(username: testUsername),
      ).thenAnswer((_) async => right(suggestions));

      await Future.delayed(const Duration(milliseconds: 500));

      final viewModel = container.read(authViewModelProvider.notifier);

      final result = await viewModel.suggestUsernames(username: testUsername);

      expect(result, suggestions);
      verify(
        mockRemoteRepository.suggest_usernames(username: testUsername),
      ).called(1);
    });

    test('should return empty list on failure', () async {
      when(
        mockRemoteRepository.suggest_usernames(username: testUsername),
      ).thenAnswer((_) async => left(AppFailure(message: 'Failed')));

      await Future.delayed(const Duration(milliseconds: 500));

      final viewModel = container.read(authViewModelProvider.notifier);

      final result = await viewModel.suggestUsernames(username: testUsername);

      expect(result, []);
    });
  });
  group('Setbirthdate', () {
    const testBirthDate = '11/11/2004';

    final testUser = UserModel(
      id: '1',
      name: 'aser mohamed',
      email: 'aser@gmail.com',
      username: 'aser_1',
      dob: '2000-01-01',
      isEmailVerified: true,
      isVerified: false,
    );

    test('should set birthdate successfully', () async {
      when(
        mockRemoteRepository.setbirthdate(day: '11', month: '11', year: '2004'),
      ).thenAnswer((_) async => right('Birthdate set successfully'));

      await Future.delayed(const Duration(milliseconds: 500));

      container.read(currentUserProvider.notifier).adduser(testUser);

      final viewModel = container.read(authViewModelProvider.notifier);

      await viewModel.Setbirthdate(birthDate: testBirthDate);

      final state = container.read(authViewModelProvider);
      expect(state.type, AuthStateType.success);
      expect(state.message, 'Birthdate set successfully');

      final currentUser = container.read(currentUserProvider);
      expect(currentUser?.dob, '11/11/2004');
    });

    test('should return error when user not found', () async {
      await Future.delayed(const Duration(milliseconds: 500));

      final viewModel = container.read(authViewModelProvider.notifier);

      await viewModel.Setbirthdate(birthDate: testBirthDate);

      final state = container.read(authViewModelProvider);
      expect(state.type, AuthStateType.error);
      expect(state.message, 'User not found');
    });

    test('should return error for invalid date format', () async {
      await Future.delayed(const Duration(milliseconds: 500));

      container.read(currentUserProvider.notifier).adduser(testUser);

      final viewModel = container.read(authViewModelProvider.notifier);

      await viewModel.Setbirthdate(birthDate: '11-11-2004');

      final state = container.read(authViewModelProvider);
      expect(state.type, AuthStateType.error);
      expect(state.message, 'Invalid date format');
    });

    test('should handle repository failure', () async {
      when(
        mockRemoteRepository.setbirthdate(day: '11', month: '11', year: '2004'),
      ).thenAnswer((_) async => left(AppFailure(message: 'Failed to set')));

      await Future.delayed(const Duration(milliseconds: 500));

      container.read(currentUserProvider.notifier).adduser(testUser);

      final viewModel = container.read(authViewModelProvider.notifier);

      await viewModel.Setbirthdate(birthDate: testBirthDate);

      final state = container.read(authViewModelProvider);
      expect(state.type, AuthStateType.error);
      expect(state.message, 'Failed to set');
    });
  });
  group('Token Management', () {
    final testTokens = TokensModel(
      accessToken: 'access_token_123',
      refreshToken: 'refresh_token_123',
      accessTokenExpiry: DateTime.now().add(const Duration(hours: 1)),
      refreshTokenExpiry: DateTime.now().add(const Duration(days: 30)),
    );

    test('should return access token when tokens exist', () async {
      when(mockLocalRepository.getTokens()).thenReturn(testTokens);

      await Future.delayed(const Duration(milliseconds: 500));

      final viewModel = container.read(authViewModelProvider.notifier);

      final accessToken = viewModel.getAccessToken();

      expect(accessToken, 'access_token_123');
    });

    test('should return null when no tokens exist', () async {
      when(mockLocalRepository.getTokens()).thenReturn(null);

      await Future.delayed(const Duration(milliseconds: 500));

      final viewModel = container.read(authViewModelProvider.notifier);

      final accessToken = viewModel.getAccessToken();

      expect(accessToken, null);
    });

    test('should return refresh token when not expired', () async {
      when(mockLocalRepository.getTokens()).thenReturn(testTokens);

      await Future.delayed(const Duration(milliseconds: 500));

      final viewModel = container.read(authViewModelProvider.notifier);

      final refreshToken = viewModel.getRefreshToken();

      expect(refreshToken, 'refresh_token_123');
    });

    test('should return null for expired refresh token', () async {
      final expiredTokens = TokensModel(
        accessToken: 'access_token_123',
        refreshToken: 'refresh_token_123',
        accessTokenExpiry: DateTime.now().subtract(const Duration(hours: 1)),
        refreshTokenExpiry: DateTime.now().subtract(const Duration(days: 1)),
      );
      when(mockLocalRepository.getTokens()).thenReturn(expiredTokens);

      await Future.delayed(const Duration(milliseconds: 500));

      final viewModel = container.read(authViewModelProvider.notifier);

      final refreshToken = viewModel.getRefreshToken();

      expect(refreshToken, null);
    });
  });
  group('Helper Methods', () {
    final testUser = UserModel(
      id: '1',
      name: 'aser',
      email: 'aser@test.com',
      username: 'aser',
      dob: '2000-01-01',
      isEmailVerified: false,
      isVerified: false,
    );

    final testTokens = TokensModel(
      accessToken: 'access_token_123',
      refreshToken: 'refresh_token_123',
      accessTokenExpiry: DateTime.now().add(const Duration(hours: 1)),
      refreshTokenExpiry: DateTime.now().add(const Duration(days: 30)),
    );

    test('should reset state to unauthenticated', () async {
      await Future.delayed(const Duration(milliseconds: 500));

      final viewModel = container.read(authViewModelProvider.notifier);

      viewModel.resetState();

      final state = container.read(authViewModelProvider);
      expect(state.type, AuthStateType.unauthenticated);
    });

    test('should set state to authenticated', () async {
      await Future.delayed(const Duration(milliseconds: 500));

      final viewModel = container.read(authViewModelProvider.notifier);

      viewModel.setAuthenticated();

      final state = container.read(authViewModelProvider);
      expect(state.type, AuthStateType.authenticated);
    });

    test('should return true when user is authenticated', () async {
      when(mockLocalRepository.getUser()).thenReturn(testUser);
      when(mockLocalRepository.getTokens()).thenReturn(testTokens);

      await Future.delayed(const Duration(milliseconds: 500));

      final viewModel = container.read(authViewModelProvider.notifier);

      final isAuth = viewModel.isAuthenticated;

      expect(isAuth, true);
    });

    test('should return false when tokens expired', () async {
      final expiredTokens = TokensModel(
        accessToken: 'access_token_123',
        refreshToken: 'refresh_token_123',
        accessTokenExpiry: DateTime.now().subtract(const Duration(hours: 1)),
        refreshTokenExpiry: DateTime.now().subtract(const Duration(days: 1)),
      );
      when(mockLocalRepository.getUser()).thenReturn(testUser);
      when(mockLocalRepository.getTokens()).thenReturn(expiredTokens);

      await Future.delayed(const Duration(milliseconds: 500));

      final viewModel = container.read(authViewModelProvider.notifier);

      final isAuth = viewModel.isAuthenticated;

      expect(isAuth, false);
    });

    test('should return current user', () async {
      when(mockLocalRepository.getUser()).thenReturn(testUser);

      await Future.delayed(const Duration(milliseconds: 500));

      final viewModel = container.read(authViewModelProvider.notifier);

      final user = viewModel.getCurrentUser();

      expect(user, testUser);
    });

    test('should return null when no user', () async {
      when(mockLocalRepository.getUser()).thenReturn(null);

      await Future.delayed(const Duration(milliseconds: 500));

      final viewModel = container.read(authViewModelProvider.notifier);

      final user = viewModel.getCurrentUser();

      expect(user, null);
    });
  });
  group('registerFcmToken', () {
    test('should handle null FCM token gracefully', () async {
      await Future.delayed(const Duration(milliseconds: 500));
      final viewModel = container.read(authViewModelProvider.notifier);
      await viewModel.registerFcmToken();
      verifyNever(
        mockRemoteRepository.registerFcmToken(fcmToken: anyNamed('fcmToken')),
      );
    });

    test('should handle permission denial', () async {
      await Future.delayed(const Duration(milliseconds: 500));
      final viewModel = container.read(authViewModelProvider.notifier);
      await viewModel.registerFcmToken();
      verifyNever(
        mockRemoteRepository.registerFcmToken(fcmToken: anyNamed('fcmToken')),
      );
    });

    test('should handle exceptions during FCM token retrieval', () async {
      await Future.delayed(const Duration(milliseconds: 500));
      final viewModel = container.read(authViewModelProvider.notifier);
      await viewModel.registerFcmToken();
    });
  });
  group('loginWithGoogle', () {
    final testUser = UserModel(
      id: '1',
      name: 'Test User',
      email: 'test@gmail.com',
      username: 'testuser',
      dob: '2004-11-11',
      isEmailVerified: true,
      isVerified: false,
    );

    final testTokens = TokensModel(
      accessToken: 'google_access_token',
      refreshToken: 'google_refresh_token',
      accessTokenExpiry: DateTime.now().add(const Duration(hours: 1)),
      refreshTokenExpiry: DateTime.now().add(const Duration(days: 30)),
    );

    test('should login with Google for new user', () async {
      when(
        mockRemoteRepository.signInWithGoogleAndroid(),
      ).thenAnswer((_) async => right((testUser, testTokens, true)));

      when(
        mockLocalRepository.saveUser(any),
      ).thenAnswer((_) async => Future.value());

      when(
        mockLocalRepository.saveTokens(any),
      ).thenAnswer((_) async => Future.value());

      await Future.delayed(const Duration(milliseconds: 500));

      final viewModel = container.read(authViewModelProvider.notifier);

      await viewModel.loginWithGoogle();

      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);

      final state = container.read(authViewModelProvider);

      expect(state.type, AuthStateType.authenticated);
      expect(state.message, 'new_google_user');

      verify(mockLocalRepository.saveUser(testUser)).called(1);
      verify(mockLocalRepository.saveTokens(testTokens)).called(1);
    });

    test('should login with Google for existing user', () async {
      when(
        mockRemoteRepository.signInWithGoogleAndroid(),
      ).thenAnswer((_) async => right((testUser, testTokens, false)));
      when(
        mockRemoteRepository.getUserInterests(),
      ).thenAnswer((_) async => right(['Tech', 'Business']));
      when(
        mockLocalRepository.saveUser(any),
      ).thenAnswer((_) async => Future.value());
      when(
        mockLocalRepository.saveTokens(any),
      ).thenAnswer((_) async => Future.value());

      await Future.delayed(const Duration(milliseconds: 500));

      final viewModel = container.read(authViewModelProvider.notifier);

      await viewModel.loginWithGoogle();

      final state = container.read(authViewModelProvider);
      expect(state.type, AuthStateType.authenticated);
      expect(state.message, 'google_login_success');

      verify(mockLocalRepository.saveUser(any)).called(2);
    });

    test('should handle Google login failure', () async {
      when(
        mockRemoteRepository.signInWithGoogleAndroid(),
      ).thenAnswer((_) async => left(AppFailure(message: 'Login failed')));

      await Future.delayed(const Duration(milliseconds: 500));

      final viewModel = container.read(authViewModelProvider.notifier);

      await viewModel.loginWithGoogle();

      final state = container.read(authViewModelProvider);
      expect(state.type, AuthStateType.error);
      expect(state.message, 'Login failed');
    });
  });
  group('loginWithGithub', () {
    final testUser = UserModel(
      id: '1',
      name: 'Test User',
      email: 'test@github.com',
      username: 'testuser',
      dob: '2004-11-11',
      isEmailVerified: true,
      isVerified: false,
    );

    final testTokens = TokensModel(
      accessToken: 'github_access_token',
      refreshToken: 'github_refresh_token',
      accessTokenExpiry: DateTime.now().add(const Duration(hours: 1)),
      refreshTokenExpiry: DateTime.now().add(const Duration(days: 30)),
    );

    test('should login with Github for new user', () async {
      when(
        mockRemoteRepository.loginWithGithub(),
      ).thenAnswer((_) async => right((testUser, testTokens, true)));
      when(
        mockLocalRepository.saveUser(any),
      ).thenAnswer((_) async => Future.value());
      when(
        mockLocalRepository.saveTokens(any),
      ).thenAnswer((_) async => Future.value());

      await Future.delayed(const Duration(milliseconds: 500));

      final viewModel = container.read(authViewModelProvider.notifier);

      await viewModel.loginWithGithub();
      await pumpEventQueue();
      await pumpEventQueue();
      final state = container.read(authViewModelProvider);
      expect(state.type, AuthStateType.authenticated);
      expect(state.message, 'new_github_user');

      verify(mockLocalRepository.saveUser(testUser)).called(1);
      verify(mockLocalRepository.saveTokens(testTokens)).called(1);
    });

    test('should login with Github for existing user', () async {
      when(
        mockRemoteRepository.loginWithGithub(),
      ).thenAnswer((_) async => right((testUser, testTokens, false)));
      when(
        mockRemoteRepository.getUserInterests(),
      ).thenAnswer((_) async => right(['Tech', 'Business']));
      when(
        mockLocalRepository.saveUser(any),
      ).thenAnswer((_) async => Future.value());
      when(
        mockLocalRepository.saveTokens(any),
      ).thenAnswer((_) async => Future.value());

      await Future.delayed(const Duration(milliseconds: 500));

      final viewModel = container.read(authViewModelProvider.notifier);

      await viewModel.loginWithGithub();
      await pumpEventQueue();
      await pumpEventQueue();

      final state = container.read(authViewModelProvider);
      expect(state.type, AuthStateType.authenticated);
      expect(state.message, 'github_login_success');

      verify(mockLocalRepository.saveUser(any)).called(2);
    });

    test('should handle Github login failure', () async {
      when(
        mockRemoteRepository.loginWithGithub(),
      ).thenAnswer((_) async => left(AppFailure(message: 'Login failed')));

      await Future.delayed(const Duration(milliseconds: 500));

      final viewModel = container.read(authViewModelProvider.notifier);

      await viewModel.loginWithGithub();

      final state = container.read(authViewModelProvider);
      expect(state.type, AuthStateType.error);
      expect(state.message, 'Login failed');
    });
  });
  group('getCategories', () {
    test('should return list of categories on success', () async {
      final categories = [
        ExploreCategory(id: '1', name: 'Tech'),
        ExploreCategory(id: '2', name: 'Business'),
      ];

      when(
        mockRemoteRepository.getCategories(),
      ).thenAnswer((_) async => right(categories));

      await Future.delayed(const Duration(milliseconds: 500));

      final viewModel = container.read(authViewModelProvider.notifier);

      final result = await viewModel.getCategories();

      expect(result, categories);
      verify(mockRemoteRepository.getCategories()).called(1);
    });

    test('should return empty list on failure', () async {
      when(
        mockRemoteRepository.getCategories(),
      ).thenAnswer((_) async => left(AppFailure(message: 'Failed')));

      await Future.delayed(const Duration(milliseconds: 500));

      final viewModel = container.read(authViewModelProvider.notifier);

      final result = await viewModel.getCategories();

      expect(result, []);
    });
  });
}
