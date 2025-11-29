import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lite_x/core/providers/dio_interceptor.dart';
import 'package:lite_x/core/theme/palette.dart';
import 'package:lite_x/features/home/repositories/home_repository.dart';
import 'package:lite_x/features/home/view/screens/quote_composer_screen.dart';
import 'package:lite_x/features/home/view/screens/tweet_screen.dart';

import '../../../notification_model.dart';

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
  bool _handlingQuote = false;

  NotificationItem get notification => widget.notification;

  bool get _isSystemAlert => notification.title == 'ALERT';
  bool get _isRepost => notification.title == 'REPOST';
  bool get _isLike => notification.title == 'LIKE';
  bool get _isUnlike => notification.title == 'UNLIKE';
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

    try {
      final dio = ref.read(dioProvider);
      if (previousLiked) {
        await dio.delete('/api/tweets/$tweetId/likes');
      } else {
        await dio.post('/api/tweets/$tweetId/likes');
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

    try {
      final dio = ref.read(dioProvider);
      if (previousState) {
        await dio.delete('/api/tweets/$tweetId/retweets');
      } else {
        await dio.post('/api/tweets/$tweetId/retweets');
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

  Widget _cardShell({
    required Widget child,
    EdgeInsetsGeometry? padding,
    VoidCallback? onTap,
  }) {
    final content = Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      padding: padding ?? const EdgeInsets.symmetric(vertical: 12.0),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Palette.textTertiary.withOpacity(0.1)),
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

  Widget _buildBadgeIcon({required IconData icon, required Color color}) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: Colors.black,
        shape: BoxShape.circle,
        border: Border.all(color: color, width: 1),
      ),
      child: Icon(icon, color: color, size: 20),
    );
  }

  Widget _buildBrandBadge() {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: Colors.black,
        shape: BoxShape.circle,
        border: Border.all(color: Palette.textSecondary),
      ),
      alignment: Alignment.center,
      child: const Text(
        'X',
        style: TextStyle(
          fontFamily: 'SF Pro Display',
          fontWeight: FontWeight.w700,
          color: Palette.textPrimary,
          fontSize: 18,
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
      case 'REPOST':
        final reposts = _repostsCount.clamp(1, 99).toInt();
        return 'reposted $reposts of your posts';
      case 'LIKE':
        return 'liked your post';
      case 'UNLIKE':
        return 'removed their like from your post';
      case 'FOLLOW':
        return 'followed you';
      default:
        return 'Replying to $target';
    }
  }

  bool _hasQuotedTweet() {
    return (notification.quotedAuthor?.isNotEmpty ?? false) &&
        (notification.quotedContent?.isNotEmpty ?? false);
  }

  bool get _hasMetrics =>
      notification.repliesCount > 0 || _repostsCount > 0 || _likesCount > 0;

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
            onTap: _toggleRetweet,
          ),
          _metricButton(
            icon: Icons.favorite_border,
            count: _likesCount,
            color: _liked ? Palette.like : Palette.textTertiary,
            onTap: _toggleLike,
          ),
          _metricButton(
            icon: Icons.bar_chart_outlined,
            onTap: _openTweetDetail,
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
                if (notification.body.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(notification.body, style: _bodyStyle),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConversationCard() {
    return _cardShell(
      onTap: _hasTweetLink ? _openTweetDetail : null,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 20,
            backgroundImage: notification.mediaUrl.isNotEmpty
                ? NetworkImage(notification.mediaUrl)
                : null,
            backgroundColor: Palette.cardBackground,
            child: notification.mediaUrl.isEmpty
                ? const Icon(Icons.person, color: Palette.textPrimary)
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
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
                      '${_actorHandle()} · ${_formatTimestamp(notification.createdAt)}',
                      style: const TextStyle(
                        fontFamily: 'SF Pro Text',
                        color: Palette.textTertiary,
                        fontSize: 13,
                      ),
                    ),
                    const Spacer(),
                    const Icon(
                      Icons.more_horiz,
                      color: Palette.textTertiary,
                      size: 18,
                    ),
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
                if (notification.body.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(notification.body, style: _bodyStyle),
                ],
                if (_hasQuotedTweet()) _buildQuotedTweet(),
                if (_hasMetrics) _buildMetricsRow(),
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
    if (_isRepost) {
      return _buildActivityCard(icon: Icons.repeat, color: Palette.retweet);
    }
    if (_isLike) {
      return _buildActivityCard(icon: Icons.favorite, color: Palette.like);
    }
    if (_isUnlike) {
      return _buildActivityCard(
        icon: Icons.favorite_border,
        color: Palette.textSecondary,
      );
    }
    return _buildConversationCard();
  }
}
