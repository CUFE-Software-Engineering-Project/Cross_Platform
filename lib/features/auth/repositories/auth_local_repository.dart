import 'package:hive_ce/hive.dart';
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

  Future<void> saveTokens(String accessToken, String refreshToken) async {
    await _tokenBox.put('accessToken', accessToken);
    await _tokenBox.put('refreshToken', refreshToken);
  }

  Map<String, String?> getTokens() {
    return {
      'accessToken': _tokenBox.get('accessToken'),
      'refreshToken': _tokenBox.get('refreshToken'),
    };
  }

  Future<void> clearTokens() async {
    await _tokenBox.delete('accessToken');
    await _tokenBox.delete('refreshToken');
  }
}
