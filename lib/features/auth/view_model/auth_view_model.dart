import 'dart:async';
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
  Timer? _refreshTimer;

  @override
  AuthState build() {
    _authRemoteRepository = ref.read(authRemoteRepositoryProvider);
    _authLocalRepository = ref.read(authLocalRepositoryProvider);

    // Schedule check for next frame to avoid blocking build
    Future.microtask(() => _checkAuthStatus());

    return AuthState.loading();
  }

  Future<void> _checkAuthStatus() async {
    print('🔍 Checking auth status...');

    try {
      await Future.delayed(
        Duration(milliseconds: 100),
      ); // Small delay to ensure UI is ready

      final user = _authLocalRepository.getUser();
      final tokens = _authLocalRepository.getTokens();

      print('👤 User: ${user?.name ?? "null"}');
      print('🔑 Tokens: ${tokens != null ? "exists" : "null"}');

      if (user != null && tokens != null && !tokens.isAccessTokenExpired) {
        print('✅ User is authenticated');
        ref.read(currentUserProvider.notifier).adduser(user);
        state = AuthState.authenticated();
        _startAutoRefresh();
      } else {
        print('❌ User is not authenticated');
        state = AuthState.unauthenticated();
      }
    } catch (e) {
      print('❗ Error checking auth status: $e');
      state = AuthState.unauthenticated();
    }
  }

  //--------------------------------------------SignUp Flow---------------------------------------------------------//
  // Step 1: Create account
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

  // Step 2: Verify signup email with code
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

  // Step 3: Finalize signup
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
        await _authLocalRepository.saveUser(user);
        await _authLocalRepository.saveTokens(tokens);
        ref.read(currentUserProvider.notifier).adduser(user);
        state = AuthState.authenticated('Signup successful');
        _startAutoRefresh();
      },
    );
  }

  // Step 4: Upload profile photo
  Future<void> uploadProfilePhoto(PickedImage pickedImage) async {
    state = AuthState.loading();

    // Try to get access token, refresh if needed
    String? accessToken = getAccessToken();

    if (accessToken == null) {
      print('⚠️ Access token expired, attempting refresh...');
      await refreshAccessToken();
      accessToken = getAccessToken();

      if (accessToken == null) {
        print('❌ Failed to refresh token');
        state = AuthState.error('Session expired. Please login again.');
        return;
      }
      print('✅ Token refreshed successfully');
    }

    final result = await _authRemoteRepository.uploadProfilePhoto(
      pickedImage: pickedImage,
      accessToken: accessToken,
    );

    result.fold(
      (failure) {
        print('❌ Photo upload failed: ${failure.message}');
        state = AuthState.error(failure.message);
      },
      (keyName) {
        print('✅ Photo uploaded successfully');
        state = AuthState.success("Profile photo uploaded");
      },
    );
  }

  // Step 5: Update username after signup
  Future<void> updateUsername({required String username}) async {
    state = AuthState.loading();

    // Get current user first
    final currentUser = ref.read(currentUserProvider);
    if (currentUser == null) {
      print('❌ No current user found');
      state = AuthState.error('User not found');
      return;
    }

    // Try to get access token, refresh if needed
    String? accessToken = getAccessToken();

    if (accessToken == null) {
      print('⚠️ Access token expired, attempting refresh...');
      await refreshAccessToken();
      accessToken = getAccessToken();

      if (accessToken == null) {
        print('❌ Failed to refresh token');
        state = AuthState.error('Session expired. Please login again.');
        return;
      }
      print('✅ Token refreshed successfully');
    }

    print('🔑 Using access token for username update');

    final result = await _authRemoteRepository.updateUsername(
      currentUser: currentUser,
      Username: username,
      accessToken: accessToken,
    );

    await result.fold(
      (failure) async {
        print('❌ Username update failed: ${failure.message}');
        state = AuthState.error(failure.message);
      },
      (updatedUser) async {
        print('✅ Username updated successfully');
        await _authLocalRepository.saveUser(updatedUser);
        ref.read(currentUserProvider.notifier).adduser(updatedUser);
        state = AuthState.success('Username updated successfully');
      },
    );
  }

  //step 6: Interests selected after signup
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

  //-------------------------------------------------Login Flow--------------------------------------------------------------------------------------//
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
      await _authLocalRepository.saveUser(user);
      await _authLocalRepository.saveTokens(tokens);

      ref.read(currentUserProvider.notifier).adduser(user);
      state = AuthState.authenticated('Login successful');
      _startAutoRefresh();
    });
  }

  //-------------------------------------------------Email Check--------------------------------------------------------------------------------------//
  Future<bool?> validateEmailOnBackend(String email) async {
    final result = await _authRemoteRepository.check_email(email: email);

    return result.fold(
      (failure) {
        return null;
      },
      (exists) {
        return exists;
      },
    );
  }

  Future<bool?> checkEmail({required String email}) async {
    state = AuthState.loading();
    final result = await _authRemoteRepository.check_email(email: email);
    return result.fold(
      (failure) {
        state = AuthState.error(failure.message);
        return null;
      },
      (exists) {
        state = AuthState.unauthenticated();
        return exists;
      },
    );
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

  //-------------------------------------------------Token Management--------------------------------------------------------------------------------------//
  void _startAutoRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(const Duration(minutes: 15), (_) async {
      await refreshAccessToken();
    });
  }

  Future<void> refreshAccessToken() async {
    final currentTokens = _authLocalRepository.getTokens();

    if (currentTokens == null) {
      print('No refresh token details found, cannot refresh');
      return;
    }

    if (currentTokens.isRefreshTokenExpired) {
      print('Refresh token is expired. Logging out.');
      return;
    }

    final result = await _authRemoteRepository.refreshToken(
      currentTokens.refreshToken,
      currentTokens.refreshTokenExpiry,
    );

    result.fold(
      (failure) {
        print("Refresh failed: ${failure.message}");
      },
      (newTokens) async {
        await _authLocalRepository.saveTokens(newTokens);
        print("Token refreshed successfully.");
      },
    );
  }

  String? getAccessToken() {
    final tokens = _authLocalRepository.getTokens();
    print('🔍 Getting access token...');
    print('📦 Tokens exist: ${tokens != null}');

    if (tokens != null) {
      print('⏰ Access token expired: ${tokens.isAccessTokenExpired}');
      print('📅 Expiry time: ${tokens.accessTokenExpiry}');
      print('🕒 Current time: ${DateTime.now()}');

      if (!tokens.isAccessTokenExpired) {
        print('✅ Token is valid');
        return tokens.accessToken;
      } else {
        print('❌ Token is expired');
      }
    }
    return null;
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
    return user != null && tokens != null && !tokens.isAccessTokenExpired;
  }

  UserModel? getCurrentUser() {
    return _authLocalRepository.getUser();
  }
}
