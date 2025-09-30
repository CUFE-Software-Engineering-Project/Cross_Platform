// ignore_for_file: public_member_api_docs, sort_constructors_first
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
  UserModel({
    required this.name,
    required this.email,
    required this.dob,
    required this.username,
    this.photo,
  });

  UserModel copyWith({
    String? name,
    String? email,
    String? dob,
    String? username,
    String? photo,
  }) {
    return UserModel(
      name: name ?? this.name,
      email: email ?? this.email,
      dob: dob ?? this.dob,
      username: username ?? this.username,
      photo: photo ?? this.photo,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'name': name,
      'email': email,
      'dob': dob,
      'username': username,
      'photo': photo,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      name: map['name'] ?? "",
      email: map['email'] ?? "",
      dob: map['dob'] ?? "",
      username: map['username'] ?? "",
      photo: map['photo'] != null ? map['photo'] as String : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory UserModel.fromJson(String source) =>
      UserModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'UserModel(name: $name, email: $email, dob: $dob, username: $username, photo: $photo)';
  }

  @override
  bool operator ==(covariant UserModel other) {
    if (identical(this, other)) return true;

    return other.name == name &&
        other.email == email &&
        other.dob == dob &&
        other.username == username &&
        other.photo == photo;
  }

  @override
  int get hashCode {
    return name.hashCode ^
        email.hashCode ^
        dob.hashCode ^
        username.hashCode ^
        photo.hashCode;
  }
}
