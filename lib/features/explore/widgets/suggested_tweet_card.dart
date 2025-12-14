import 'package:flutter/material.dart';
import 'package:lite_x/core/theme/Palette.dart';
import '../models/suggested_tweet_model.dart';

class SuggestedTweetCard extends StatelessWidget {
  final SuggestedTweetModel tweet;
  final VoidCallback? onTap;

  const SuggestedTweetCard({super.key, required this.tweet, this.onTap});

  String _formatCount(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    }
    return count.toString();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap:
          onTap ??
          () {
            // Navigate to tweet detail
          },
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: Palette.divider, width: 1)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Column 1: Avatar
            Column(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: Palette.primary,
                  backgroundImage: tweet.avatarUrl.isNotEmpty
                      ? NetworkImage(tweet.avatarUrl)
                      : null,
                  child: tweet.avatarUrl.isEmpty
                      ? const Icon(
                          Icons.person,
                          size: 20,
                          color: Palette.textPrimary,
                        )
                      : null,
                ),
              ],
            ),
            const SizedBox(width: 12),
            // Column 2: Rest of the content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Trend context if available
                  if (tweet.trendContext != null) ...[
                    Text(
                      tweet.trendContext!,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Palette.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                  // User info row
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          tweet.username,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Palette.textPrimary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (tweet.isVerified) ...[
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.check_circle,
                          size: 16,
                          color: Palette.verified,
                        ),
                      ],
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          '${tweet.handle} · ${tweet.timestamp}',
                          style: const TextStyle(
                            fontSize: 15,
                            color: Palette.textSecondary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(
                          Icons.more_vert,
                          size: 20,
                          color: Palette.icons,
                        ),
                        onPressed: () {},
                        constraints: const BoxConstraints(),
                        padding: EdgeInsets.zero,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Tweet content
                  Text(
                    tweet.content,
                    style: const TextStyle(
                      fontSize: 15,
                      color: Palette.textPrimary,
                      height: 1.4,
                    ),
                  ),
                  // Image or video thumbnail if available
                  if (tweet.imageUrl != null) ...[
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        tweet.imageUrl!,
                        width: double.infinity,
                        height: 200,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          height: 200,
                          color: Palette.cardBackground,
                          child: const Center(
                            child: Icon(Icons.image, color: Palette.icons),
                          ),
                        ),
                      ),
                    ),
                  ],
                  // Engagement icons row
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildEngagementButton(
                        icon: Icons.chat_bubble_outline,
                        count: tweet.replyCount,
                        color: Palette.reply,
                      ),
                      _buildEngagementButton(
                        icon: Icons.repeat,
                        count: tweet.repostCount,
                        color: Palette.retweet,
                      ),
                      _buildEngagementButton(
                        icon: Icons.favorite_border,
                        count: tweet.likeCount,
                        color: Palette.like,
                      ),
                      _buildEngagementButton(
                        icon: Icons.share_outlined,
                        count: tweet.shareCount,
                        color: Palette.share,
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

  Widget _buildEngagementButton({
    required IconData icon,
    required int count,
    required Color color,
  }) {
    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: Palette.icons),
            const SizedBox(width: 4),
            Text(
              _formatCount(count),
              style: const TextStyle(fontSize: 13, color: Palette.icons),
            ),
          ],
        ),
      ),
    );
  }
}
