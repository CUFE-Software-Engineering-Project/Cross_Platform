import 'package:hive_ce/hive.dart';
import 'package:lite_x/core/models/TokensModel.dart';
import 'package:lite_x/core/models/usermodel.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_local_repository.g.dart';

@Riverpod(keepAlive: true)
AuthLocalRepository authLocalRepository(Ref ref) {
  final userBox = Hive.box<UserModel>('userBox');
  final tokenBox = Hive.box('tokenBox');
  return AuthLocalRepository(userBox: userBox, tokenBox: tokenBox);
}

class AuthLocalRepository {
  final Box<UserModel> _userBox;
  final Box _tokenBox;

  AuthLocalRepository({required Box<UserModel> userBox, required Box tokenBox})
    : _userBox = userBox,
      _tokenBox = tokenBox;

  Future<void> saveUser(UserModel user) async {
    await _userBox.put('currentUser', user);
  }

  UserModel? getUser() {
    return _userBox.get('currentUser');
  }

  Future<void> clearUser() async {
    await _userBox.delete('currentUser');
  }

  Future<void> saveTokens(TokensModel tokens) async {
    await _tokenBox.put('accessToken', tokens.accessToken);
    await _tokenBox.put('refreshToken', tokens.refreshToken);
    await _tokenBox.put(
      'accessTokenExpiry',
      tokens.accessTokenExpiry.toIso8601String(),
    );
    await _tokenBox.put(
      'refreshTokenExpiry',
      tokens.refreshTokenExpiry.toIso8601String(),
    );
  }

  TokensModel? getTokens() {
    final accessToken = _tokenBox.get('accessToken') as String?;
    final refreshToken = _tokenBox.get('refreshToken') as String?;
    final accessTokenExpiryStr = _tokenBox.get('accessTokenExpiry') as String?;
    final refreshTokenExpiryStr =
        _tokenBox.get('refreshTokenExpiry') as String?;

    if (accessToken == null ||
        refreshToken == null ||
        accessTokenExpiryStr == null ||
        refreshTokenExpiryStr == null) {
      return null;
    }

    try {
      return TokensModel(
        accessToken: accessToken,
        refreshToken: refreshToken,
        accessTokenExpiry: DateTime.parse(accessTokenExpiryStr),
        refreshTokenExpiry: DateTime.parse(refreshTokenExpiryStr),
      );
    } catch (e) {
      return null;
    }
  }

  Future<void> clearTokens() async {
    await _tokenBox.delete('accessToken');
    await _tokenBox.delete('refreshToken');
    await _tokenBox.delete('accessTokenExpiry');
    await _tokenBox.delete('refreshTokenExpiry');
  }
}
