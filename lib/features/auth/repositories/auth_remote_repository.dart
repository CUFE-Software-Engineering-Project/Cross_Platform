import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:fpdart/fpdart.dart';
import 'package:google_sign_in/google_sign_in.dart' as signIn;
import 'package:http/http.dart' as http;
import 'package:lite_x/core/classes/AppFailure.dart';
import 'package:lite_x/core/classes/PickedImage.dart';
import 'package:lite_x/core/models/TokensModel.dart';
import 'package:lite_x/core/models/usermodel.dart';
import 'package:lite_x/core/providers/dio_interceptor.dart';
import 'package:lite_x/core/services/deep_link_service.dart';
import 'package:lite_x/features/auth/models/ExploreCategory.dart';
import 'package:path_provider/path_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:dio/dio.dart';
import 'package:url_launcher/url_launcher.dart';
part 'auth_remote_repository.g.dart';

@Riverpod(keepAlive: true)
AuthRemoteRepository authRemoteRepository(Ref ref) {
  final dio = ref.watch(dioProvider);
  return AuthRemoteRepository(dio: dio);
}

class AuthRemoteRepository {
  final Dio _dio;
  AuthRemoteRepository({required Dio dio}) : _dio = dio;
  //---------------------------------------------------github------------------------------------------------------//

  Future<Either<AppFailure, (UserModel, TokensModel)>> loginWithGithub() async {
    try {
      final baseUrl = dotenv.env["API_URL"]!;
      final authUrl = "${baseUrl}oauth2/authorize/github";
      final opened = await launchUrl(
        Uri.parse(authUrl),
        mode: LaunchMode.externalApplication,
      );

      if (!opened) {
        return left(AppFailure(message: "Could not open browser"));
      }
      final uri = await DeepLinkService.waitForLink();

      if (uri == null) {
        return left(AppFailure(message: "Login cancelled by user"));
      }

      final token = uri.queryParameters["token"];
      final refresh = uri.queryParameters["refresh-token"];
      final userRaw = uri.queryParameters["user"];

      if (token == null || refresh == null || userRaw == null) {
        return left(AppFailure(message: "OAuth error: missing parameters"));
      }

      final decodedUser = Uri.decodeComponent(userRaw);

      final user = UserModel.fromJson(decodedUser);

      final tokens = TokensModel(
        accessToken: token,
        refreshToken: refresh,
        accessTokenExpiry: DateTime.now().add(const Duration(hours: 1)),
        refreshTokenExpiry: DateTime.now().add(const Duration(days: 30)),
      );

      return right((user, tokens));
    } catch (e) {
      return left(AppFailure(message: e.toString()));
    }
  }

  //--------------------------------------------------------google-------------------------------------------------------------------//

  final _googleSignIn = signIn.GoogleSignIn(
    serverClientId:
        "1096363232606-2fducjadk56bt4nsreqkj2jna7oiomga.apps.googleusercontent.com",
    scopes: ['email', 'https://www.googleapis.com/auth/userinfo.profile'],
  );

  Future<Either<AppFailure, (UserModel, TokensModel)>>
  signInWithGoogleAndroid() async {
    try {
      final String apiUrl = dotenv.env["API_URL"]!;

      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return left(AppFailure(message: "Google login canceled"));
      }

      final googleAuth = await googleUser.authentication;
      final idToken = googleAuth.idToken;

      debugPrint("GOOGLE ID TOKEN = $idToken");

      final resp = await http.post(
        Uri.parse("${apiUrl}oauth2/callback/android_google"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"idToken": idToken}),
      );

      if (resp.statusCode != 200) {
        return left(AppFailure(message: resp.body));
      }

      final data = jsonDecode(resp.body);

      final user = UserModel.fromMap(data["user"]);
      final tokens = TokensModel(
        accessToken: data["token"],
        refreshToken: data["refreshToken"],
        accessTokenExpiry: DateTime.now().add(const Duration(hours: 1)),
        refreshTokenExpiry: DateTime.now().add(const Duration(days: 30)),
      );

      return right((user, tokens));
    } catch (e) {
      return left(AppFailure(message: e.toString()));
    }
  }

  //--------------------------------------------------get categories------------------------------------------------------------//
  Future<Either<AppFailure, List<ExploreCategory>>> getCategories() async {
    try {
      final response = await _dio.get("api/explore/categories");

      final List data = response.data['data'];
      final categories = data.map((e) => ExploreCategory.fromMap(e)).toList();

      return right(categories);
    } catch (e) {
      return left(AppFailure(message: "Failed to load categories"));
    }
  }

  Future<Either<AppFailure, String>> saveUserInterests(
    Set<String> categories,
  ) async {
    try {
      final response = await _dio.post(
        "api/explore/preferred-categories",
        data: {"categories": categories.toList()},
      );

      return right(response.data['message'] ?? "Interests saved");
    } catch (e) {
      return left(AppFailure(message: "Failed to save interests"));
    }
  }

  //--------------------------------------------SignUp---------------------------------------------------------//
  // Register new user
  Future<Either<AppFailure, String>> create({
    required String name,
    required String email,
    required String dateOfBirth,
  }) async {
    try {
      final response = await _dio.post(
        'api/auth/signup',
        data: {'name': name, 'email': email, 'dateOfBirth': dateOfBirth},
      );
      return right(response.data['message'] ?? 'Verification email sent');
    } on DioException {
      return left(AppFailure(message: 'Signup failed'));
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
        'api/auth/verify-signup',
        data: {'email': email, 'code': code},
      );

      final message = response.data['message'] ?? 'Verified successfully';
      return right(message);
    } on DioException {
      return left(AppFailure(message: 'Email verification failed'));
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
        'api/auth/finalize_signup',
        data: {'email': email, 'password': password},
      );
      print("asermohamed${response.data['tokens']}");
      final user = UserModel.fromMap(response.data['user']);
      final tokens = TokensModel.fromMap(response.data['tokens']);

      return right((user, tokens));
    } on DioException {
      return left(AppFailure(message: 'Signup failed'));
    } catch (e) {
      return left(AppFailure(message: e.toString()));
    }
  }

  //-------------------------------------------------------------------media of photo-----------------------------------------------------------------------------------//
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

  Future<Either<AppFailure, Map<String, dynamic>>> uploadProfilePhoto({
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
        'api/media/upload-request',
        data: {'fileName': fileName, 'contentType': fileType},
      );

      final String presignedUrl = requestResponse.data['url'];
      final String keyName = requestResponse.data['keyName'];
      final fileBytes = await file.readAsBytes();

      final newDio = Dio(
        BaseOptions(
          headers: {
            'Content-Type': fileType,
            'Content-Length': fileBytes.length,
          },
        ),
      );

      await newDio.put(presignedUrl, data: Stream.fromIterable([fileBytes]));

      final confirmResponse = await _dio.post(
        'api/media/confirm-upload/$keyName',
      );

      final mediaId = confirmResponse.data['newMedia']['id'].toString();

      final newMediaKey = confirmResponse.data['newMedia']['keyName'] as String;
      print("MEDIA ID AFTER UPLOAD: $mediaId");

      return right({'mediaId': mediaId, 'keyName': newMediaKey});
    } on DioException {
      return left(AppFailure(message: 'Upload failed'));
    } catch (e) {
      return left(AppFailure(message: e.toString()));
    }
  }

  //------------------------------------------------------------------download the media------------------------------------------------------------------------------//
  Future<Either<AppFailure, File>> downloadMedia({
    required String mediaId,
  }) async {
    try {
      final response = await _dio.get('api/media/download-request/$mediaId');
      final String downloadUrl = response.data['url'];

      final newDio = Dio();
      final imageResponse = await newDio.get(
        downloadUrl,
        options: Options(responseType: ResponseType.bytes),
      );

      final directory = await getTemporaryDirectory();
      final filePath =
          '${directory.path}/downloaded_${DateTime.now().millisecondsSinceEpoch}.jpg';

      final file = File(filePath);
      await file.writeAsBytes(imageResponse.data);

      return right(file);
    } catch (e) {
      return left(AppFailure(message: 'Download failed $e'));
    }
  }

  //-----------------------------------------------------------------------updateprofilephoto----------------------------------------------------------------------------------//
  Future<Either<AppFailure, void>> updateProfilePhoto(
    String userId,
    String mediaId,
  ) async {
    try {
      await _dio.patch("api/users/profile-picture/$userId/$mediaId");
      return const Right(());
    } catch (e) {
      return Left(AppFailure(message: "couldn't update profile picture"));
    }
  }

  //-------------------------------------------------------------------------------------------------------------------------------------------------------//
  Future<Either<AppFailure, (UserModel, TokensModel)>> updateUsername({
    required UserModel currentUser,
    required String Username,
  }) async {
    try {
      final response = await _dio.put(
        'api/auth/update_username',
        data: {'username': Username},
      );
      final newUsername = response.data['user']['username'] as String;
      final updatedUser = currentUser.copyWith(username: newUsername);
      final newtokens = TokensModel.fromMap_update(response.data['tokens']);
      return right((updatedUser, newtokens));
    } on DioException {
      return left(AppFailure(message: 'Failed to update username'));
    } catch (e) {
      return left(AppFailure(message: e.toString()));
    }
  }

  //---------------------------------------------------------setbirthdate-------------------------------------------------------------------------//
  Future<Either<AppFailure, String>> setbirthdate({
    required String day,
    required String month,
    required String year,
  }) async {
    try {
      final response = await _dio.post(
        'api/auth/set-birthdate',
        data: {'day': day, 'month': month, 'year': year},
      );
      final message = response.data['message'] as String;
      return right(message);
    } on DioException {
      return left(AppFailure(message: 'Failed to set birthdate'));
    } catch (e) {
      return left(AppFailure(message: e.toString()));
    }
  }

  //-------------------------------------------------FCM Token Registration-----------------------------------------------------------------------------------------//
  Future<Either<AppFailure, String>> registerFcmToken({
    required String fcmToken,
  }) async {
    try {
      final String osType = kIsWeb
          ? 'WEB'
          : (Platform.isAndroid ? 'ANDROID' : 'IOS');

      final data = {'token': fcmToken, 'osType': osType};

      final response = await _dio.post('api/users/fcm-token', data: data);

      final message = response.data['message'] ?? 'FCM registered successfully';
      return right(message);
    } on DioException catch (e) {
      if (e.response != null) {
        final resp = e.response!;
        final serverMessage = resp.data != null && resp.data is Map
            ? (resp.data['message'] ??
                  resp.data['errors'] ??
                  resp.data.toString())
            : resp.statusMessage;
        return left(
          AppFailure(message: 'FCM registration failed: $serverMessage'),
        );
      }
      return left(AppFailure(message: 'FCM registration failed'));
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
        'api/auth/login',
        data: {'email': email, 'password': password},
      );

      final user = UserModel.fromMap(response.data['user']);
      final tokens = TokensModel.fromMap_login(response.data);
      print("asermohamed${user.id}");
      print("asermohamed${tokens.accessToken}");
      return right((user, tokens));
    } on DioException {
      return left(AppFailure(message: 'Login failed'));
    } catch (e) {
      return left(AppFailure(message: "Wrong Password"));
    }
  }

  //-----------------------------------------------check email-------------------------------------------------------------------------------------//
  Future<Either<AppFailure, bool>> check_email({required String email}) async {
    try {
      final response = await _dio.post(
        'api/auth/getUser',
        data: {'email': email},
      );
      print("asermohamed${response.data['exists']}");
      return right(response.data['exists'] ?? false);
    } on DioException {
      return left(AppFailure(message: 'Email check failed'));
    } catch (e) {
      return left(AppFailure(message: e.toString()));
    }
  }

  //--------------------------------------suggest usernames--------------------------------------//
  Future<Either<AppFailure, List<String>>> suggest_usernames({
    required String username,
  }) async {
    try {
      final response = await _dio.post(
        'api/auth/suggest-usernames',
        data: {'name': username},
      );
      final suggestions = List<String>.from(response.data['suggestions'] ?? []);
      return right(suggestions);
    } on DioException {
      return left(AppFailure(message: 'Username suggestions failed'));
    } catch (e) {
      return left(AppFailure(message: e.toString()));
    }
  }

  //--------------------------------------forgetpassword---------------------------------------------------------------//
  Future<Either<AppFailure, String>> forget_password({
    required String email,
  }) async {
    try {
      final response = await _dio.post(
        'api/auth/forget-password',
        data: {'email': email},
      );
      final message = response.data['message'] ?? 'Reset code sent';
      return right(message);
    } on DioException {
      return left(AppFailure(message: 'Forget password failed'));
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
        'api/auth/verify-reset-code',
        data: {'email': email, 'code': code},
      );
      final message = response.data['message'] ?? 'Reset code verified';
      return right(message);
    } on DioException {
      return left(AppFailure(message: 'Verify reset code failed'));
    } catch (e) {
      return left(AppFailure(message: e.toString()));
    }
  }

  Future<Either<AppFailure, (UserModel, TokensModel)>> reset_password({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        'api/auth/reset-password',
        data: {'email': email, 'password': password},
      );
      final user = UserModel.fromMap(response.data['user']);
      final tokens = TokensModel.fromMap_reset_password(response.data);
      return right((user, tokens));
    } on DioException {
      return left(AppFailure(message: 'Reset password failed'));
    } catch (e) {
      return left(AppFailure(message: e.toString()));
    }
  }

  //-------------------------------------------------------Update password------------------------------------------------------------------------------------//

  Future<Either<AppFailure, String>> update_password({
    required String password,
    required String newpassword,
    required String confirmPassword,
  }) async {
    try {
      final response = await _dio.post(
        'api/auth/change-password',
        data: {
          'password': password,
          'newpassword': newpassword,
          'confirmPassword': confirmPassword,
        },
      );

      final message =
          response.data['message'] ?? 'Password updated successfully';
      return right(message);
    } on DioException {
      return left(AppFailure(message: 'update password failed'));
    } catch (e) {
      return left(AppFailure(message: e.toString()));
    }
  }

  //----------------------------------------------------------------------updateemail------------------------------------------------------------------------------------------//
  Future<Either<AppFailure, String>> update_email({
    required String newemail,
  }) async {
    try {
      final response = await _dio.post(
        'api/auth/change-email',
        data: {'newemail': newemail},
      );
      final message = response.data['message'] ?? 'Email updated successfully';
      return right(message);
    } on DioException {
      return left(AppFailure(message: 'update email failed'));
    } catch (e) {
      return left(AppFailure(message: e.toString()));
    }
  }

  Future<Either<AppFailure, String>> verify_new_email({
    required String newemail,
    required String code,
  }) async {
    try {
      final response = await _dio.post(
        'api/auth/verify-new-email',
        data: {'email': newemail, 'code': code},
      );

      final message = response.data['message'] ?? 'updated email successfully';
      return right(message);
    } on DioException {
      return left(AppFailure(message: 'Email update failed'));
    } catch (e) {
      return left(AppFailure(message: e.toString()));
    }
  }
}
