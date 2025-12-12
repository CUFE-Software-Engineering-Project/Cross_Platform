import 'dart:convert';

import 'package:flutter/foundation.dart';
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
  final String? photo; // media Id

  @HiveField(5)
  final String? bio;

  @HiveField(6)
  final String id;

  @HiveField(7)
  final bool isEmailVerified;

  @HiveField(8)
  final bool isVerified;

  @HiveField(9)
  final bool? tfaVerified;

  @HiveField(10)
  final Set<String> interests;
  @HiveField(11)
  final String? localProfilePhotoPath; // path of local profile photo

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

    this.tfaVerified,
    this.interests = const {},
    this.localProfilePhotoPath,
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
    Set<String>? interests,
    String? localProfilePhotoPath,
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
      tfaVerified: tfaVerified ?? this.tfaVerified,
      interests: interests ?? this.interests,
      localProfilePhotoPath:
          localProfilePhotoPath ?? this.localProfilePhotoPath,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'name': name,
      'email': email,
      'dateOfBirth': dob,
      'username': username,
      'photo': photo,
      'bio': bio,
      'id': id,
      'isEmailVerified': isEmailVerified,
      'isVerified': isVerified,

      'tfaVerifed': tfaVerified, //backend uses 'tfaVerifed'
      'interests': interests.toList(),
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    Set<String> parsedInterests = {};
    if (map['interests'] != null) {
      if (map['interests'] is List) {
        parsedInterests = (map['interests'] as List)
            .map((e) => e.toString())
            .toSet();
      } else if (map['interests'] is Set) {
        parsedInterests = (map['interests'] as Set)
            .map((e) => e.toString())
            .toSet();
      }
    }

    return UserModel(
      name: map['name'] as String,
      email: map['email'] as String,
      dob: map['dateOfBirth'] != null
          ? map['dateOfBirth'] as String
          : map['dob'] as String? ?? '',
      username: map['username'] as String,
      photo: map['photo'] as String?,
      bio: map['bio'] as String?,
      id: map['id'].toString(),
      isEmailVerified: map['isEmailVerified'] as bool? ?? false,
      isVerified: map['isVerified'] as bool? ?? false,
      tfaVerified: map['tfaVerifed'] as bool?,
      interests: parsedInterests,
    );
  }

  String toJson() => json.encode(toMap());

  factory UserModel.fromJson(String source) =>
      UserModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'UserModel(name: $name, email: $email, dob: $dob, username: $username, photo: $photo, bio: $bio, id: $id, isEmailVerified: $isEmailVerified, isVerified: $isVerified,  tfaVerified: $tfaVerified, interests: $interests)';
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
        other.tfaVerified == tfaVerified &&
        setEquals(other.interests, interests);
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
        tfaVerified.hashCode ^
        interests.hashCode;
  }
}
