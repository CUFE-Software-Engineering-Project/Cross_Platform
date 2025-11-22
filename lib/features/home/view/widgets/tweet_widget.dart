import 'package:flutter/material.dart';
import 'media_gallery.dart';
import '../../models/tweet_model.dart';

class TweetWidget extends StatelessWidget {
  final String userDisplayName;
  final String username;
  final String timeAgo;
  final String content;
  final String? avatarUrl;
  final String tweetType;
  final String? imageUrl;
  final String? videoUrl;
  final List<String> mediaUrls;
  final bool isVerified;
  final int replyCount;
  final int retweetCount;
  final int likeCount;
  final int shareCount;
  final int reachCount;
  final bool isSaved;
  final bool isLiked;
  final bool isRetweeted;
  final VoidCallback? onReply;
  final VoidCallback? onRetweet;
  final VoidCallback? onQuote;
  final VoidCallback? onLike;
  final VoidCallback? onShare;
  final VoidCallback? onSave;
  final VoidCallback? onReach;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  final VoidCallback? onProfileTap;
  final String? tweetId;
  final bool isOwnTweet;
  final TweetModel? quotedTweet;

  const TweetWidget({
    super.key,
    required this.userDisplayName,
    required this.username,
    required this.timeAgo,
    required this.content,
    this.avatarUrl,
    this.tweetType = 'TWEET',
    this.imageUrl,
    this.videoUrl,
    this.mediaUrls = const [],
    this.isVerified = false,
    this.replyCount = 0,
    this.retweetCount = 0,
    this.likeCount = 0,
    this.shareCount = 0,
    this.reachCount = 0,
    this.isSaved = false,
    this.isLiked = false,
    this.isRetweeted = false,
    this.onReply,
    this.onRetweet,
    this.onQuote,
    this.onLike,
    this.onShare,
    this.onSave,
    this.onReach,
    this.onTap,
    this.onDelete,
    this.onProfileTap,
    this.tweetId,
    this.isOwnTweet = false,
    this.quotedTweet,
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_contextLabel != null) ...[
              _buildContextPill(_contextLabel!),
              const SizedBox(height: 12),
            ],
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildAvatar(),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildUserInfoRow(context),
                      const SizedBox(height: 8),
                      _buildTweetText(),
                      const SizedBox(height: 12),
                      if (quotedTweet != null) ...[
                        _buildQuotedTweet(),
                        const SizedBox(height: 12),
                      ],
                      if (mediaUrls.isNotEmpty ||
                          imageUrl != null ||
                          videoUrl != null) ...[
                        _buildMediaContent(),
                        const SizedBox(height: 12),
                      ],
                      _buildActionButtons(),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    final hasAvatar = avatarUrl != null && avatarUrl!.isNotEmpty;
    final avatar = CircleAvatar(
      radius: 20,
      backgroundColor: Colors.grey[700],
      backgroundImage: hasAvatar ? NetworkImage(avatarUrl!) : null,
      child: hasAvatar
          ? null
          : const Icon(Icons.person, color: Colors.white, size: 24),
    );

    if (onProfileTap == null) {
      return avatar;
    }

    return GestureDetector(
      onTap: onProfileTap,
      behavior: HitTestBehavior.opaque,
      child: avatar,
    );
  }

  Widget _buildUserInfoRow(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: onProfileTap,
            behavior: HitTestBehavior.opaque,
            child: Row(
              children: [
                Flexible(
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
                        const Icon(
                          Icons.verified,
                          color: Colors.blue,
                          size: 16,
                        ),
                      ],
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Text(
                    '·',
                    style: TextStyle(color: Colors.grey[500], fontSize: 15),
                  ),
                ),
                Flexible(
                  child: Text(
                    username.startsWith('@') ? username : '@$username',
                    style: TextStyle(color: Colors.grey[500], fontSize: 15),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Text(
                    '·',
                    style: TextStyle(color: Colors.grey[500], fontSize: 15),
                  ),
                ),
                Text(
                  timeAgo,
                  style: TextStyle(color: Colors.grey[500], fontSize: 15),
                ),
              ],
            ),
          ),
        ),
        IconButton(
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
          icon: Icon(Icons.more_horiz, color: Colors.grey[500], size: 20),
          onPressed: () => _showOptionsMenu(context),
        ),
      ],
    );
  }

  void _showOptionsMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E1E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext modalContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[600],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              if (isOwnTweet && onDelete != null)
                ListTile(
                  leading: const Icon(Icons.delete, color: Colors.red),
                  title: const Text(
                    'Delete',
                    style: TextStyle(color: Colors.red, fontSize: 16),
                  ),
                  onTap: () {
                    Navigator.pop(modalContext);
                    _showDeleteConfirmation(context);
                  },
                ),
              if (!isOwnTweet) ...[
                ListTile(
                  leading: Icon(
                    Icons.person_add_outlined,
                    color: Colors.grey[300],
                  ),
                  title: Text(
                    'Follow @$username',
                    style: TextStyle(color: Colors.grey[300], fontSize: 16),
                  ),
                  onTap: () {
                    Navigator.pop(modalContext);
                  },
                ),
                ListTile(
                  leading: Icon(
                    Icons.volume_off_outlined,
                    color: Colors.grey[300],
                  ),
                  title: Text(
                    'Mute @$username',
                    style: TextStyle(color: Colors.grey[300], fontSize: 16),
                  ),
                  onTap: () {
                    Navigator.pop(modalContext);
                  },
                ),
                ListTile(
                  leading: Icon(Icons.block_outlined, color: Colors.grey[300]),
                  title: Text(
                    'Block @$username',
                    style: TextStyle(color: Colors.grey[300], fontSize: 16),
                  ),
                  onTap: () {
                    Navigator.pop(modalContext);
                  },
                ),
                ListTile(
                  leading: Icon(Icons.flag_outlined, color: Colors.grey[300]),
                  title: Text(
                    'Report post',
                    style: TextStyle(color: Colors.grey[300], fontSize: 16),
                  ),
                  onTap: () {
                    Navigator.pop(modalContext);
                  },
                ),
              ],
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E1E1E),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Delete Post?',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: const Text(
            'This action cannot be undone. Your post will be permanently deleted.',
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                if (onDelete != null) {
                  onDelete!();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
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

  Widget _buildQuotedTweet() {
    if (quotedTweet == null) return const SizedBox.shrink();

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[800]!, width: 1),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 12,
                backgroundImage: NetworkImage(quotedTweet!.authorAvatar),
                backgroundColor: Colors.grey[800],
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Row(
                  children: [
                    Flexible(
                      child: Text(
                        quotedTweet!.authorName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        '@${quotedTweet!.authorUsername}',
                        style: TextStyle(color: Colors.grey[500], fontSize: 14),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '· ${formatTimeAgoShort(quotedTweet!.createdAt)}',
                      style: TextStyle(color: Colors.grey[500], fontSize: 14),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            quotedTweet!.content,
            style: TextStyle(color: Colors.grey[300], fontSize: 14),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          if (quotedTweet!.images.isNotEmpty) ...[
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                quotedTweet!.images.first,
                height: 120,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 120,
                    color: Colors.grey[800],
                    child: const Icon(Icons.image, color: Colors.grey),
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMediaContent() {
    final hasGallery = mediaUrls.isNotEmpty;
    final hasImage = imageUrl != null;
    final hasVideo = videoUrl != null;

    if (!hasGallery && !hasImage && !hasVideo) {
      return const SizedBox.shrink();
    }

    if (hasGallery || hasImage) {
      final urls = hasGallery ? mediaUrls : [if (imageUrl != null) imageUrl!];
      return MediaGallery(urls: urls);
    }

    return _buildVideoContent();
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
                onTap: () => _showRetweetMenu(context),
                compact: isNarrow,
                isActive: isRetweeted,
                activeColor: Colors.green,
              ),
            ),
            Flexible(
              child: _buildActionButton(
                icon: isLiked ? Icons.favorite : Icons.favorite_border,
                count: likeCount,
                onTap: onLike,
                compact: isNarrow,
                isActive: isLiked,
                activeColor: Colors.red,
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
    bool isActive = false,
    Color? activeColor,
  }) {
    final color = isActive && activeColor != null
        ? activeColor
        : Colors.grey[500];

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: EdgeInsets.all(compact ? 4 : 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: compact ? 16 : 18),
            if (count > 0 && !compact) ...[
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  _formatCount(count),
                  style: TextStyle(color: color, fontSize: 13),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ] else if (count > 0 && compact) ...[
              const SizedBox(width: 2),
              Flexible(
                child: Text(
                  _formatCount(count),
                  style: TextStyle(color: color, fontSize: 11),
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
    return RegExp(r'[\u0600-\u06FF]').hasMatch(text);
  }

  String? get _contextLabel {
    switch (tweetType.toUpperCase()) {
      case 'REPLY':
        return 'Reply';
      case 'RETWEET':
      case 'REPOST':
        return 'Repost';
      default:
        return null;
    }
  }

  Widget _buildContextPill(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: Colors.grey[400],
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  void _showRetweetMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E1E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext modalContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[600],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: Icon(
                  isRetweeted ? Icons.repeat : Icons.repeat,
                  color: isRetweeted ? Colors.green : Colors.grey[300],
                ),
                title: Text(
                  isRetweeted ? 'Undo Repost' : 'Repost',
                  style: TextStyle(
                    color: isRetweeted ? Colors.green : Colors.grey[300],
                    fontSize: 16,
                  ),
                ),
                onTap: () {
                  Navigator.pop(modalContext);
                  if (onRetweet != null) onRetweet!();
                },
              ),
              ListTile(
                leading: Icon(Icons.edit_outlined, color: Colors.grey[300]),
                title: Text(
                  'Quote',
                  style: TextStyle(color: Colors.grey[300], fontSize: 16),
                ),
                onTap: () {
                  Navigator.pop(modalContext);
                  if (onQuote != null) onQuote!();
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  static String formatTimeAgoShort(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inSeconds < 60) {
      return '${difference.inSeconds}s';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d';
    } else if (difference.inDays < 30) {
      return '${(difference.inDays / 7).floor()}w';
    } else if (difference.inDays < 365) {
      return '${(difference.inDays / 30).floor()}mo';
    } else {
      return '${(difference.inDays / 365).floor()}y';
    }
  }
}
