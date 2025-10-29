import 'dart:convert';
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
  String? groupName;
  @HiveField(5)
  String? groupPhoto;
  @HiveField(6)
  String? groupDescription;
  @HiveField(7)
  List<String> participantIds;
  @HiveField(8)
  String? lastMessageContent;
  @HiveField(9)
  DateTime? lastMessageTime;
  @HiveField(10)
  String? lastMessageSenderId;
  @HiveField(11)
  int unseenCount;

  ConversationModel({
    required this.id,
    required this.isDMChat,
    required this.createdAt,
    required this.updatedAt,
    this.groupName,
    this.groupPhoto,
    this.groupDescription,
    required this.participantIds,
    this.lastMessageContent,
    this.lastMessageTime,
    this.lastMessageSenderId,
    this.unseenCount = 0,
  });
  factory ConversationModel.fromApiResponse(Map<String, dynamic> json) {
    final chatUsers = json['chatUsers'] as List<dynamic>? ?? [];
    final participantIds = chatUsers
        .map((cu) => cu['userId'] as String)
        .toList();
    final messages = json['messages'] as List<dynamic>? ?? [];
    String? lastMessageContent;
    DateTime? lastMessageTime;
    String? lastMessageSenderId;
    if (messages.isNotEmpty) {
      final lastMsg = messages.first;
      lastMessageContent = lastMsg['content'] as String?;
      lastMessageTime = DateTime.parse(lastMsg['createdAt'] as String);
      lastMessageSenderId = lastMsg['userId'] as String;
    }
    final chatGroup = json['chatGroup'] as Map<String, dynamic>?;

    return ConversationModel(
      id: json['id'] as String,
      isDMChat: json['DMChat'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      groupName: chatGroup?['name'] as String?,
      groupPhoto: chatGroup?['photo'] as String?,
      groupDescription: chatGroup?['description'] as String?,
      participantIds: participantIds,
      lastMessageContent: lastMessageContent,
      lastMessageTime: lastMessageTime,
      lastMessageSenderId: lastMessageSenderId,
      unseenCount: 0,
    );
  }

  ConversationModel copyWith({
    String? id,
    bool? isDMChat,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? groupName,
    String? groupPhoto,
    String? groupDescription,
    List<String>? participantIds,
    String? lastMessageContent,
    DateTime? lastMessageTime,
    String? lastMessageSenderId,
    int? unseenCount,
  }) {
    return ConversationModel(
      id: id ?? this.id,
      isDMChat: isDMChat ?? this.isDMChat,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      groupName: groupName ?? this.groupName,
      groupPhoto: groupPhoto ?? this.groupPhoto,
      groupDescription: groupDescription ?? this.groupDescription,
      participantIds: participantIds ?? this.participantIds,
      lastMessageContent: lastMessageContent ?? this.lastMessageContent,
      lastMessageTime: lastMessageTime ?? this.lastMessageTime,
      lastMessageSenderId: lastMessageSenderId ?? this.lastMessageSenderId,
      unseenCount: unseenCount ?? this.unseenCount,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'isDMChat': isDMChat,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'groupName': groupName,
      'groupPhoto': groupPhoto,
      'groupDescription': groupDescription,
      'participantIds': participantIds,
      'lastMessageContent': lastMessageContent,
      'lastMessageTime': lastMessageTime?.toIso8601String(),
      'lastMessageSenderId': lastMessageSenderId,
      'unseenCount': unseenCount,
    };
  }

  factory ConversationModel.fromMap(Map<String, dynamic> map) {
    return ConversationModel(
      id: map['id'] as String,
      isDMChat: map['isDMChat'] as bool,
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
      groupName: map['groupName'] as String?,
      groupPhoto: map['groupPhoto'] as String?,
      groupDescription: map['groupDescription'] as String?,
      participantIds: List<String>.from(map['participantIds'] as List),
      lastMessageContent: map['lastMessageContent'] as String?,
      lastMessageTime: map['lastMessageTime'] != null
          ? DateTime.parse(map['lastMessageTime'] as String)
          : null,
      lastMessageSenderId: map['lastMessageSenderId'] as String?,
      unseenCount: map['unseenCount'] as int? ?? 0,
    );
  }

  String toJson() => json.encode(toMap());

  factory ConversationModel.fromJson(String source) =>
      ConversationModel.fromMap(json.decode(source) as Map<String, dynamic>);

  bool get isGroup => !isDMChat;

  String? getOtherParticipantId(String currentUserId) {
    if (!isDMChat) return null;
    return participantIds.firstWhere(
      (id) => id != currentUserId,
      orElse: () => participantIds.first,
    );
  }

  @override
  String toString() {
    return 'ConversationModel(id: $id, isDMChat: $isDMChat, groupName: $groupName, participants: ${participantIds.length}, unseenCount: $unseenCount)';
  }

  @override
  bool operator ==(covariant ConversationModel other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.isDMChat == isDMChat &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^ isDMChat.hashCode ^ updatedAt.hashCode;
  }
}
