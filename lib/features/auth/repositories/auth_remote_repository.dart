import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:fpdart/fpdart.dart';
import 'package:lite_x/core/classes/AppFailure.dart';
import 'package:lite_x/core/constants/server_constants.dart';
import 'package:lite_x/core/models/TokensModel.dart';
import 'package:lite_x/core/models/usermodel.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:dio/dio.dart';
import 'package:url_launcher/url_launcher.dart';
part 'auth_remote_repository.g.dart';

@Riverpod(keepAlive: true)
AuthRemoteRepository authRemoteRepository(Ref ref) {
  return AuthRemoteRepository(dio: Dio(BASE_OPTIONS));
}

class AuthRemoteRepository {
  final String API_URL = dotenv.env["API_URL"]!;
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
        '/signup',
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
        '/verify-signup',
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
        '/finalize_signup',
        data: {'email': email, 'password': password},
      );
      final user = UserModel.fromMap(response.data['user']);
      final tokens = TokensModel.fromMap(response.data['tokens']);
      return right((user, tokens));
    } on DioException catch (e) {
      return left(
        AppFailure(message: e.response?.data['error'] ?? 'Login failed'),
      );
    } catch (e) {
      return left(AppFailure(message: e.toString()));
    }
  }

  Future<Either<AppFailure, UserModel>> updateUsername({
    required String Username,
    required String accessToken,
  }) async {
    try {
      final response = await _dio.post(
        '/update_username',
        data: {'username': Username},
        options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
      );

      final updatedUser = UserModel.fromMap(response.data['user']);
      return right(updatedUser);
    } on DioException catch (e) {
      final errorMsg = e.response?.data['error'] ?? 'Failed to update username';
      return left(AppFailure(message: errorMsg));
    } catch (e) {
      return left(AppFailure(message: e.toString()));
    }
  }

  Future<void> loginWithGoogle() async {
    final authUrl = Uri.parse("${API_URL}/authorize/google");
    if (await canLaunchUrl(authUrl)) {
      await launchUrl(authUrl, mode: LaunchMode.externalApplication);
    } else {
      throw Exception("Could not launch $authUrl");
    }
  }

  Future<void> loginWithGithub() async {
    final authUrl = Uri.parse("${API_URL}/authorize/github");
    if (await canLaunchUrl(authUrl)) {
      await launchUrl(authUrl, mode: LaunchMode.externalApplication);
    } else {
      throw Exception("Could not launch $authUrl");
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
        '/login',
        data: {'email': email, 'password': password},
      );
      final user = UserModel.fromMap(response.data['User']);
      final tokensMap = {
        'access_token': response.data['Token'],
        'refresh_token': response.data['Refresh_token'],
      };
      final tokens = TokensModel.fromMap(tokensMap);

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
      final response = await _dio.post('/check-email', data: {'email': email});
      return right(response.data['exists'] ?? false);
    } on DioException catch (e) {
      return left(
        AppFailure(message: e.response?.data['error'] ?? 'Email check failed'),
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
        '/refresh',
        options: Options(headers: {'Authorization': 'Bearer $refreshToken'}),
      );

      final newAccessToken = response.data['NewAcesstoken'] as String?;

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
        accessTokenExpiry: DateTime.now().add(const Duration(minutes: 15)),
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
