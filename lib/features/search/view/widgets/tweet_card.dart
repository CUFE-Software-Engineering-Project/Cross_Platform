import 'package:flutter/material.dart';
import 'package:lite_x/core/theme/palette.dart';
import 'package:lite_x/features/home/models/tweet_model.dart';

class TweetCardWidget extends StatelessWidget {
  final TweetModel tweet;
  final ValueChanged<String>? onLike;

  const TweetCardWidget({
    super.key,
    required this.tweet,
    this.onLike,
  });

  String _formatTimestamp(DateTime createdAt) {
    final now = DateTime.now();
    final diff = now.difference(createdAt);
    if (diff.inDays > 7) {
      return '${createdAt.day}/${createdAt.month}/${createdAt.year}';
    } else if (diff.inDays > 0) {
      return '${diff.inDays}d';
    } else if (diff.inHours > 0) {
      return '${diff.inHours}h';
    } else if (diff.inMinutes > 0) {
      return '${diff.inMinutes}m';
    }
    return 'now';
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {},
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: Palette.cardBackground,
              backgroundImage: tweet.authorAvatar.isNotEmpty
                  ? NetworkImage(tweet.authorAvatar)
                  : null,
              child: tweet.authorAvatar.isEmpty
                  ? const Icon(Icons.person, color: Palette.textPrimary, size: 20)
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          tweet.authorName,
                          style: const TextStyle(
                            color: Palette.textPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '@${tweet.authorUsername}',
                        style: const TextStyle(
                          color: Palette.textSecondary,
                          fontSize: 14,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _formatTimestamp(tweet.createdAt),
                        style: const TextStyle(
                          color: Palette.textTertiary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  if (tweet.content.isNotEmpty)
                    Text(
                      tweet.content,
                      style: const TextStyle(
                        color: Palette.textPrimary,
                        fontSize: 14,
                      ),
                    ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(
                          tweet.isLiked
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color:
                              tweet.isLiked ? Palette.like : Palette.textTertiary,
                          size: 18,
                        ),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onPressed: () => onLike?.call(tweet.id),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        tweet.likes.toString(),
                        style: const TextStyle(
                          color: Palette.textTertiary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
