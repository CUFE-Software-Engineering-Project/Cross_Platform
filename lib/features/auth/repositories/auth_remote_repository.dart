import 'package:fpdart/fpdart.dart';
import 'package:lite_x/core/classes/AppFailure.dart';
import 'package:lite_x/core/constants/server_constants.dart';
import 'package:lite_x/core/models/usermodel.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:dio/dio.dart';
part 'auth_remote_repository.g.dart';

@Riverpod(keepAlive: true)
AuthRemoteRepository authRemoteRepository(Ref ref) {
  return AuthRemoteRepository(dio: Dio(BASE_OPTIONS));
}

class AuthRemoteRepository {
  final Dio _dio;
  AuthRemoteRepository({required Dio dio}) : _dio = dio;

  // Signup Captcha Verification
  Future<Either<AppFailure, String>> signupCaptcha(String email) async {
    try {
      final response = await _dio.post(
        '/signup_captcha',
        queryParameters: {'email': email},
      );
      return right(response.data['Message'] ?? 'Captcha verified');
    } on DioException catch (e) {
      return left(
        AppFailure(
          message: e.response?.data['error'] ?? 'Captcha verification failed',
        ),
      );
    } catch (e) {
      return left(AppFailure(message: e.toString()));
    }
  }

  // Register new user
  Future<Either<AppFailure, String>> signup({
    required String name,
    required String email,
    required String password,
    required String dateOfBirth,
  }) async {
    try {
      final response = await _dio.post(
        '/signup',
        data: {
          'name': name,
          'email': email,
          'password': password,
          'dateOfBirth': dateOfBirth,
        },
      );
      return right(response.data['message'] ?? 'Verification email sent');
    } on DioException catch (e) {
      return left(
        AppFailure(message: e.response?.data['error'] ?? 'Signup failed'),
      );
    } catch (e) {
      return left(AppFailure(message: e.toString()));
    }
  }

  // Verify signup email with code
  Future<Either<AppFailure, UserModel>> verifySignupEmail({
    required String email,
    required String code,
  }) async {
    try {
      final response = await _dio.post(
        '/verify-signup',
        data: {'email': email, 'code': code},
      );
      final user = UserModel.fromMap(response.data['user']);
      return right(user);
    } on DioException catch (e) {
      return left(
        AppFailure(
          message: e.response?.data['error'] ?? 'Email verification failed',
        ),
      );
    } catch (e) {
      return left(AppFailure(message: e.toString()));
    }
  }

  // Login with email and password
  Future<Either<AppFailure, String>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        '/login',
        data: {'email': email, 'password': password},
      );
      return right(response.data['message'] ?? 'Verification code sent');
    } on DioException catch (e) {
      return left(
        AppFailure(message: e.response?.data['error'] ?? 'Login failed'),
      );
    } catch (e) {
      return left(AppFailure(message: e.toString()));
    }
  }

  // Verify login email with code
  Future<Either<AppFailure, LoginResponse>> verifyLoginEmail({
    required String email,
    required String code,
  }) async {
    try {
      final response = await _dio.post(
        '/verify-login',
        data: {'email': email, 'code': code},
      );

      final user = UserModel.fromMap(response.data['User']);
      final token = response.data['Token'] as String;
      final refreshToken = response.data['Refresh_token'] as String;
      final deviceRecord = response.data['DeviceRecord'];

      return right(
        LoginResponse(
          user: user,
          token: token,
          refreshToken: refreshToken,
          deviceRecord: deviceRecord,
        ),
      );
    } on DioException catch (e) {
      return left(
        AppFailure(
          message: e.response?.data['error'] ?? 'Login verification failed',
        ),
      );
    } catch (e) {
      return left(AppFailure(message: e.toString()));
    }
  }

  // Login Captcha Verification
  Future<Either<AppFailure, String>> loginCaptcha(String email) async {
    try {
      final response = await _dio.get(
        '/captcha',
        queryParameters: {'email': email},
      );
      return right(response.data['Message'] ?? 'Captcha verified');
    } on DioException catch (e) {
      return left(
        AppFailure(
          message: e.response?.data['error'] ?? 'Captcha verification failed',
        ),
      );
    } catch (e) {
      return left(AppFailure(message: e.toString()));
    }
  }

  // Setup 2FA
  Future<Either<AppFailure, TwoFactorSetup>> setup2FA(String token) async {
    try {
      final response = await _dio.post(
        '/2fa/setup',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      return right(
        TwoFactorSetup(
          email: response.data['Email'],
          qrCodePng: response.data['Png'],
          secret: response.data['Secret'],
        ),
      );
    } on DioException catch (e) {
      return left(
        AppFailure(message: e.response?.data['error'] ?? '2FA setup failed'),
      );
    } catch (e) {
      return left(AppFailure(message: e.toString()));
    }
  }

  // Verify 2FA code
  Future<Either<AppFailure, LoginResponse>> verify2FA({
    required String email,
    required String code,
  }) async {
    try {
      final response = await _dio.post(
        '/2fa/verify',
        data: {'email': email, 'code': code},
      );

      final user = UserModel.fromMap(response.data['User']);
      final token = response.data['Token'] as String;
      final refreshToken = response.data['Refresh_token'] as String;

      return right(
        LoginResponse(user: user, token: token, refreshToken: refreshToken),
      );
    } on DioException catch (e) {
      return left(
        AppFailure(
          message: e.response?.data['error'] ?? '2FA verification failed',
        ),
      );
    } catch (e) {
      return left(AppFailure(message: e.toString()));
    }
  }

  // Generate backup login codes
  Future<Either<AppFailure, List<String>>> generateLoginCodes(
    String token,
  ) async {
    try {
      final response = await _dio.post(
        '/generate-login-codes',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      final message = response.data as String;
      final codes = message
          .split('\n')
          .where(
            (line) => line.length == 6 && RegExp(r'^\d{6}$').hasMatch(line),
          )
          .toList();

      return right(codes);
    } on DioException catch (e) {
      return left(
        AppFailure(
          message: e.response?.data['error'] ?? 'Failed to generate codes',
        ),
      );
    } catch (e) {
      return left(AppFailure(message: e.toString()));
    }
  }

  // Verify login code
  Future<Either<AppFailure, LoginResponse>> verifyLoginCode({
    required String email,
    required String code,
  }) async {
    try {
      final response = await _dio.post(
        '/verify-login-code',
        data: {'email': email, 'code': code},
      );

      final user = UserModel.fromMap(response.data['User']);
      final token = response.data['Token'] as String;
      final refreshToken = response.data['Refresh_token'] as String;

      return right(
        LoginResponse(user: user, token: token, refreshToken: refreshToken),
      );
    } on DioException catch (e) {
      return left(
        AppFailure(
          message:
              e.response?.data['error'] ?? 'Login code verification failed',
        ),
      );
    } catch (e) {
      return left(AppFailure(message: e.toString()));
    }
  }

  // Forget Password
  Future<Either<AppFailure, String>> forgetPassword({
    required String email,
    required String token,
  }) async {
    try {
      final response = await _dio.post(
        '/forget-password',
        data: {'email': email},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return right(response.data['message'] ?? 'Reset token sent to email');
    } on DioException catch (e) {
      return left(
        AppFailure(
          message: e.response?.data['error'] ?? 'Failed to send reset email',
        ),
      );
    } catch (e) {
      return left(AppFailure(message: e.toString()));
    }
  }

  // Reset Password
  Future<Either<AppFailure, String>> resetPassword({
    required String email,
    required String token,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        '/reset-password',
        data: {'email': email, 'token': token, 'password': password},
      );
      return right(response.data['message'] ?? 'Password reset successfully');
    } on DioException catch (e) {
      return left(
        AppFailure(
          message: e.response?.data['error'] ?? 'Password reset failed',
        ),
      );
    } catch (e) {
      return left(AppFailure(message: e.toString()));
    }
  }

  // Refresh token
  Future<Either<AppFailure, String>> refreshToken() async {
    try {
      final response = await _dio.get('/refresh');
      return right(response.data['NewAcesstoken'] as String);
    } on DioException catch (e) {
      return left(
        AppFailure(
          message: e.response?.data['error'] ?? 'Token refresh failed',
        ),
      );
    } catch (e) {
      return left(AppFailure(message: e.toString()));
    }
  }

  // Logout
  Future<Either<AppFailure, String>> logout(String token) async {
    try {
      final response = await _dio.post(
        '/logout',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return right(response.data['message'] ?? 'Logged out successfully');
    } on DioException catch (e) {
      return left(
        AppFailure(message: e.response?.data['error'] ?? 'Logout failed'),
      );
    } catch (e) {
      return left(AppFailure(message: e.toString()));
    }
  }

  // Logout from all sessions
  Future<Either<AppFailure, String>> logoutAll(String token) async {
    try {
      final response = await _dio.post(
        '/logout-all',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return right(response.data['message'] ?? 'Logged out from all sessions');
    } on DioException catch (e) {
      return left(
        AppFailure(message: e.response?.data['error'] ?? 'Logout all failed'),
      );
    } catch (e) {
      return left(AppFailure(message: e.toString()));
    }
  }

  // Re-authenticate with password
  Future<Either<AppFailure, String>> reauthPassword({
    required String email,
    required String password,
    required String token,
  }) async {
    try {
      final response = await _dio.post(
        '/reauth-password',
        data: {'email': email, 'password': password},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return right(response.data['message'] ?? 'Reauthentication successful');
    } on DioException catch (e) {
      return left(
        AppFailure(
          message: e.response?.data['error'] ?? 'Reauthentication failed',
        ),
      );
    } catch (e) {
      return left(AppFailure(message: e.toString()));
    }
  }

  // Re-authenticate with 2FA
  Future<Either<AppFailure, String>> reauthTFA({
    required String email,
    required String code,
    required String token,
  }) async {
    try {
      final response = await _dio.post(
        '/reauth-tfa',
        data: {'email': email, 'code': code},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return right(response.data['message'] ?? 'Reauthentication successful');
    } on DioException catch (e) {
      return left(
        AppFailure(
          message: e.response?.data['error'] ?? 'Reauthentication failed',
        ),
      );
    } catch (e) {
      return left(AppFailure(message: e.toString()));
    }
  }

  // Re-authenticate with backup code
  Future<Either<AppFailure, String>> reauthCode({
    required String email,
    required String code,
    required String token,
  }) async {
    try {
      final response = await _dio.post(
        '/reauth-code',
        data: {'email': email, 'code': code},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return right(response.data['message'] ?? 'Reauthentication successful');
    } on DioException catch (e) {
      return left(
        AppFailure(
          message: e.response?.data['error'] ?? 'Reauthentication failed',
        ),
      );
    } catch (e) {
      return left(AppFailure(message: e.toString()));
    }
  }

  // Change password
  Future<Either<AppFailure, String>> changePassword({
    required String password,
    required String confirm,
    required String token,
  }) async {
    try {
      final response = await _dio.post(
        '/change-password',
        data: {'password': password, 'confirm': confirm},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return right(response.data['Message'] ?? 'Password changed successfully');
    } on DioException catch (e) {
      return left(
        AppFailure(
          message: e.response?.data['error'] ?? 'Password change failed',
        ),
      );
    } catch (e) {
      return left(AppFailure(message: e.toString()));
    }
  }

  // Change email
  Future<Either<AppFailure, String>> changeEmail({
    required String newEmail,
    required String currentEmail,
    required String token,
  }) async {
    try {
      final response = await _dio.post(
        '/change-email',
        data: {'email': newEmail, 'currentEmail': currentEmail},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return right(response.data['message'] ?? 'Verification email sent');
    } on DioException catch (e) {
      return left(
        AppFailure(message: e.response?.data['error'] ?? 'Email change failed'),
      );
    } catch (e) {
      return left(AppFailure(message: e.toString()));
    }
  }

  // Verify new email
  Future<Either<AppFailure, String>> verifyNewEmail({
    required String email,
    required String code,
    required String currentEmail,
    required String token,
  }) async {
    try {
      final response = await _dio.post(
        '/verify-new-email',
        data: {'email': email, 'code': code, 'currentEmail': currentEmail},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return right(response.data['message'] ?? 'Email changed successfully');
    } on DioException catch (e) {
      return left(
        AppFailure(
          message: e.response?.data['error'] ?? 'Email verification failed',
        ),
      );
    } catch (e) {
      return left(AppFailure(message: e.toString()));
    }
  }

  // Get user info
  Future<Either<AppFailure, UserModel>> getUser(String token) async {
    try {
      final response = await _dio.get(
        '/user',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      final user = UserModel.fromMap(response.data['User']);
      return right(user);
    } on DioException catch (e) {
      return left(
        AppFailure(message: e.response?.data['error'] ?? 'Failed to get user'),
      );
    } catch (e) {
      return left(AppFailure(message: e.toString()));
    }
  }

  // Get active sessions
  Future<Either<AppFailure, List<SessionInfo>>> getSessions(
    String token,
  ) async {
    try {
      final response = await _dio.get(
        '/sessions',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      final sessionsList = response.data as List;
      final sessions = sessionsList
          .map((s) => SessionInfo.fromMap(s as Map<String, dynamic>))
          .toList();

      return right(sessions);
    } on DioException catch (e) {
      return left(
        AppFailure(
          message: e.response?.data['error'] ?? 'Failed to get sessions',
        ),
      );
    } catch (e) {
      return left(AppFailure(message: e.toString()));
    }
  }

  // Logout specific session
  Future<Either<AppFailure, String>> logoutSession({
    required String sessionId,
    required String token,
  }) async {
    try {
      final response = await _dio.delete(
        '/session/$sessionId',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return right(response.data['message'] ?? 'Session logged out');
    } on DioException catch (e) {
      return left(
        AppFailure(
          message: e.response?.data['error'] ?? 'Failed to logout session',
        ),
      );
    } catch (e) {
      return left(AppFailure(message: e.toString()));
    }
  }

  // OAuth - Google Sign In
  Future<Either<AppFailure, LoginResponse>> googleSignIn(String code) async {
    try {
      final response = await _dio.get(
        '/oauth2/callback/google',
        queryParameters: {'code': code},
      );

      final user = UserModel.fromMap(response.data['user']);
      final token = response.data['token']['token'] as String;

      return right(
        LoginResponse(user: user, token: token, refreshToken: token),
      );
    } on DioException catch (e) {
      return left(
        AppFailure(
          message: e.response?.data['error'] ?? 'Google sign-in failed',
        ),
      );
    } catch (e) {
      return left(AppFailure(message: e.toString()));
    }
  }

  // OAuth - GitHub Sign In
  Future<Either<AppFailure, LoginResponse>> githubSignIn(String code) async {
    try {
      final response = await _dio.get(
        '/oauth2/callback/github',
        queryParameters: {'code': code},
      );

      final user = UserModel.fromMap(response.data['user']);
      final token = response.data['token']['token'] as String;

      return right(
        LoginResponse(user: user, token: token, refreshToken: token),
      );
    } on DioException catch (e) {
      return left(
        AppFailure(
          message: e.response?.data['error'] ?? 'GitHub sign-in failed',
        ),
      );
    } catch (e) {
      return left(AppFailure(message: e.toString()));
    }
  }
}

// Helper classes for responses
class LoginResponse {
  final UserModel user;
  final String token;
  final String refreshToken;
  final dynamic deviceRecord;

  LoginResponse({
    required this.user,
    required this.token,
    required this.refreshToken,
    this.deviceRecord,
  });
}

class TwoFactorSetup {
  final String email;
  final String qrCodePng;
  final String secret;

  TwoFactorSetup({
    required this.email,
    required this.qrCodePng,
    required this.secret,
  });
}

class SessionInfo {
  final String jti;
  final String deviceId;
  final String userAgent;
  final String ip;
  final String location;
  final String createdAt;
  final String expireAt;

  SessionInfo({
    required this.jti,
    required this.deviceId,
    required this.userAgent,
    required this.ip,
    required this.location,
    required this.createdAt,
    required this.expireAt,
  });

  factory SessionInfo.fromMap(Map<String, dynamic> map) {
    return SessionInfo(
      jti: map['Jti'] as String? ?? '',
      deviceId: map['DeviceId'] as String? ?? '',
      userAgent: map['UserAgent'] as String? ?? '',
      ip: map['Ip'] as String? ?? '',
      location: map['Location'] as String? ?? '',
      createdAt: map['CreatedAt'] as String? ?? '',
      expireAt: map['ExpireAt'] as String? ?? '',
    );
  }
}
