import 'dart:convert';

import 'package:hive_ce/hive.dart';

part 'usermodel.g.dart';

@HiveType(typeId: 0)
class UserModel {
  @HiveField(0)
  final String name;

  @HiveField(1)
  final String email;

  @HiveField(2)
  final String dob;

  @HiveField(3)
  final String username;

  @HiveField(4)
  final String? photo;

  @HiveField(5)
  final String? bio;

  @HiveField(6)
  final String id;

  @HiveField(7)
  final bool isEmailVerified;

  @HiveField(8)
  final bool isVerified;

  @HiveField(9)
  final bool loginCodesSet;

  @HiveField(10)
  final bool? tfaVerified; // Two-factor authentication status

  @HiveField(11)
  final int? tokenVersion; // For managing token invalidation

  @HiveField(12)
  final String? accessToken; // Store current access token

  @HiveField(13)
  final String? refreshToken; // Store refresh token

  UserModel({
    required this.name,
    required this.email,
    required this.dob,
    required this.username,
    this.photo,
    this.bio,
    required this.id,
    required this.isEmailVerified,
    required this.isVerified,
    required this.loginCodesSet,
    this.tfaVerified,
    this.tokenVersion,
    this.accessToken,
    this.refreshToken,
  });

  UserModel copyWith({
    String? name,
    String? email,
    String? dob,
    String? username,
    String? photo,
    String? bio,
    String? id,
    bool? isEmailVerified,
    bool? isVerified,
    bool? loginCodesSet,
    bool? tfaVerified,
    int? tokenVersion,
    String? accessToken,
    String? refreshToken,
  }) {
    return UserModel(
      name: name ?? this.name,
      email: email ?? this.email,
      dob: dob ?? this.dob,
      username: username ?? this.username,
      photo: photo ?? this.photo,
      bio: bio ?? this.bio,
      id: id ?? this.id,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      isVerified: isVerified ?? this.isVerified,
      loginCodesSet: loginCodesSet ?? this.loginCodesSet,
      tfaVerified: tfaVerified ?? this.tfaVerified,
      tokenVersion: tokenVersion ?? this.tokenVersion,
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'name': name,
      'email': email,
      'dob': dob,
      'username': username,
      'photo': photo,
      'bio': bio,
      'id': id,
      'isEmailVerified': isEmailVerified,
      'isVerified': isVerified,
      'loginCodesSet': loginCodesSet,
      'tfaVerifed': tfaVerified, //backend uses 'tfaVerifed'
      'tokenVersion': tokenVersion,
      'accessToken': accessToken,
      'refreshToken': refreshToken,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      name: map['name'] as String,
      email: map['email'] as String,
      dob: map['dateOfBirth'] != null
          ? map['dateOfBirth'] as String
          : map['dob'] as String? ?? '',
      username: map['username'] as String,
      photo: map['photo'] != null ? map['photo'] as String : null,
      bio: map['bio'] != null ? map['bio'] as String : null,
      id: map['id'] as String,
      isEmailVerified: map['isEmailVerified'] as bool? ?? false,
      isVerified: map['isVerified'] as bool? ?? false,
      loginCodesSet: map['loginCodesSet'] as bool? ?? false,
      tfaVerified:
          map['tfaVerifed'] as bool?, // Note: backend uses 'tfaVerifed'
      tokenVersion: map['tokenVersion'] as int?,
      accessToken: map['accessToken'] as String?,
      refreshToken: map['refreshToken'] as String?,
    );
  }

  String toJson() => json.encode(toMap());

  factory UserModel.fromJson(String source) =>
      UserModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'UserModel(name: $name, email: $email, dob: $dob, username: $username, photo: $photo, bio: $bio, id: $id, isEmailVerified: $isEmailVerified, isVerified: $isVerified, loginCodesSet: $loginCodesSet, tfaVerified: $tfaVerified, tokenVersion: $tokenVersion)';
  }

  @override
  bool operator ==(covariant UserModel other) {
    if (identical(this, other)) return true;

    return other.name == name &&
        other.email == email &&
        other.dob == dob &&
        other.username == username &&
        other.photo == photo &&
        other.bio == bio &&
        other.id == id &&
        other.isEmailVerified == isEmailVerified &&
        other.isVerified == isVerified &&
        other.loginCodesSet == loginCodesSet &&
        other.tfaVerified == tfaVerified &&
        other.tokenVersion == tokenVersion &&
        other.accessToken == accessToken &&
        other.refreshToken == refreshToken;
  }

  @override
  int get hashCode {
    return name.hashCode ^
        email.hashCode ^
        dob.hashCode ^
        username.hashCode ^
        photo.hashCode ^
        bio.hashCode ^
        id.hashCode ^
        isEmailVerified.hashCode ^
        isVerified.hashCode ^
        loginCodesSet.hashCode ^
        tfaVerified.hashCode ^
        tokenVersion.hashCode ^
        accessToken.hashCode ^
        refreshToken.hashCode;
  }
}
