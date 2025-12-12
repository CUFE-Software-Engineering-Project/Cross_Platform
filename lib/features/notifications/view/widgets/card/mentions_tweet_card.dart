import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lite_x/core/theme/palette.dart';
import 'package:lite_x/core/providers/dio_interceptor.dart';
import 'package:lite_x/features/profile/models/shared.dart';
import 'package:lite_x/features/home/repositories/home_repository.dart';
import 'package:lite_x/features/home/view/screens/quote_composer_screen.dart';
import 'package:lite_x/features/home/view/screens/tweet_screen.dart';
import '../../../mentions_model.dart';

class MentionTweetCard extends ConsumerStatefulWidget {
  final MentionItem mention;

  const MentionTweetCard({super.key, required this.mention});

  @override
  ConsumerState<MentionTweetCard> createState() => _MentionTweetCardState();
}

class _MentionTweetCardState extends ConsumerState<MentionTweetCard> {
  late bool _liked;
  late bool _retweeted;
  late int _likesCount;
  late int _repostsCount;
  bool _processingLike = false;
  bool _processingRetweet = false;
  late bool _bookmarked;
  bool _processingBookmark = false;
  bool _handlingQuote = false;

  MentionItem get mention => widget.mention;

  @override
  void initState() {
    super.initState();
    _hydrateCounts();
  }

  @override
  void didUpdateWidget(MentionTweetCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.mention.id != widget.mention.id ||
        oldWidget.mention.likesCount != widget.mention.likesCount ||
        oldWidget.mention.retweetCount != widget.mention.retweetCount ||
        oldWidget.mention.isLiked != widget.mention.isLiked ||
        oldWidget.mention.isRetweeted != widget.mention.isRetweeted) {
      _hydrateCounts();
    }
  }

  void _hydrateCounts() {
    _liked = mention.isLiked;
    _retweeted = mention.isRetweeted;
    _likesCount = mention.likesCount;
    _repostsCount = mention.retweetCount;
    _bookmarked = mention.isBookmarked ?? false;
  }

  void _showSnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _openTweetDetail() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => TweetDetailScreen(tweetId: mention.id)),
    );
  }

  void _openUserProfile() {
    final username = mention.user.username;
    if (username.isEmpty) {
      _showSnack('User profile not available');
      return;
    }
    Navigator.of(context).pushNamed('/profile', arguments: {'username': username});
  }

  Future<void> _openQuoteComposer() async {
    if (_handlingQuote) return;

    _handlingQuote = true;
    try {
      final repository = ref.read(homeRepositoryProvider);
      final tweet = await repository.getTweetById(mention.id);
      if (!mounted) return;
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => QuoteComposerScreen(quotedTweet: tweet),
        ),
      );
    } catch (_) {
      _showSnack('Unable to open quote composer.');
    } finally {
      _handlingQuote = false;
    }
  }

  void _showRetweetMenu() {
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
                  Icons.repeat,
                  color: _retweeted ? Colors.green : Colors.grey[300],
                ),
                title: Text(
                  _retweeted ? 'Undo Repost' : 'Repost',
                  style: TextStyle(
                    color: _retweeted ? Colors.green : Colors.grey[300],
                    fontSize: 16,
                  ),
                ),
                onTap: () {
                  Navigator.pop(modalContext);
                  _toggleRetweet();
                },
              ),
              ListTile(
                leading: Icon(Icons.edit_outlined, color: Colors.grey[300]),
                title: const Text(
                  'Quote',
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                ),
                onTap: () {
                  Navigator.pop(modalContext);
                  _openQuoteComposer();
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Future<void> _toggleLike() async {
    if (_processingLike) return;

    _processingLike = true;
    final previousLiked = _liked;
    final previousCount = _likesCount;
    final newState = !previousLiked;

    setState(() {
      _liked = newState;
      _likesCount = newState
          ? (previousCount + 1)
          : (previousCount - 1 < 0 ? 0 : previousCount - 1);
    });

    try {
      final dio = ref.read(dioProvider);
      if (previousLiked) {
        await dio.delete('api/tweets/${mention.id}/likes');
      } else {
        await dio.post('api/tweets/${mention.id}/likes');
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _liked = previousLiked;
          _likesCount = previousCount;
        });
      }
      _showSnack('Unable to ${previousLiked ? 'unlike' : 'like'} right now.');
    } finally {
      _processingLike = false;
    }
  }

  Future<void> _toggleRetweet() async {
    if (_processingRetweet) return;

    _processingRetweet = true;
    final previousState = _retweeted;
    final previousCount = _repostsCount;
    final newState = !previousState;

    setState(() {
      _retweeted = newState;
      _repostsCount = newState
          ? (previousCount + 1)
          : (previousCount - 1 < 0 ? 0 : previousCount - 1);
    });

    try {
      final dio = ref.read(dioProvider);
      if (previousState) {
        await dio.delete('api/tweets/${mention.id}/retweets');
      } else {
        await dio.post('api/tweets/${mention.id}/retweets');
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _retweeted = previousState;
          _repostsCount = previousCount;
        });
      }
      _showSnack('Unable to ${previousState ? 'undo' : 'send'} repost.');
    } finally {
      _processingRetweet = false;
    }
  }

  Future<void> _toggleBookmark() async {
    if (_processingBookmark) return;

    _processingBookmark = true;
    final previousBookmarked = _bookmarked;
    final newState = !previousBookmarked;

    setState(() {
      _bookmarked = newState;
    });

    try {
      final dio = ref.read(dioProvider);
      if (previousBookmarked) {
        await dio.delete('api/tweets/${mention.id}/bookmark');
      } else {
        await dio.post('api/tweets/${mention.id}/bookmark');
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _bookmarked = previousBookmarked;
        });
      }
      _showSnack('Unable to update bookmark right now.');
    } finally {
      _processingBookmark = false;
    }
  }

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

  String _formatHandle(String value) {
    if (value.isEmpty) return '@you';
    return value.startsWith('@') ? value : '@$value';
  }

  TextStyle get _nameStyle => const TextStyle(
    fontFamily: 'SF Pro Text',
    fontWeight: FontWeight.w600,
    color: Palette.textPrimary,
  );

  TextStyle get _bodyStyle => const TextStyle(
    fontFamily: 'SF Pro Text',
    color: Palette.textPrimary,
    fontSize: 14,
    height: 1.4,
  );

  Widget _cardShell({
    required Widget child,
    EdgeInsetsGeometry? padding,
    VoidCallback? onTap,
  }) {
    final content = Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      padding: padding ?? const EdgeInsets.symmetric(vertical: 12.0),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.white, width: 0.5),
        ),
      ),
      child: child,
    );

    if (onTap == null) {
      return content;
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: content,
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
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          if (count != null) ...[
            const SizedBox(width: 4),
            Text(
              count.toString(),
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

  Widget _buildMetricsRow() {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _metricButton(
            icon: Icons.mode_comment_outlined,
            count: mention.repliesCount,
            onTap: _openTweetDetail,
          ),
          _metricButton(
            icon: Icons.repeat,
            count: _repostsCount,
            color: _retweeted ? Palette.retweet : Palette.textTertiary,
            onTap: _showRetweetMenu,
          ),
          _metricButton(
            icon: Icons.favorite,
            count: _likesCount,
            color: _liked ? Palette.like : Palette.textTertiary,
            onTap: _toggleLike,
          ),
          _metricButton(
            icon: _bookmarked ? Icons.bookmark : Icons.bookmark_border,
            color: _bookmarked ? Palette.primary : Palette.textTertiary,
            onTap: _toggleBookmark,
          ),
          _metricButton(
            icon: Icons.ios_share_outlined,
            onTap: _openQuoteComposer,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profileImageUrl = mention.user.profileMedia?.id;
    final String bodyText = mention.content.isNotEmpty ? mention.content : '';

    return _cardShell(
      onTap: _openTweetDetail,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: _openUserProfile,
            child: ClipOval(
              child: SizedBox(
                width: 40,
                height: 40,
                child: BuildSmallProfileImage(
                  mediaId: profileImageUrl,
                  radius: 20,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: GestureDetector(
                        onTap: _openUserProfile,
                        child: Text(
                          mention.user.name,
                          style: _nameStyle,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    GestureDetector(
                      onTap: _openUserProfile,
                      child: Text(
                        '${_formatHandle(mention.user.username)} · ${_formatTimestamp(mention.createdAt)}',
                        style: const TextStyle(
                          fontFamily: 'SF Pro Text',
                          color: Palette.textTertiary,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    const Spacer(),
                  ],
                ),
                const SizedBox(height: 2),
                const Text(
                  'mentioned you',
                  style: TextStyle(
                    fontFamily: 'SF Pro Text',
                    color: Palette.textSecondary,
                    fontSize: 13,
                  ),
                ),
                if (bodyText.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(bodyText, style: _bodyStyle),
                ],
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
                              image: NetworkImage(mention.mediaUrls[index].url),
                              fit: BoxFit.cover,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
                _buildMetricsRow(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
