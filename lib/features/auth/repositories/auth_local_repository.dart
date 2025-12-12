import 'dart:async';

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
  //--------------------------------------------------------------//
  final _tokenStreamController = StreamController<TokensModel?>.broadcast();
  Stream<TokensModel?> get tokenStream => _tokenStreamController.stream;
  //-----------------------------------------------------------------------//
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
    await _tokenBox.putAll({
      'accessToken': tokens.accessToken,
      'refreshToken': tokens.refreshToken,
      'accessTokenExpiry': tokens.accessTokenExpiry.toIso8601String(),
      'refreshTokenExpiry': tokens.refreshTokenExpiry.toIso8601String(),
    });
    _tokenStreamController.add(tokens);
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
    await _tokenBox.deleteAll([
      'accessToken',
      'refreshToken',
      'accessTokenExpiry',
      'refreshTokenExpiry',
    ]);
    _tokenStreamController.add(null);
  }

  void dispose() {
    _tokenStreamController.close();
  }
}
