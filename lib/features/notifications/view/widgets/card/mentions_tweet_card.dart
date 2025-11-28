import 'package:flutter/material.dart';
import 'package:lite_x/core/theme/palette.dart';
import '../../../mentions_model.dart';
import 'interaction_bar.dart';

class MentionTweetCard extends StatelessWidget {
  final MentionItem mention;

  const MentionTweetCard({super.key, required this.mention});

  String _formatTimestamp(String createdAt) {
    try {
      final dateTime = DateTime.parse(createdAt);
      final now = DateTime.now();
      final difference = now.difference(dateTime);
      if (difference.inDays > 7) {
        return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
      } else if (difference.inDays > 0) {
        return '${difference.inDays}d';
      } else if (difference.inHours > 0) {
        return '${difference.inHours}h';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes}m';
      } else {
        return 'now';
      }
    } catch (e) {
      return createdAt;
    }
  }

  String formatShortDate(String date) {
  final dt = DateTime.parse(date).toLocal();
  return "${dt.day.toString().padLeft(2, '0')}/"
         "${dt.month.toString().padLeft(2, '0')}/"
         "${dt.year.toString().substring(2)}";
}


  String? _getProfileImageUrl() {
    // Profile media URL is stored in TweetMedia.id (workaround)
    return mention.user.profileMedia?.id;
  }

  @override
  Widget build(BuildContext context) {
    final profileImageUrl = _getProfileImageUrl();

    return Container(
  margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
  padding: const EdgeInsets.all(12.0),
  child: Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      // Avatar
      CircleAvatar(
        radius: 20,
        backgroundImage: (profileImageUrl != null && profileImageUrl.isNotEmpty)
            ? NetworkImage(profileImageUrl)
            : null,
        backgroundColor: Palette.cardBackground,
        child: (profileImageUrl == null || profileImageUrl.isEmpty)
            ? Icon(
                Icons.person,
                color: Palette.textPrimary,
                size: 20,
              )
            : null,
      ),

      const SizedBox(width: 12),

      // Content Column
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Username + Verified + ShortDate + Timestamp
            Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Flexible(
                        child: Text(
                          '${mention.user.name} ',
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Palette.textSecondary,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      Flexible(
                        child: Text(
                          '@${mention.user.username} ',
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Palette.textWhite,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      Text(
                        formatShortDate(mention.createdAt),
                        style: TextStyle(
                          color: Palette.textSecondary,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      if (mention.user.verified)
                        Padding(
                          padding: const EdgeInsets.only(left: 4.0),
                          child: Icon(
                            Icons.verified,
                            color: Palette.verified,
                            size: 16,
                          ),
                        ),
                    ],
                  ),
                ),

                // Right timestamp
                Text(
                  _formatTimestamp(mention.createdAt),
                  style: TextStyle(
                    color: Palette.textTertiary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 6),

            // Tweet content
            if (mention.content.isNotEmpty) ...[
              const SizedBox(height: 6),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  mention.content,
                  style: TextStyle(
                    color: Palette.textPrimary,
                    fontSize: 14,
                  ),
                ),
              ),
            ],

            // Media images if available
            if (mention.mediaUrls.isNotEmpty) ...[
              const SizedBox(height: 8),
              SizedBox(
                height: 200,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: mention.mediaUrls.length,
                  itemBuilder: (context, index) {
                    return Container(
                      margin: const EdgeInsets.only(right: 8.0),
                      width: 200,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        image: DecorationImage(
                          image: NetworkImage(
                            mention.mediaUrls[index].url,
                          ),
                          fit: BoxFit.cover,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],

            const SizedBox(height: 8),

            // Interaction bar
            InteractionBar(
              tweetId: mention.id,
              repliesCount: mention.repliesCount,
              retweetCount: mention.retweetCount,
              likesCount: mention.likesCount,
              quotesCount: mention.quotesCount,
              isLiked: mention.isLiked,
              isRetweeted: mention.isRetweeted,
            ),
          ],
        ),
      ),
    ],
  ),
);

  }
}
