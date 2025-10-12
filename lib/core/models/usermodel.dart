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
  @HiveField(5)
  final String? bio;
  @HiveField(6)
  final String id;
  UserModel({
    required this.name,
    required this.email,
    required this.dob,
    required this.username,
    this.photo,
    this.bio,
    required this.id,
  });

  UserModel copyWith({
    String? name,
    String? email,
    String? dob,
    String? username,
    String? photo,
    String? bio,
    String? id,
  }) {
    return UserModel(
      name: name ?? this.name,
      email: email ?? this.email,
      dob: dob ?? this.dob,
      username: username ?? this.username,
      photo: photo ?? this.photo,
      bio: bio ?? this.bio,
      id: id ?? this.id,
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
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      name: map['name'] as String,
      email: map['email'] as String,
      dob: map['dob'] as String,
      username: map['username'] as String,
      photo: map['photo'] != null ? map['photo'] as String : null,
      bio: map['bio'] != null ? map['bio'] as String : null,
      id: map['id'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory UserModel.fromJson(String source) =>
      UserModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'UserModel(name: $name, email: $email, dob: $dob, username: $username, photo: $photo, bio: $bio, id: $id)';
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
        other.id == id;
  }

  @override
  int get hashCode {
    return name.hashCode ^
        email.hashCode ^
        dob.hashCode ^
        username.hashCode ^
        photo.hashCode ^
        bio.hashCode ^
        id.hashCode;
  }
}
