// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';
import 'package:collection/collection.dart';
import 'package:hive_ce/hive.dart';
import 'package:lite_x/features/chat/models/mediamodel.dart';

part "messagemodel.g.dart";

@HiveType(typeId: 2)
class MessageModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String chatId;

  @HiveField(2)
  String senderId;

  @HiveField(3)
  String? content; // nullable if only media

  @HiveField(4)
  List<MediaModel>? media;

  @HiveField(5)
  DateTime createdAt;

  @HiveField(6)
  String status; // "PENDING","SENT","READ","DELIVERED"

  @HiveField(7)
  String messageType; // "text","image","video","gif","voice","file"

  MessageModel({
    required this.id,
    required this.chatId,
    required this.senderId,
    this.content,
    this.media,
    required this.createdAt,
    this.status = 'PENDING',
    this.messageType = 'text',
  });

  MessageModel copyWith({
    String? id,
    String? chatId,
    String? senderId,
    String? content,
    List<MediaModel>? media,
    DateTime? createdAt,
    String? status,
    String? messageType,
  }) {
    return MessageModel(
      id: id ?? this.id,
      chatId: chatId ?? this.chatId,
      senderId: senderId ?? this.senderId,
      content: content ?? this.content,
      media: media ?? this.media,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
      messageType: messageType ?? this.messageType,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'chatId': chatId,
      'senderId': senderId,
      'content': content,
      'media': media?.map((x) => x.toMap()).toList(),
      'createdAt': createdAt.millisecondsSinceEpoch,
      'status': status,
      'messageType': messageType,
    };
  }

  factory MessageModel.fromMap(Map<String, dynamic> map) {
    return MessageModel(
      id: map['id'] as String,
      chatId: map['chatId'] as String,
      senderId: map['senderId'] as String,
      content: map['content'] != null ? map['content'] as String : null,
      media: map['media'] != null
          ? List<MediaModel>.from(
              (map['media'] as List).map(
                (x) => MediaModel.fromMap(x as Map<String, dynamic>),
              ),
            )
          : null,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int),
      status: map['status'] as String,
      messageType: map['messageType'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory MessageModel.fromJson(String source) =>
      MessageModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'MessageModel(id: $id, chatId: $chatId, senderId: $senderId, content: $content, media: $media, createdAt: $createdAt, status: $status, messageType: $messageType)';
  }

  @override
  bool operator ==(covariant MessageModel other) {
    if (identical(this, other)) return true;
    final listEquals = const DeepCollectionEquality().equals;

    return other.id == id &&
        other.chatId == chatId &&
        other.senderId == senderId &&
        other.content == content &&
        listEquals(other.media, media) &&
        other.createdAt == createdAt &&
        other.status == status &&
        other.messageType == messageType;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        chatId.hashCode ^
        senderId.hashCode ^
        content.hashCode ^
        media.hashCode ^
        createdAt.hashCode ^
        status.hashCode ^
        messageType.hashCode;
  }
}
