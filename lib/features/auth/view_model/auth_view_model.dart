import 'dart:async';
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
    _checkAuthStatus();
    return AuthState.unauthenticated();
  }

  Future<void> _checkAuthStatus() async {
    final user = _authLocalRepository.getUser();
    final tokens = _authLocalRepository.getTokens();
    if (user != null && tokens != null && !tokens.isAccessTokenExpired) {
      ref.read(currentUserProvider.notifier).adduser(user);
      state = AuthState.authenticated();
      _startAutoRefresh();
    } else {
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

  // Step 4: Update username after signup
  Future<void> updateUsername({required String username}) async {
    state = AuthState.loading();
    final accessToken = getAccessToken();

    if (accessToken == null) {
      state = AuthState.error('No access token found');
      return;
    }

    final result = await _authRemoteRepository.updateUsername(
      Username: username,
      accessToken: accessToken,
    );

    await result.fold(
      (failure) async {
        state = AuthState.error(failure.message);
      },
      (updatedUser) async {
        await _authLocalRepository.saveUser(updatedUser);
        ref.read(currentUserProvider.notifier).adduser(updatedUser);

        state = AuthState.success('Username updated successfully');
      },
    );
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
    if (tokens != null && !tokens.isAccessTokenExpired) {
      return tokens.accessToken;
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

  bool get isAuthenticated {
    final user = _authLocalRepository.getUser();
    final tokens = _authLocalRepository.getTokens();
    return user != null && tokens != null && !tokens.isAccessTokenExpired;
  }

  UserModel? getCurrentUser() {
    return _authLocalRepository.getUser();
  }
}
