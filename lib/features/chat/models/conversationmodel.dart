// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:hive_ce/hive.dart';

import 'package:lite_x/core/models/usermodel.dart';

part 'conversationmodel.g.dart';

@HiveType(typeId: 1)
class ConversationModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  bool isGroup;

  @HiveField(2)
  String? name; // group name or null for DM

  @HiveField(3)
  String? photo;

  @HiveField(4)
  List<UserModel> participants;

  @HiveField(5)
  String? lastMessageId;

  @HiveField(6)
  int unseenCount;

  @HiveField(7)
  DateTime updatedAt;

  ConversationModel({
    required this.id,
    required this.isGroup,
    this.name,
    this.photo,
    required this.participants,
    this.lastMessageId,
    this.unseenCount = 0,
    required this.updatedAt,
  });

  ConversationModel copyWith({
    String? id,
    bool? isGroup,
    String? name,
    String? photo,
    List<UserModel>? participants,
    String? lastMessageId,
    int? unseenCount,
    DateTime? updatedAt,
  }) {
    return ConversationModel(
      id: id ?? this.id,
      isGroup: isGroup ?? this.isGroup,
      name: name ?? this.name,
      photo: photo ?? this.photo,
      participants: participants ?? this.participants,
      lastMessageId: lastMessageId ?? this.lastMessageId,
      unseenCount: unseenCount ?? this.unseenCount,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'isGroup': isGroup,
      'name': name,
      'photo': photo,
      'participants': participants.map((x) => x.toMap()).toList(),
      'lastMessageId': lastMessageId,
      'unseenCount': unseenCount,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
    };
  }

  factory ConversationModel.fromMap(Map<String, dynamic> map) {
    return ConversationModel(
      id: map['id'] as String,
      isGroup: map['isGroup'] as bool,
      name: map['name'] != null ? map['name'] as String : null,
      photo: map['photo'] != null ? map['photo'] as String : null,
      // FIX: Changed 'as List<int>' to 'as List<dynamic>'
      participants: List<UserModel>.from(
        (map['participants'] as List<dynamic>).map<UserModel>(
          (x) => UserModel.fromMap(x as Map<String, dynamic>),
        ),
      ),
      lastMessageId: map['lastMessageId'] != null
          ? map['lastMessageId'] as String
          : null,
      unseenCount: map['unseenCount'] as int,
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updatedAt'] as int),
    );
  }

  String toJson() => json.encode(toMap());

  factory ConversationModel.fromJson(String source) =>
      ConversationModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'ConversationModel(id: $id, isGroup: $isGroup, name: $name, photo: $photo, participants: $participants, lastMessageId: $lastMessageId, unseenCount: $unseenCount, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(covariant ConversationModel other) {
    if (identical(this, other)) return true;
    final listEquals = const DeepCollectionEquality().equals;

    return other.id == id &&
        other.isGroup == isGroup &&
        other.name == name &&
        other.photo == photo &&
        listEquals(other.participants, participants) &&
        other.lastMessageId == lastMessageId &&
        other.unseenCount == unseenCount &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        isGroup.hashCode ^
        name.hashCode ^
        photo.hashCode ^
        participants.hashCode ^
        lastMessageId.hashCode ^
        unseenCount.hashCode ^
        updatedAt.hashCode;
  }
}
