import 'package:fpdart/fpdart.dart';
import 'package:lite_x/core/classes/AppFailure.dart';
import 'package:lite_x/core/classes/PickedImage.dart';
import 'package:lite_x/core/models/TokensModel.dart';
import 'package:lite_x/core/models/usermodel.dart';
import 'package:lite_x/core/providers/dio_interceptor.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:dio/dio.dart';

part 'auth_remote_repository.g.dart';

@Riverpod(keepAlive: true)
AuthRemoteRepository authRemoteRepository(Ref ref) {
  final dio = ref.watch(dioProvider);
  return AuthRemoteRepository(dio: dio);
}

class AuthRemoteRepository {
  final Dio _dio;

  AuthRemoteRepository({required Dio dio}) : _dio = dio;

  //--------------------------------------------SignUp---------------------------------------------------------//
  // Register new user
  Future<Either<AppFailure, String>> create({
    required String name,
    required String email,
    required String dateOfBirth,
  }) async {
    try {
      final response = await _dio.post(
        'auth/signup',
        data: {'name': name, 'email': email, 'dateOfBirth': dateOfBirth},
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
  Future<Either<AppFailure, String>> verifySignupEmail({
    required String email,
    required String code,
  }) async {
    try {
      final response = await _dio.post(
        'auth/verify-signup',
        data: {'email': email, 'code': code},
      );

      final message = response.data['message'] ?? 'Verified successfully';
      return right(message);
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

  //finalize signup by setting password
  Future<Either<AppFailure, (UserModel, TokensModel)>> signup({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        'auth/finalize_signup',
        data: {'email': email, 'password': password},
      );

      final user = UserModel.fromMap(response.data['user']);
      final tokens = TokensModel.fromMap(response.data['tokens']);
      return right((user, tokens));
    } on DioException catch (e) {
      return left(
        AppFailure(message: e.response?.data['error'] ?? 'Signup failed'),
      );
    } catch (e) {
      return left(AppFailure(message: e.toString()));
    }
  }

  static const Map<String, String> _mediaTypes = {
    'jpg': 'image/jpeg',
    'jpeg': 'image/jpeg',
    'png': 'image/png',
    'gif': 'image/gif',
    'webp': 'image/webp',
  };
  String _getMediaType(String filePath) {
    final extension = filePath.split('.').last.toLowerCase();
    return _mediaTypes[extension] ?? 'image/jpeg';
  }

  Future<Either<AppFailure, String>> uploadProfilePhoto({
    required PickedImage pickedImage,
  }) async {
    if (pickedImage.file == null) {
      return left(AppFailure(message: 'No file selected'));
    }
    final file = pickedImage.file!;
    final fileName = pickedImage.name;
    final fileType = _getMediaType(file.path);
    try {
      final requestResponse = await _dio.post(
        'media/upload-request',
        data: {'fileName': fileName, 'contentType': fileType},
      );
      final String presignedUrl = requestResponse.data['url'];
      final String keyName = requestResponse.data['keyName'];
      await _dio.put(
        presignedUrl,
        data: file.openRead(),
        options: Options(
          headers: {
            'Content-Type': fileType,
            'Content-Length': await file.length(),
          },
        ),
      );

      final encodedKeyName = Uri.encodeComponent(keyName);
      final confirmResponse = await _dio.post(
        'media/confirm-upload/$encodedKeyName',
      );
      final newMediaKey = confirmResponse.data['newMedia']['keyName'] as String;
      return right(newMediaKey);
    } on DioException catch (e) {
      return left(
        AppFailure(message: e.response?.data['error'] ?? 'Upload failed'),
      );
    } catch (e) {
      return left(AppFailure(message: e.toString()));
    }
  }

  Future<Either<AppFailure, UserModel>> updateUsername({
    required UserModel currentUser,
    required String Username,
    required String accessToken,
  }) async {
    try {
      final response = await _dio.put(
        'auth/update_username',
        data: {'username': Username},
      );
      final newUsername = response.data['user']['username'] as String;
      final updatedUser = currentUser.copyWith(username: newUsername);
      return right(updatedUser);
    } on DioException catch (e) {
      final errorMsg = e.response?.data['error'] ?? 'Failed to update username';
      return left(AppFailure(message: errorMsg));
    } catch (e) {
      return left(AppFailure(message: e.toString()));
    }
  }

  //-------------------------------------------------FCM Token Registration-----------------------------------------------------------------------------------------//
  Future<Either<AppFailure, String>> registerFcmToken({
    required String fcmToken,
    required String osType,
  }) async {
    try {
      final data = {'token': fcmToken, 'osType': osType};
      final response = await _dio.post('users/fcm-token', data: data);
      return right(response.data['message'] ?? 'FCM registered successfully');
    } on DioException catch (e) {
      return left(
        AppFailure(
          message: e.response?.data['error'] ?? 'FCM registration failed',
        ),
      );
    } catch (e) {
      return left(AppFailure(message: e.toString()));
    }
  }

  //-------------------------------------------------Login--------------------------------------------------------------------------------------//
  // Login with email and password
  Future<Either<AppFailure, (UserModel, TokensModel)>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        'auth/login',
        data: {'email': email, 'password': password},
      );

      final user = UserModel.fromMap(response.data['User']);
      final tokens = TokensModel.fromMap_login(response.data);

      return right((user, tokens));
    } on DioException catch (e) {
      return left(
        AppFailure(message: e.response?.data['error'] ?? 'Login failed'),
      );
    } catch (e) {
      return left(AppFailure(message: e.toString()));
    }
  }

  Future<Either<AppFailure, bool>> check_email({required String email}) async {
    try {
      final response = await _dio.post('auth/getUser', data: {'email': email});
      return right(response.data['exists'] ?? false);
    } on DioException catch (e) {
      return left(
        AppFailure(message: e.response?.data['error'] ?? 'Email check failed'),
      );
    } catch (e) {
      return left(AppFailure(message: e.toString()));
    }
  }

  //------------------------------------------------------------------------------------------------------//
  Future<Either<AppFailure, String>> forget_password({
    required String email,
  }) async {
    try {
      final response = await _dio.post(
        'auth/forget-password',
        data: {'email': email},
      );
      final message = response.data['message'] ?? 'Reset code sent';
      return right(message);
    } on DioException catch (e) {
      return left(
        AppFailure(
          message: e.response?.data['error'] ?? 'Forget password failed',
        ),
      );
    } catch (e) {
      return left(AppFailure(message: e.toString()));
    }
  }

  Future<Either<AppFailure, String>> verify_reset_code({
    required String email,
    required String code,
  }) async {
    try {
      final response = await _dio.post(
        'auth/verify-reset-code',
        data: {'email': email, 'code': code},
      );
      final message = response.data['message'] ?? 'Reset code verified';
      return right(message);
    } on DioException catch (e) {
      return left(
        AppFailure(
          message: e.response?.data['error'] ?? 'Verify reset code failed',
        ),
      );
    } catch (e) {
      return left(AppFailure(message: e.toString()));
    }
  }

  Future<Either<AppFailure, String>> reset_password({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        'auth/reset-password',
        data: {'email': email, 'password': password},
      );
      final message = response.data['message'] ?? 'Password reset successful';
      return right(message);
    } on DioException catch (e) {
      return left(
        AppFailure(
          message: e.response?.data['error'] ?? 'Reset password failed',
        ),
      );
    } catch (e) {
      return left(AppFailure(message: e.toString()));
    }
  }

  //-------------------------------------------------------------------------------token management--------------------------------------------------------------------------------------------//
  Future<Either<AppFailure, TokensModel>> refreshToken(
    String refreshToken,
    DateTime refreshTokenExpiry,
  ) async {
    try {
      final response = await _dio.post(
        'auth/refresh',
        data: {'refresh_token': refreshToken},
        options: Options(headers: {'Content-Type': 'application/json'}),
      );
      final newAccessToken = response.data['access_token'] as String?;
      if (newAccessToken == null) {
        return left(
          AppFailure(
            message: 'Refresh response did not contain new access token',
          ),
        );
      }
      final tokens = TokensModel(
        accessToken: newAccessToken,
        refreshToken: refreshToken,
        accessTokenExpiry: DateTime.now().add(const Duration(hours: 1)),
        refreshTokenExpiry: refreshTokenExpiry,
      );
      return right(tokens);
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
}
