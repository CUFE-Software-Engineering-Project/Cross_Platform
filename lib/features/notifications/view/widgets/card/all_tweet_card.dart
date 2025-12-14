import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lite_x/core/providers/dio_interceptor.dart';
import 'package:lite_x/core/theme/Palette.dart';
import 'package:lite_x/features/home/repositories/home_repository.dart';
import 'package:lite_x/features/home/view/screens/quote_composer_screen.dart';
import 'package:lite_x/features/home/view/screens/tweet_screen.dart';
import 'package:lite_x/features/profile/models/shared.dart';

import '../../../notification_model.dart';
import '../../../notification_view_model.dart';

class AllTweetCardWidget extends ConsumerStatefulWidget {
  final NotificationItem notification;

  const AllTweetCardWidget({super.key, required this.notification});

  @override
  ConsumerState<AllTweetCardWidget> createState() => _AllTweetCardWidgetState();
}

class _AllTweetCardWidgetState extends ConsumerState<AllTweetCardWidget> {
  late bool _liked;
  late bool _retweeted;
  late int _likesCount;
  late int _repostsCount;
  bool _processingLike = false;
  bool _processingRetweet = false;
  late bool _bookmarked;
  bool _processingBookmark = false;
  bool _handlingQuote = false;

  NotificationItem get notification => widget.notification;

  bool get _isSystemAlert => notification.title == 'LOGIN';
  bool get _isRetweet =>
      notification.title == 'RETWEET' || notification.title == 'REPOST';
  bool get _isLike => notification.title == 'LIKE';
  bool get _isFollow => notification.title == 'FOLLOW';
  bool get _hasTweetLink => _tweetId != null;

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

  String? get _tweetId {
    final id = notification.tweetId;
    if (id == null || id.isEmpty) return null;
    return id;
  }

  @override
  void initState() {
    super.initState();
    _hydrateCounts();
  }

  @override
  void didUpdateWidget(AllTweetCardWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.notification.id != widget.notification.id ||
        oldWidget.notification.likesCount != widget.notification.likesCount ||
        oldWidget.notification.repostsCount !=
            widget.notification.repostsCount ||
        oldWidget.notification.isLiked != widget.notification.isLiked ||
        oldWidget.notification.isRetweeted != widget.notification.isRetweeted) {
      _hydrateCounts();
    }
  }

  void _hydrateCounts() {
    _liked = notification.isLiked;
    _retweeted = notification.isRetweeted;
    _likesCount = notification.likesCount;
    _repostsCount = notification.repostsCount;
    _bookmarked = notification.isBookmarked;
  }

  void _showSnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _openTweetDetail() {
    final tweetId = _tweetId;
    if (tweetId == null) {
      _showSnack('Tweet is no longer available.');
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => TweetDetailScreen(tweetId: tweetId)),
    );
  }

  void _openUserProfile() {
    final username = notification.actor.username;
    if (username.isEmpty) {
      _showSnack('User profile not available');
      return;
    }
    Navigator.of(
      context,
    ).pushNamed('/profile', arguments: {'username': username});
  }

  Future<void> _toggleLike() async {
    if (_processingLike) return;
    final tweetId = _tweetId;
    if (tweetId == null) {
      _showSnack('Tweet is no longer available.');
      return;
    }

    _processingLike = true;
    final previousLiked = _liked;
    final previousCount = _likesCount;
    final newState = !previousLiked;

    setState(() {
      _liked = newState;
      _likesCount = newState
          ? previousCount + 1
          : (previousCount - 1 < 0 ? 0 : previousCount - 1);
    });

    final vm = ref.read(notificationViewModelProvider.notifier);
    final currentTweetId = tweetId;
    if (currentTweetId != null) {
      vm.updateTweetInteractions(
        currentTweetId,
        likesCount: _likesCount,
        isLiked: _liked,
      );
    }

    try {
      final dio = ref.read(dioProvider);
      if (previousLiked) {
        await dio.delete('api/tweets/$tweetId/likes');
      } else {
        await dio.post('api/tweets/$tweetId/likes');
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _liked = previousLiked;
          _likesCount = previousCount;
        });
        final currentTweetId = tweetId;
        if (currentTweetId != null) {
          ref
              .read(notificationViewModelProvider.notifier)
              .updateTweetInteractions(
                currentTweetId,
                likesCount: previousCount,
                isLiked: previousLiked,
              );
        }
      }
      _showSnack('Unable to ${previousLiked ? 'unlike' : 'like'} right now.');
    } finally {
      _processingLike = false;
    }
  }

  Future<void> _toggleRetweet() async {
    if (_processingRetweet) return;
    final tweetId = _tweetId;
    if (tweetId == null) {
      _showSnack('Tweet is no longer available.');
      return;
    }

    _processingRetweet = true;
    final previousState = _retweeted;
    final previousCount = _repostsCount;
    final newState = !previousState;

    setState(() {
      _retweeted = newState;
      _repostsCount = newState
          ? previousCount + 1
          : (previousCount - 1 < 0 ? 0 : previousCount - 1);
    });

    final vm = ref.read(notificationViewModelProvider.notifier);
    final currentTweetId = tweetId;
    if (currentTweetId != null) {
      vm.updateTweetInteractions(
        currentTweetId,
        repostsCount: _repostsCount,
        isRetweeted: _retweeted,
      );
    }

    try {
      final dio = ref.read(dioProvider);
      if (previousState) {
        await dio.delete('api/tweets/$tweetId/retweets');
      } else {
        await dio.post('api/tweets/$tweetId/retweets');
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _retweeted = previousState;
          _repostsCount = previousCount;
        });
        final currentTweetId = tweetId;
        if (currentTweetId != null) {
          ref
              .read(notificationViewModelProvider.notifier)
              .updateTweetInteractions(
                currentTweetId,
                repostsCount: previousCount,
                isRetweeted: previousState,
              );
        }
      }
      _showSnack('Unable to ${previousState ? 'undo' : 'send'} repost.');
    } finally {
      _processingRetweet = false;
    }
  }

  Future<void> _toggleBookmark() async {
    if (_processingBookmark) return;
    final tweetId = _tweetId;
    if (tweetId == null) {
      _showSnack('Tweet is no longer available.');
      return;
    }

    _processingBookmark = true;
    final previousBookmarked = _bookmarked;
    final newState = !previousBookmarked;

    setState(() {
      _bookmarked = newState;
    });

    try {
      final dio = ref.read(dioProvider);
      if (previousBookmarked) {
        await dio.delete('api/tweets/$tweetId/bookmark');
      } else {
        await dio.post('api/tweets/$tweetId/bookmark');
      }

      final vm = ref.read(notificationViewModelProvider.notifier);
      vm.updateTweetInteractions(tweetId, isBookmarked: _bookmarked);
    } catch (_) {
      if (mounted) {
        setState(() {
          _bookmarked = previousBookmarked;
        });
        ref
            .read(notificationViewModelProvider.notifier)
            .updateTweetInteractions(tweetId, isBookmarked: previousBookmarked);
      }
      _showSnack('Unable to update bookmark right now.');
    } finally {
      _processingBookmark = false;
    }
  }

  Future<void> _openQuoteComposer() async {
    if (_handlingQuote) return;
    final tweetId = _tweetId;
    if (tweetId == null) {
      _showSnack('Tweet is no longer available.');
      return;
    }

    _handlingQuote = true;
    try {
      final repository = ref.read(homeRepositoryProvider);
      final tweet = await repository.getTweetById(tweetId);
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

  Widget _cardShell({
    required Widget child,
    EdgeInsetsGeometry? padding,
    VoidCallback? onTap,
  }) {
    final content = Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      padding: padding ?? const EdgeInsets.symmetric(vertical: 12.0),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.white, width: 0.5)),
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

  Widget _buildBadgeIcon({required IconData icon, required Color color}) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(color: Colors.black, shape: BoxShape.circle),
      child: Icon(icon, color: color, size: 30),
    );
  }

  Widget _buildBrandBadge() {
    return Container(
      width: 36,
      height: 36,
      alignment: Alignment.center,
      child: const Text(
        'X',
        style: TextStyle(
          fontFamily: 'SF Pro Display',
          fontWeight: FontWeight.w700,
          color: Palette.textPrimary,
          fontSize: 24,
        ),
      ),
    );
  }

  Widget _buildTimestampText() {
    return Text(
      _formatTimestamp(notification.createdAt),
      style: const TextStyle(
        fontFamily: 'SF Pro Text',
        color: Palette.textTertiary,
        fontSize: 12,
      ),
    );
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
    } catch (_) {
      return createdAt;
    }
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
      case 'RETWEET':
      case 'REPOST':
        final reposts = _repostsCount.clamp(1, 99).toInt();
        return 'retweeted $reposts of your posts';
      case 'LIKE':
        return 'liked your post';
      case 'FOLLOW':
        return 'followed you';
      case 'REPLY':
        return 'replied to your post';
      case 'QUOTE':
        return 'quoted your post';
      default:
        return 'Replying to $target';
    }
  }

  bool _hasQuotedTweet() {
    return (notification.quotedAuthor?.isNotEmpty ?? false) &&
        (notification.quotedContent?.isNotEmpty ?? false);
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

  Widget _buildMetricsRow() {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _metricButton(
            icon: Icons.mode_comment_outlined,
            count: notification.repliesCount,
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

  Widget _buildAlertCard() {
    return _cardShell(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildBrandBadge(),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: Text(notification.body, style: _bodyStyle)),
                    const SizedBox(width: 12),
                    _buildTimestampText(),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityCard({required IconData icon, required Color color}) {
    final description = _getActionText();

    // Prefer tweet content as snapshot; fall back to notification body
    final String snapshotText;
    if (notification.tweet != null && notification.tweet!.content.isNotEmpty) {
      snapshotText = notification.tweet!.content;
    } else {
      snapshotText = notification.body;
    }

    return _cardShell(
      onTap: _hasTweetLink ? _openTweetDetail : null,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildBadgeIcon(icon: icon, color: color),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          text: '${notification.actor.name} ',
                          style: _nameStyle,
                          children: [
                            TextSpan(text: description, style: _secondaryStyle),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    _buildTimestampText(),
                  ],
                ),
                if (snapshotText.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(snapshotText, style: _secondaryStyle),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFollowCard() {
    final description = _getActionText();

    return _cardShell(
      onTap: _hasTweetLink ? _openTweetDetail : null,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BuildSmallProfileImage(mediaId: notification.mediaUrl, radius: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          text: '${notification.actor.name} ',
                          style: _nameStyle,
                          children: [
                            TextSpan(text: description, style: _secondaryStyle),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    _buildTimestampText(),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConversationCard() {
    final String bodyText;
    if (notification.tweet != null && notification.tweet!.content.isNotEmpty) {
      bodyText = notification.tweet!.content;
    } else {
      bodyText = notification.body;
    }

    return _cardShell(
      onTap: _hasTweetLink ? _openTweetDetail : null,
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
                  mediaId: notification.mediaUrl,
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
                          notification.actor.name,
                          style: _nameStyle,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    GestureDetector(
                      onTap: _openUserProfile,
                      child: Text(
                        '${_actorHandle()} · ${_formatTimestamp(notification.createdAt)}',
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
                _buildMetricsRow(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isSystemAlert) {
      return _buildAlertCard();
    }
    if (_isRetweet) {
      return _buildActivityCard(icon: Icons.repeat, color: Palette.retweet);
    }
    if (_isLike) {
      return _buildActivityCard(icon: Icons.favorite, color: Palette.like);
    }
    if (_isFollow) {
      return _buildFollowCard();
    }
    return _buildConversationCard();
  }
}
