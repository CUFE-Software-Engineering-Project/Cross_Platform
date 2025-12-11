import 'package:flutter/material.dart';
import 'package:lite_x/core/theme/palette.dart';

class NotificationMetricsRow extends StatelessWidget {
  final int repliesCount;
  final int repostsCount;
  final int likesCount;
  final bool isRetweeted;
  final bool isLiked;
  final bool isBookmarked;
  final VoidCallback? onOpenTweet;
  final VoidCallback? onToggleRetweet;
  final VoidCallback? onToggleLike;
  final VoidCallback? onToggleBookmark;
  final VoidCallback? onOpenQuoteComposer;

  const NotificationMetricsRow({
    super.key,
    required this.repliesCount,
    required this.repostsCount,
    required this.likesCount,
    required this.isRetweeted,
    required this.isLiked,
    required this.isBookmarked,
    this.onOpenTweet,
    this.onToggleRetweet,
    this.onToggleLike,
    this.onToggleBookmark,
    this.onOpenQuoteComposer,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _metricButton(
            icon: Icons.mode_comment_outlined,
            count: repliesCount,
            onTap: onOpenTweet,
          ),
          _metricButton(
            icon: Icons.repeat,
            count: repostsCount,
            color: isRetweeted ? Palette.retweet : Palette.textTertiary,
            onTap: onToggleRetweet,
          ),
          _metricButton(
            icon: Icons.favorite,
            count: likesCount,
            color: isLiked ? Palette.like : Palette.textTertiary,
            onTap: onToggleLike,
          ),
          _metricButton(
            icon: isBookmarked ? Icons.bookmark : Icons.bookmark_border,
            color: isBookmarked ? Palette.primary : Palette.textTertiary,
            onTap: onToggleBookmark,
          ),
          _metricButton(
            icon: Icons.ios_share_outlined,
            onTap: onOpenQuoteComposer,
          ),
        ],
      ),
    );
  }

  Widget _metricButton({
    required IconData icon,
    int? count,
    Color color = Palette.textTertiary,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          if (count != null && count > 0) ...[
            const SizedBox(width: 4),
            Text(
              '$count',
              style: TextStyle(
                fontSize: 12,
                color: color,
                fontFamily: 'SF Pro Text',
              ),
            ),
          ],
        ],
      ),
    );
  }
}
