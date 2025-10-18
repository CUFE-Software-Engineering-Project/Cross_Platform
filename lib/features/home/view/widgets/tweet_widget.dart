import 'package:flutter/material.dart';

class TweetWidget extends StatelessWidget {
  final String userDisplayName;
  final String username;
  final String timeAgo;
  final String content;
  final String? imageUrl;
  final String? videoUrl;
  final bool isVerified;
  final int replyCount;
  final int retweetCount;
  final int likeCount;
  final int shareCount;
  final int reachCount;
  final bool isSaved;
  final VoidCallback? onReply;
  final VoidCallback? onRetweet;
  final VoidCallback? onLike;
  final VoidCallback? onShare;
  final VoidCallback? onSave;
  final VoidCallback? onReach;
  final VoidCallback? onTap;
  const TweetWidget({
    super.key,
    required this.userDisplayName,
    required this.username,
    required this.timeAgo,
    required this.content,
    this.imageUrl,
    this.videoUrl,
    this.isVerified = false,
    this.replyCount = 0,
    this.retweetCount = 0,
    this.likeCount = 0,
    this.shareCount = 0,
    this.reachCount = 0,
    this.isSaved = false,
    this.onReply,
    this.onRetweet,
    this.onLike,
    this.onShare,
    this.onSave,
    this.onReach,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.black,
          border: Border(
            bottom: BorderSide(color: Colors.grey[800]!, width: 0.5),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Picture
            CircleAvatar(
              radius: 20,
              backgroundColor: Colors.grey[700],
              child: const Icon(Icons.person, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 12),
            // Tweet Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // User Info Row
                  _buildUserInfoRow(),
                  const SizedBox(height: 8),
                  // Tweet Text
                  _buildTweetText(),
                  const SizedBox(height: 12),
                  // Media Content (Image/Video)
                  if (imageUrl != null || videoUrl != null) ...[
                    _buildMediaContent(),
                    const SizedBox(height: 12),
                  ],
                  // Action Buttons
                  _buildActionButtons(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserInfoRow() {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  userDisplayName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (isVerified) ...[
                const SizedBox(width: 4),
                const Icon(Icons.verified, color: Colors.blue, size: 16),
              ],
            ],
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          flex: 2,
          child: Text(
            '@$username',
            style: TextStyle(color: Colors.grey[500], fontSize: 15),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 8),
        Text('·', style: TextStyle(color: Colors.grey[500], fontSize: 15)),
        const SizedBox(width: 4),
        Text(timeAgo, style: TextStyle(color: Colors.grey[500], fontSize: 15)),
      ],
    );
  }

  Widget _buildTweetText() {
    return Text(
      content,
      style: const TextStyle(color: Colors.white, fontSize: 15, height: 1.4),
      textDirection: _isArabicText(content)
          ? TextDirection.rtl
          : TextDirection.ltr,
    );
  }

  Widget _buildMediaContent() {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(
        maxHeight: 400, // Maximum height to prevent extremely tall images
        minHeight: 150, // Minimum height for very small images
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: imageUrl != null
            ? _buildImageContent()
            : videoUrl != null
            ? _buildVideoContent()
            : const SizedBox.shrink(),
      ),
    );
  }

  Widget _buildImageContent() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Image.network(
          imageUrl!,
          width: double.infinity,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Container(
              height: 200,
              color: Colors.grey[900],
              child: Center(
                child: CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                            loadingProgress.expectedTotalBytes!
                      : null,
                  color: Colors.blue,
                ),
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return Container(
              height: 200,
              color: Colors.grey[900],
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.broken_image, color: Colors.grey, size: 48),
                    SizedBox(height: 8),
                    Text(
                      'Failed to load image',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildVideoContent() {
    return Container(
      height: 200, // Fixed height for video placeholder
      color: Colors.grey[900],
      child: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            const Icon(Icons.play_circle_filled, color: Colors.white, size: 64),
            Positioned(
              bottom: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'VIDEO',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate if we need to use smaller spacing for narrow screens
        final isNarrow = constraints.maxWidth < 300;

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Flexible(
              child: _buildActionButton(
                icon: Icons.chat_bubble_outline,
                count: replyCount,
                onTap: onReply,
                compact: isNarrow,
              ),
            ),
            Flexible(
              child: _buildActionButton(
                icon: Icons.repeat,
                count: retweetCount,
                onTap: onRetweet,
                compact: isNarrow,
              ),
            ),
            Flexible(
              child: _buildActionButton(
                icon: Icons.favorite_border,
                count: likeCount,
                onTap: onLike,
                compact: isNarrow,
              ),
            ),
            Flexible(
              child: _buildActionButton(
                icon: Icons.analytics_outlined,
                count: reachCount,
                onTap: onReach,
                compact: isNarrow,
              ),
            ),
            Flexible(child: _buildSaveButton(compact: isNarrow)),
            Flexible(
              child: _buildActionButton(
                icon: Icons.share_outlined,
                count: shareCount,
                onTap: onShare,
                compact: isNarrow,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required int count,
    VoidCallback? onTap,
    bool compact = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: EdgeInsets.all(compact ? 4 : 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.grey[500], size: compact ? 16 : 18),
            if (count > 0 && !compact) ...[
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  _formatCount(count),
                  style: TextStyle(color: Colors.grey[500], fontSize: 13),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ] else if (count > 0 && compact) ...[
              const SizedBox(width: 2),
              Flexible(
                child: Text(
                  _formatCount(count),
                  style: TextStyle(color: Colors.grey[500], fontSize: 11),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSaveButton({bool compact = false}) {
    return InkWell(
      onTap: onSave,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: EdgeInsets.all(compact ? 4 : 8),
        child: Icon(
          isSaved ? Icons.bookmark : Icons.bookmark_border,
          color: isSaved ? Colors.blue : Colors.grey[500],
          size: compact ? 16 : 18,
        ),
      ),
    );
  }

  String _formatCount(int count) {
    if (count < 1000) {
      return count.toString();
    } else if (count < 1000000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    } else {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    }
  }

  bool _isArabicText(String text) {
    // Simple check for Arabic characters
    return RegExp(r'[\u0600-\u06FF]').hasMatch(text);
  }
}
