import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:lite_x/core/classes/PickedImage.dart';
import 'package:lite_x/core/models/usermodel.dart';
import 'package:lite_x/features/auth/repositories/auth_local_repository.dart';
import 'package:lite_x/features/auth/repositories/auth_remote_repository.dart';
import 'package:lite_x/features/auth/view_model/auth_state.dart';
import 'package:lite_x/core/providers/current_user_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
part 'auth_view_model.g.dart';

@Riverpod(keepAlive: true)
class AuthViewModel extends _$AuthViewModel {
  late AuthRemoteRepository _authRemoteRepository;
  late AuthLocalRepository _authLocalRepository;

  @override
  AuthState build() {
    _authRemoteRepository = ref.read(authRemoteRepositoryProvider);
    _authLocalRepository = ref.read(authLocalRepositoryProvider);
    Future(() async {
      await Future.delayed(const Duration(milliseconds: 300));
      await _checkAuthStatus();
    });
    return AuthState.loading();
  }

  Future<void> _checkAuthStatus() async {
    try {
      await Future.delayed(const Duration(milliseconds: 100));
      final user = _authLocalRepository.getUser();
      final tokens = _authLocalRepository.getTokens();

      if (user != null && tokens != null) {
        if (!tokens.isRefreshTokenExpired) {
          ref.read(currentUserProvider.notifier).adduser(user);
          state = AuthState.authenticated();
          _registerFcmToken();
          _listenForFcmTokenRefresh();
        } else {
          await logout();
          state = AuthState.unauthenticated();
        }
      } else {
        state = AuthState.unauthenticated();
      }
    } catch (e) {
      state = AuthState.unauthenticated();
    }
  }

  //--------------------------------------------SignUp---------------------------------------------------------//
  Future<void> createAccount({
    required String name,
    required String email,
    required String dateOfBirth,
  }) async {
    state = AuthState.loading();

    final result = await _authRemoteRepository.create(
      name: name,
      email: email,
      dateOfBirth: dateOfBirth,
    );

    result.fold(
      (failure) => state = AuthState.error(failure.message),
      (message) => state = AuthState.success(message),
    );
  }

  Future<void> verifySignupEmail({
    required String email,
    required String code,
  }) async {
    state = AuthState.loading();

    final result = await _authRemoteRepository.verifySignupEmail(
      email: email,
      code: code,
    );

    result.fold(
      (failure) => state = AuthState.error(failure.message),
      (message) => state = AuthState.verified(message),
    );
  }

  Future<void> finalizeSignup({
    required String email,
    required String password,
  }) async {
    state = AuthState.loading();

    final result = await _authRemoteRepository.signup(
      email: email,
      password: password,
    );

    await result.fold(
      (failure) async {
        state = AuthState.error(failure.message);
      },
      (data) async {
        final (user, tokens) = data;
        await Future.wait([
          _authLocalRepository.saveUser(user),
          _authLocalRepository.saveTokens(tokens),
        ]);
        ref.read(currentUserProvider.notifier).adduser(user);
        state = AuthState.authenticated('Signup successful');
        _registerFcmToken();
        _listenForFcmTokenRefresh();
      },
    );
  }

  Future<void> uploadProfilePhoto(PickedImage pickedImage) async {
    state = AuthState.loading();
    final accessToken = getAccessToken();

    if (accessToken == null) {
      state = AuthState.error('Session expired. Please login again.');
      return;
    }

    final result = await _authRemoteRepository.uploadProfilePhoto(
      pickedImage: pickedImage,
    );

    result.fold(
      (failure) {
        state = AuthState.error(failure.message);
      },
      (keyName) {
        state = AuthState.success("Profile photo uploaded");
      },
    );
  }

  Future<void> updateUsername({required String username}) async {
    state = AuthState.loading();

    final currentUser = ref.read(currentUserProvider);
    if (currentUser == null) {
      state = AuthState.error('User not found');
      return;
    }

    final result = await _authRemoteRepository.updateUsername(
      currentUser: currentUser,
      Username: username,
    );

    await result.fold(
      (failure) async {
        state = AuthState.error(failure.message);
      },
      (data) async {
        final updatedUser = data;
        // await _authLocalRepository.saveTokens(newTokens);
        await _authLocalRepository.saveUser(updatedUser);
        ref.read(currentUserProvider.notifier).adduser(updatedUser);
        state = AuthState.success('Username updated successfully');
      },
    );
  }

  Future<void> saveInterests(Set<String> interests) async {
    state = AuthState.loading();
    try {
      final currentUser = ref.read(currentUserProvider);
      if (currentUser == null) {
        state = AuthState.error("User not found!");
        return;
      }
      final updatedUser = currentUser.copyWith(interests: interests);
      await _authLocalRepository.saveUser(updatedUser);
      ref.read(currentUserProvider.notifier).adduser(updatedUser);
      state = AuthState.success("Interests saved successfully");
    } catch (e) {
      state = AuthState.error(e.toString());
    }
  }

  //----------------------------------------------------FCM Token Registration----------------------------------------------------------------------------------------//
  Future<void> _registerFcmToken() async {
    try {
      FirebaseMessaging messaging = FirebaseMessaging.instance;
      NotificationSettings settings = await messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        final fcmToken = await messaging.getToken();
        if (fcmToken == null) {
          return;
        }
        String osType;
        if (Platform.isAndroid) {
          osType = 'Android';
        } else if (Platform.isIOS) {
          osType = 'IOS';
        } else {
          osType = 'unknown';
        }
        final result = await _authRemoteRepository.registerFcmToken(
          fcmToken: fcmToken,
          osType: osType,
        );
        result.fold(
          (failure) =>
              print("FCM: Failed to register token: ${failure.message}"),
          (message) => print("FCM: Token registered successfully: $message"),
        );
      } else {
        print('User declined or has not accepted permission');
      }
    } catch (e) {
      print("FCM: Error getting/registering token: $e");
    }
  }

  void _listenForFcmTokenRefresh() {
    FirebaseMessaging.instance.onTokenRefresh.listen((newFcmToken) {
      _registerFcmToken();
    });
  }

  //-------------------------------------------------Login--------------------------------------------------------------------------------------//
  Future<void> login({required String email, required String password}) async {
    state = AuthState.loading();
    final result = await _authRemoteRepository.login(
      email: email,
      password: password,
    );
    result.fold((failure) => state = AuthState.error(failure.message), (
      data,
    ) async {
      final (user, tokens) = data;
      await Future.wait([
        _authLocalRepository.saveUser(user),
        _authLocalRepository.saveTokens(tokens),
      ]);
      ref.read(currentUserProvider.notifier).adduser(user);
      state = AuthState.authenticated('Login successful');
    });
  }

  //-------------------------------------------------Logout--------------------------------------------------------------------------------------//
  Future<void> logout() async {
    try {
      await _authLocalRepository.clearTokens();
      await _authLocalRepository.clearUser();
      ref.read(currentUserProvider.notifier).clearUser();
      state = AuthState.unauthenticated();
    } catch (e) {
      print("Logout error: $e");
    }
  }

  //-------------------------------------------------Email Check--------------------------------------------------------------------------------------//
  Future<bool?> validateEmail(String email) async {
    final result = await _authRemoteRepository.check_email(email: email);
    return result.fold((failure) => null, (exists) => exists);
  }

  Future<void> checkEmail({required String email}) async {
    state = AuthState.loading();
    final bool? exists = await validateEmail(email);
    if (exists == true) {
      state = AuthState.success("Email found");
    } else if (exists == false) {
      state = AuthState.error("Email not found. Please create an account.");
    } else {
      state = AuthState.error("Failed to check email. Please try again.");
    }
  }

  //-------------------------------------------------Forget Password--------------------------------------------------------------------------------------//
  Future<void> forgetPassword({required String email}) async {
    state = AuthState.loading();
    final result = await _authRemoteRepository.forget_password(email: email);
    result.fold(
      (failure) {
        state = AuthState.error(failure.message);
      },
      (message) {
        state = AuthState.success(message);
      },
    );
  }

  Future<void> verifyResetCode({
    required String email,
    required String code,
  }) async {
    state = AuthState.loading();
    final result = await _authRemoteRepository.verify_reset_code(
      email: email,
      code: code,
    );
    result.fold(
      (failure) {
        state = AuthState.error(failure.message);
      },
      (message) {
        state = AuthState.awaitingPassword(message);
      },
    );
  }

  Future<void> resetPassword({
    required String email,
    required String password,
  }) async {
    state = AuthState.loading();
    final result = await _authRemoteRepository.reset_password(
      email: email,
      password: password,
    );

    result.fold(
      (failure) {
        state = AuthState.error(failure.message);
      },
      (message) {
        state = AuthState.success(message);
      },
    );
  }

  //------------------------------------------------------updatepassword-----------------------------------------------------------------//
  Future<void> updatePassword({
    required String password,
    required String newpassword,
    required String confirmPassword,
  }) async {
    state = AuthState.loading();
    final result = await _authRemoteRepository.update_password(
      password: password,
      newpassword: newpassword,
      confirmPassword: confirmPassword,
    );
    result.fold(
      (failure) {
        state = AuthState.error(failure.message);
      },
      (message) {
        state = AuthState.success(message);
      },
    );
  }

  //------------------------------------------------------updateemail-----------------------------------------------------------------//
  Future<void> updateEmail({required String newEmail}) async {
    state = AuthState.loading();
    final result = await _authRemoteRepository.update_email(newemail: newEmail);

    result.fold(
      (failure) {
        state = AuthState.error(failure.message);
      },
      (message) {
        state = AuthState.awaitingVerification(message);
      },
    );
  }

  Future<void> verifyNewEmail({
    required String newEmail,
    required String code,
  }) async {
    state = AuthState.loading();
    final result = await _authRemoteRepository.verify_new_email(
      newemail: newEmail,
      code: code,
    );
    await result.fold(
      (failure) async {
        state = AuthState.error(failure.message);
      },
      (message) async {
        try {
          final currentUser = ref.read(currentUserProvider);
          if (currentUser == null) {
            state = AuthState.error("User not found to update email");
            return;
          }
          final updatedUser = currentUser.copyWith(email: newEmail);
          await _authLocalRepository.saveUser(updatedUser);
          ref.read(currentUserProvider.notifier).adduser(updatedUser);
          state = AuthState.success(message);
        } catch (e) {
          state = AuthState.error("Failed to update email: $e");
        }
      },
    );
  }

  //-------------------------------------------------Token Management--------------------------------------------------------------------------------------//
  String? getAccessToken() {
    final tokens = _authLocalRepository.getTokens();
    return tokens?.accessToken;
  }

  String? getRefreshToken() {
    final tokens = _authLocalRepository.getTokens();
    if (tokens != null && !tokens.isRefreshTokenExpired) {
      return tokens.refreshToken;
    }
    return null;
  }

  //-------------------------------------------------Helper Methods--------------------------------------------------------------------------------------//
  void resetState() {
    state = AuthState.unauthenticated();
  }

  void setAuthenticated() {
    state = AuthState.authenticated();
  }

  bool get isAuthenticated {
    final user = _authLocalRepository.getUser();
    final tokens = _authLocalRepository.getTokens();
    return user != null && tokens != null && !tokens.isRefreshTokenExpired;
  }

  UserModel? getCurrentUser() {
    return _authLocalRepository.getUser();
  }
}
