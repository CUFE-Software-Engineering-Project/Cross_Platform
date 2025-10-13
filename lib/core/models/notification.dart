import 'package:flutter/material.dart';

enum NotificationType {
  like,
  repost,
  follow,
  mention,
  reply,
}

class User {
  final String username;
  final String avatarUrl;
  final bool isVerified;

  User({
    required this.username,
    required this.avatarUrl,
    this.isVerified = false,
  });
}

class AppNotification {
  final User user;
  final NotificationType type;
  final String content;
  final String timestamp;
  final String? postSnippet;

  AppNotification({
    required this.user,
    required this.type,
    required this.content,
    required this.timestamp,
    this.postSnippet,
  });
}

// --- Helper Functions for UI ---

IconData getIconForType(NotificationType type) {
  switch (type) {
    case NotificationType.like:
      return Icons.favorite;
    case NotificationType.repost:
      return Icons.repeat;
    case NotificationType.follow:
      return Icons.person;
    case NotificationType.mention:
    case NotificationType.reply:
      return Icons.chat_bubble;
  }
}

Color getColorForType(NotificationType type) {
  switch (type) {
    case NotificationType.like:
      return Colors.red.shade300;
    case NotificationType.repost:
      return Colors.green.shade300;
    case NotificationType.follow:
      return Colors.blue.shade300;
    case NotificationType.mention:
    case NotificationType.reply:
      return Colors.blue.shade400;
  }
}
