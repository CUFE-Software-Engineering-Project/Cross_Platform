import 'dart:convert';
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
  String userId;

  @HiveField(3)
  String? content;

  @HiveField(4)
  DateTime createdAt;

  @HiveField(5)
  String status; // "PENDING","SENT","READ"

  @HiveField(6)
  List<MediaModel>? media;
  @HiveField(7)
  String? senderUsername;

  @HiveField(8)
  String? senderName;

  @HiveField(9)
  String? senderProfileMediaKey;

  @HiveField(10)
  String messageType; // text | image | video | gif | file

  MessageModel({
    required this.id,
    required this.chatId,
    required this.userId,
    this.content,
    required this.createdAt,
    this.status = 'PENDING',
    this.media,
    this.senderUsername,
    this.senderName,
    this.senderProfileMediaKey,
    required this.messageType,
  });

  Map<String, dynamic> toApiRequest({List<String>? recipientIds}) {
    return {
      "chatId": chatId,
      "data": {
        "content": content,
        "messageMedia": media?.map((m) => {"mediaId": m.id}).toList(),
      },
      if (recipientIds != null) "recipientId": recipientIds,
    };
  }

  factory MessageModel.fromApiResponse(Map<String, dynamic> json) {
    List<MediaModel>? mediaList;

    final messageMedia = json['messageMedia'] as List<dynamic>?;

    if (messageMedia != null && messageMedia.isNotEmpty) {
      mediaList = messageMedia.map((message_media) {
        final mediaJson = message_media['media'];
        final mediaId = message_media['mediaId']; //used for download

        return MediaModel.fromApiResponse(mediaJson, mediaMessageId: mediaId);
      }).toList();
    }
    final user = json['user'] as Map<String, dynamic>?;
    String detectedType = 'text';
    if (mediaList != null && mediaList.isNotEmpty) {
      switch (mediaList.first.type.toUpperCase()) {
        case 'IMAGE':
          detectedType = 'image';
          break;
        case 'VIDEO':
          detectedType = 'video';
          break;
        case 'GIF':
          detectedType = 'gif';
          break;
        case 'FILE':
          detectedType = 'file';
          break;
      }
    }
    return MessageModel(
      id: json['id'] as String,
      chatId: json['chatId'] as String,
      userId: json['userId'] as String,
      content: json['content'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      status: json['status'] as String? ?? 'PENDING',
      media: mediaList,
      senderUsername: user?['username'] as String?,
      senderName: user?['name'] as String?,
      senderProfileMediaKey: user?['profileMediaId'] as String?,
      messageType: detectedType,
    );
  }

  MessageModel copyWith({
    String? id,
    String? chatId,
    String? userId,
    String? content,
    DateTime? createdAt,
    String? status,
    List<MediaModel>? media,
    String? senderUsername,
    String? senderName,
    String? senderProfileMediaKey,
    String? messageType,
    String? localId,
  }) {
    return MessageModel(
      id: id ?? this.id,
      chatId: chatId ?? this.chatId,
      userId: userId ?? this.userId,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
      media: media ?? this.media,
      senderUsername: senderUsername ?? this.senderUsername,
      senderName: senderName ?? this.senderName,
      senderProfileMediaKey:
          senderProfileMediaKey ?? this.senderProfileMediaKey,
      messageType: messageType ?? this.messageType,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'chatId': chatId,
      'userId': userId,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
      'status': status,
      'media': media?.map((x) => x.toMap()).toList(),
      'senderUsername': senderUsername,
      'senderName': senderName,
      'senderProfileMediaKey': senderProfileMediaKey,
      'messageType': messageType,
    };
  }

  factory MessageModel.fromMap(Map<String, dynamic> map) {
    return MessageModel(
      id: map['id'] as String,
      chatId: map['chatId'] as String,
      userId: map['userId'] as String,
      content: map['content'] as String?,
      createdAt: DateTime.parse(map['createdAt'] as String),
      status: map['status'] as String? ?? 'PENDING',
      media: map['media'] != null
          ? List<MediaModel>.from(
              (map['media'] as List).map(
                (x) => MediaModel.fromMap(x as Map<String, dynamic>),
              ),
            )
          : null,
      senderUsername: map['senderUsername'] as String?,
      senderName: map['senderName'] as String?,
      senderProfileMediaKey: map['senderProfileMediaKey'] as String?,
      messageType: map['messageType'] ?? 'text',
    );
  }

  String toJson() => json.encode(toMap());

  factory MessageModel.fromJson(String source) =>
      MessageModel.fromMap(json.decode(source) as Map<String, dynamic>);

  bool get hasMedia => media != null && media!.isNotEmpty;
  bool get isTextOnly => !hasMedia && content != null;
  bool get isPending => status == 'PENDING';
  bool get isSent =>
      status == 'SENT' || status == 'DELIVERED' || status == 'READ';
  bool get isRead => status == 'READ';

  @override
  String toString() {
    return 'MessageModel(id: $id, chatId: $chatId, userId: $userId, content: ${content?.substring(0, content!.length > 20 ? 20 : content!.length)}, status: $status)';
  }

  @override
  bool operator ==(covariant MessageModel other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.chatId == chatId &&
        other.userId == userId &&
        other.createdAt == createdAt &&
        other.status == status;
  }

  @override
  int get hashCode {
    return id.hashCode ^ chatId.hashCode ^ userId.hashCode ^ createdAt.hashCode;
  }
}
