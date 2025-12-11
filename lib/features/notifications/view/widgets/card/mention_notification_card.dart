import 'package:flutter/material.dart';
import 'package:lite_x/core/theme/palette.dart';
import 'package:lite_x/features/profile/models/shared.dart';

import 'notification_timestamp.dart';
import 'notification_metrics_row.dart';

import '../../../notification_model.dart';

class MentionNotificationCard extends StatelessWidget {
  final NotificationItem notification;
  final bool isLiked;
  final bool isRetweeted;
  final bool isBookmarked;
  final int likesCount;
  final int repostsCount;
  final VoidCallback? onOpenProfile;
  final VoidCallback? onOpenTweet;
  final VoidCallback? onToggleLike;
  final VoidCallback? onToggleRetweet;
  final VoidCallback? onToggleBookmark;
  final VoidCallback? onOpenQuoteComposer;

  const MentionNotificationCard({
    super.key,
    required this.notification,
    required this.isLiked,
    required this.isRetweeted,
    required this.isBookmarked,
    required this.likesCount,
    required this.repostsCount,
    this.onOpenProfile,
    this.onOpenTweet,
    this.onToggleLike,
    this.onToggleRetweet,
    this.onToggleBookmark,
    this.onOpenQuoteComposer,
  });

  TextStyle get _nameStyle => const TextStyle(
        fontFamily: 'SF Pro Text',
        fontWeight: FontWeight.w600,
        color: Palette.textPrimary,
      );

  TextStyle get _secondaryStyle => const TextStyle(
        fontFamily: 'SF Pro Text',
        color: Palette.textSecondary,
        fontSize: 14,
      );

  TextStyle get _bodyStyle => const TextStyle(
        fontFamily: 'SF Pro Text',
        color: Palette.textPrimary,
        fontSize: 14,
        height: 1.4,
      );

  @override
  Widget build(BuildContext context) {
    final String bodyText;
    if (notification.tweet != null && notification.tweet!.content.isNotEmpty) {
      bodyText = notification.tweet!.content;
    } else {
      bodyText = notification.body;
    }

    final profileMediaId = notification.actor.profileMediaId;
    final showMetrics = notification.title == 'MENTION' ||
        notification.title == 'REPLY' ||
        notification.title == 'QUOTE';
    final hasMetrics = notification.repliesCount > 0 ||
        repostsCount > 0 ||
        likesCount > 0;

    final card = Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.white, width: 0.5),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: onOpenProfile,
            behavior: HitTestBehavior.opaque,
            child: BuildSmallProfileImage(
              radius: 20,
              mediaId: profileMediaId,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: onOpenProfile,
                  behavior: HitTestBehavior.opaque,
                  child: Row(
                    children: [
                      Flexible(
                        child: Text(
                          notification.actor.name,
                          style: _nameStyle,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${_actorHandle()} · ${formatNotificationTimestamp(notification.createdAt)}',
                        style: const TextStyle(
                          fontFamily: 'SF Pro Text',
                          color: Palette.textTertiary,
                          fontSize: 13,
                        ),
                      ),
                      const Spacer(),
                    ],
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _getActionText(),
                  style: const TextStyle(
                    fontFamily: 'SF Pro Text',
                    color: Palette.textSecondary,
                    fontSize: 13,
                  ),
                ),
                if (bodyText.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(bodyText, style: _bodyStyle),
                ],
                if (_hasQuotedTweet()) _buildQuotedTweet(),
                if (showMetrics && hasMetrics)
                  NotificationMetricsRow(
                    repliesCount: notification.repliesCount,
                    repostsCount: repostsCount,
                    likesCount: likesCount,
                    isRetweeted: isRetweeted,
                    isLiked: isLiked,
                    isBookmarked: isBookmarked,
                    onOpenTweet: onOpenTweet,
                    onToggleRetweet: onToggleRetweet,
                    onToggleLike: onToggleLike,
                    onToggleBookmark: onToggleBookmark,
                    onOpenQuoteComposer: onOpenQuoteComposer,
                  ),
              ],
            ),
          ),
        ],
      ),
    );

    if (onOpenTweet == null) return card;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onOpenTweet,
      child: card,
    );
  }

  String _formatHandle(String value) {
    if (value.isEmpty) return '@you';
    return value.startsWith('@') ? value : '@$value';
  }

  String _actorHandle() {
    if (notification.actor.username.isNotEmpty) {
      return _formatHandle(notification.actor.username);
    }
    final sanitized = notification.actor.name.toLowerCase().replaceAll(
          RegExp(r'[^a-z0-9_]'),
          '_',
        );
    return _formatHandle(sanitized);
  }

  String _getActionText() {
    final target = _formatHandle(
      notification.targetUsername ?? notification.actor.username,
    );

    switch (notification.title) {
      case 'REPLY':
        return 'replied to your post';
      case 'QUOTE':
        return 'quoted your post';
      case 'MENTION':
        return 'Replying to $target';
      default:
        return 'Replying to $target';
    }
  }

  bool _hasQuotedTweet() {
    return (notification.quotedAuthor?.isNotEmpty ?? false) &&
        (notification.quotedContent?.isNotEmpty ?? false);
  }

  Widget _buildQuotedTweet() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 8.0),
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Palette.textTertiary.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(notification.quotedAuthor ?? '', style: _nameStyle),
          const SizedBox(height: 4),
          Text(notification.quotedContent ?? '', style: _secondaryStyle),
        ],
      ),
    );
  }
}
