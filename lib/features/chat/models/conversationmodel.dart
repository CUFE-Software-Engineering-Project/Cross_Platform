// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';
import 'package:collection/collection.dart';
import 'package:hive_ce/hive.dart';
part 'conversationmodel.g.dart';

@HiveType(typeId: 1)
class ConversationModel extends HiveObject {
  @HiveField(0)
  String id;
  @HiveField(1)
  bool isDMChat;
  @HiveField(2)
  DateTime createdAt;
  @HiveField(3)
  DateTime updatedAt;

  @HiveField(4)
  List<String> participantIds;
  @HiveField(5)
  String? lastMessageContent;
  @HiveField(6)
  DateTime? lastMessageTime;
  @HiveField(7)
  String? lastMessageSenderId;
  @HiveField(8)
  int unseenCount;
  @HiveField(9)
  String? dmPartnerUserId;
  @HiveField(10)
  String? dmPartnerName;
  @HiveField(11)
  String? dmPartnerUsername;
  @HiveField(12)
  String? dmPartnerProfileKey;
  @HiveField(13)
  String? lastMessageType;

  ConversationModel({
    required this.id,
    required this.isDMChat,
    required this.createdAt,
    required this.updatedAt,
    required this.participantIds,
    this.lastMessageContent,
    this.lastMessageTime,
    this.lastMessageSenderId,
    this.unseenCount = 1, //
    this.dmPartnerUserId,
    this.dmPartnerName,
    this.dmPartnerUsername,
    this.dmPartnerProfileKey,
    this.lastMessageType,
  });

  factory ConversationModel.fromApiResponse(
    Map<String, dynamic> json,
    String currentUserId,
  ) {
    final chatUsers = json['chatUsers'] as List<dynamic>? ?? [];
    final participantIds = chatUsers
        .map((cu) => cu['userId'] as String)
        .toList();
    final messages = json['messages'] as List<dynamic>? ?? [];
    String? lastMessageContent;
    DateTime? lastMessageTime;
    String? lastMessageSenderId;
    String? lastMessageType;

    if (messages.isNotEmpty) {
      final lastMsg = messages.last;

      lastMessageType = 'text';
      lastMessageContent = lastMsg['content'] as String?;

      if (lastMessageContent != null && lastMessageContent.length > 80) {
        lastMessageContent = lastMessageContent.substring(0, 80);
      }

      lastMessageTime = DateTime.parse(lastMsg['createdAt'] as String);
      lastMessageSenderId = lastMsg['userId'] as String;
    }

    final unseenCount = json['unseenMessagesCount'] as int? ?? 0;

    final isDm = json['DMChat'] as bool;
    String? dmPartnerUserId;
    String? dmPartnerName;
    String? dmPartnerUsername;
    String? dmPartnerProfileKey;

    if (isDm && participantIds.length > 1) {
      final partner = chatUsers.firstWhereOrNull(
        (cu) => cu['userId'] != currentUserId,
      );

      if (partner != null && partner['user'] != null) {
        final partnerUser = partner['user'];
        dmPartnerUserId = partnerUser['id'] as String?;
        dmPartnerName = partnerUser['name'] as String?;
        dmPartnerUsername = partnerUser['username'] as String?;
        dmPartnerProfileKey = partnerUser['profileMediaId'] as String?;
      }
    }

    return ConversationModel(
      id: json['id'] as String,
      isDMChat: isDm,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      participantIds: participantIds,
      lastMessageContent: lastMessageContent,
      lastMessageTime: lastMessageTime,
      lastMessageSenderId: lastMessageSenderId,
      unseenCount: unseenCount,
      dmPartnerUserId: dmPartnerUserId,
      dmPartnerName: dmPartnerName,
      dmPartnerUsername: dmPartnerUsername,
      dmPartnerProfileKey: dmPartnerProfileKey,
      lastMessageType: lastMessageType,
    );
  }

  bool get isGroup => !isDMChat;

  String getDisplayName() {
    return dmPartnerName ?? dmPartnerUsername ?? "Unknown User";
  }

  String? getDisplayImageKey() {
    return dmPartnerProfileKey;
  }

  String? getOtherParticipantId(String currentUserId) {
    if (!isDMChat) return null;
    return participantIds.firstWhere(
      (id) => id != currentUserId,
      orElse: () => participantIds.first,
    );
  }

  @override
  String toString() {
    return 'ConversationModel(id: $id, isDMChat: $isDMChat, createdAt: $createdAt, updatedAt: $updatedAt, participantIds: $participantIds, lastMessageContent: $lastMessageContent, lastMessageTime: $lastMessageTime, lastMessageSenderId: $lastMessageSenderId, unseenCount: $unseenCount, dmPartnerUserId: $dmPartnerUserId, dmPartnerName: $dmPartnerName, dmPartnerUsername: $dmPartnerUsername, dmPartnerProfileKey: $dmPartnerProfileKey, lastMessageType: $lastMessageType)';
  }

  @override
  bool operator ==(covariant ConversationModel other) {
    if (identical(this, other)) return true;
    final listEquals = const DeepCollectionEquality().equals;

    return other.id == id &&
        other.isDMChat == isDMChat &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt &&
        listEquals(other.participantIds, participantIds) &&
        other.lastMessageContent == lastMessageContent &&
        other.lastMessageTime == lastMessageTime &&
        other.lastMessageSenderId == lastMessageSenderId &&
        other.unseenCount == unseenCount &&
        other.dmPartnerUserId == dmPartnerUserId &&
        other.dmPartnerName == dmPartnerName &&
        other.dmPartnerUsername == dmPartnerUsername &&
        other.dmPartnerProfileKey == dmPartnerProfileKey &&
        other.lastMessageType == lastMessageType;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        isDMChat.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode ^
        participantIds.hashCode ^
        lastMessageContent.hashCode ^
        lastMessageTime.hashCode ^
        lastMessageSenderId.hashCode ^
        unseenCount.hashCode ^
        dmPartnerUserId.hashCode ^
        dmPartnerName.hashCode ^
        dmPartnerUsername.hashCode ^
        dmPartnerProfileKey.hashCode ^
        lastMessageType.hashCode;
  }

  ConversationModel copyWith({
    String? id,
    bool? isDMChat,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? groupName,
    String? groupPhotoKey,
    String? groupDescription,
    List<String>? participantIds,
    String? lastMessageContent,
    DateTime? lastMessageTime,
    String? lastMessageSenderId,
    int? unseenCount,
    String? dmPartnerUserId,
    String? dmPartnerName,
    String? dmPartnerUsername,
    String? dmPartnerProfileKey,
    String? lastMessageType,
  }) {
    return ConversationModel(
      id: id ?? this.id,
      isDMChat: isDMChat ?? this.isDMChat,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,

      participantIds: participantIds ?? this.participantIds,
      lastMessageContent: lastMessageContent ?? this.lastMessageContent,
      lastMessageTime: lastMessageTime ?? this.lastMessageTime,
      lastMessageSenderId: lastMessageSenderId ?? this.lastMessageSenderId,
      unseenCount: unseenCount ?? this.unseenCount,
      dmPartnerUserId: dmPartnerUserId ?? this.dmPartnerUserId,
      dmPartnerName: dmPartnerName ?? this.dmPartnerName,
      dmPartnerUsername: dmPartnerUsername ?? this.dmPartnerUsername,
      dmPartnerProfileKey: dmPartnerProfileKey ?? this.dmPartnerProfileKey,
      lastMessageType: lastMessageType ?? this.lastMessageType,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'isDMChat': isDMChat,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),

      'participantIds': participantIds,
      'lastMessageContent': lastMessageContent,
      'lastMessageTime': lastMessageTime?.millisecondsSinceEpoch,
      'lastMessageSenderId': lastMessageSenderId,
      'unseenCount': unseenCount,
      'dmPartnerUserId': dmPartnerUserId,
      'dmPartnerName': dmPartnerName,
      'dmPartnerUsername': dmPartnerUsername,
      'dmPartnerProfileKey': dmPartnerProfileKey,
      'lastMessageType': lastMessageType,
    };
  }

  factory ConversationModel.fromMap(Map<String, dynamic> map) {
    return ConversationModel(
      id: map['id'] as String,
      isDMChat: map['isDMChat'] as bool,
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),

      participantIds: List<String>.from(map['participantIds'] as List),
      lastMessageContent: map['lastMessageContent'] != null
          ? map['lastMessageContent'] as String
          : null,
      lastMessageTime: map['lastMessageTime'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['lastMessageTime'] as int)
          : null,
      lastMessageSenderId: map['lastMessageSenderId'] != null
          ? map['lastMessageSenderId'] as String
          : null,
      unseenCount: map['unseenCount'] as int,
      dmPartnerUserId: map['dmPartnerUserId'] != null
          ? map['dmPartnerUserId'] as String
          : null,
      dmPartnerName: map['dmPartnerName'] != null
          ? map['dmPartnerName'] as String
          : null,
      dmPartnerUsername: map['dmPartnerUsername'] != null
          ? map['dmPartnerUsername'] as String
          : null,
      dmPartnerProfileKey: map['dmPartnerProfileKey'] != null
          ? map['dmPartnerProfileKey'] as String
          : null,
      lastMessageType: map['lastMessageType'] != null
          ? map['lastMessageType'] as String
          : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory ConversationModel.fromJson(String source) =>
      ConversationModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
