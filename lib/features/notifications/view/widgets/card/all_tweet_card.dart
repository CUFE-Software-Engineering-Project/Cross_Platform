import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lite_x/core/providers/dio_interceptor.dart';
import 'package:lite_x/core/theme/palette.dart';
import 'package:lite_x/core/routes/AppRouter.dart';
import 'package:lite_x/core/routes/Route_Constants.dart';
import 'package:lite_x/features/home/repositories/home_repository.dart';
import 'package:lite_x/features/home/view/screens/quote_composer_screen.dart';
import 'package:lite_x/features/home/view/screens/tweet_screen.dart';
import 'package:lite_x/features/profile/models/shared.dart';
import 'package:lite_x/features/notifications/view/widgets/card/login_notification_card.dart';
import 'package:lite_x/features/notifications/view/widgets/card/repost_notification_card.dart';
import 'package:lite_x/features/notifications/view/widgets/card/like_notification_card.dart';
import 'package:lite_x/features/notifications/view/widgets/card/follow_notification_card.dart';
import 'package:lite_x/features/notifications/view/widgets/card/mention_notification_card.dart';
import 'package:lite_x/features/notifications/view/widgets/card/reply_notification_card.dart';
import 'package:lite_x/features/notifications/view/widgets/card/quote_notification_card.dart';

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

  String? get _parentTweetId {
    final parentId = notification.tweet?.parentId;
    if (parentId == null || parentId.isEmpty) return null;
    return parentId;
  }

  void _openActorProfile() {
    final username = notification.actor.username;
    if (username.isEmpty) {
      _showSnack('User profile not available.');
      return;
    }

    Approuter.router.goNamed(
      RouteConstants.profileScreen,
      pathParameters: {'username': username},
    );
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

  void _openParentTweetDetail() {
    final parentId = _parentTweetId;
    if (parentId == null) {
      _showSnack('Tweet is no longer available.');
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => TweetDetailScreen(tweetId: parentId)),
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
          ref.read(notificationViewModelProvider.notifier).updateTweetInteractions(
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
          ref.read(notificationViewModelProvider.notifier).updateTweetInteractions(
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
      vm.updateTweetInteractions(
        tweetId,
        isBookmarked: _bookmarked,
      );
    } catch (_) {
      if (mounted) {
        setState(() {
          _bookmarked = previousBookmarked;
        });
        ref.read(notificationViewModelProvider.notifier).updateTweetInteractions(
              tweetId,
              isBookmarked: previousBookmarked,
            );
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

  @override
  Widget build(BuildContext context) {
    final title = notification.title;

    if (title == 'LOGIN') {
      return LoginNotificationCard(notification: notification);
    }

    if (title == 'RETWEET' || title == 'REPOST') {
      return RepostNotificationCard(
        notification: notification,
        repostsCount: _repostsCount,
        onOpenTweet: _hasTweetLink ? _openTweetDetail : null,
      );
    }

    if (title == 'LIKE') {
      return LikeNotificationCard(
        notification: notification,
        onOpenTweet: _hasTweetLink ? _openTweetDetail : null,
      );
    }

    if (title == 'FOLLOW') {
      return FollowNotificationCard(notification: notification);
    }

    if (title == 'REPLY') {
      return ReplyNotificationCard(
        notification: notification,
        isLiked: _liked,
        isRetweeted: _retweeted,
        isBookmarked: _bookmarked,
        likesCount: _likesCount,
        repostsCount: _repostsCount,
        onOpenProfile: _openActorProfile,
        onOpenTweet: _hasTweetLink ? _openTweetDetail : null,
        onToggleLike: _toggleLike,
        onToggleRetweet: _showRetweetMenu,
        onToggleBookmark: _toggleBookmark,
        onOpenQuoteComposer: _openQuoteComposer,
      );
    }

    if (title == 'QUOTE') {
      return QuoteNotificationCard(
        notification: notification,
        isLiked: _liked,
        isRetweeted: _retweeted,
        isBookmarked: _bookmarked,
        likesCount: _likesCount,
        repostsCount: _repostsCount,
        onOpenProfile: _openActorProfile,
        onOpenTweet: _hasTweetLink ? _openTweetDetail : null,
        onOpenQuotedTweet: _parentTweetId != null ? _openParentTweetDetail : null,
        onToggleLike: _toggleLike,
        onToggleRetweet: _showRetweetMenu,
        onToggleBookmark: _toggleBookmark,
        onOpenQuoteComposer: _openQuoteComposer,
      );
    }

    return MentionNotificationCard(
      notification: notification,
      isLiked: _liked,
      isRetweeted: _retweeted,
      isBookmarked: _bookmarked,
      likesCount: _likesCount,
      repostsCount: _repostsCount,
      onOpenProfile: _openActorProfile,
      onOpenTweet: _hasTweetLink ? _openTweetDetail : null,
      onToggleLike: _toggleLike,
      onToggleRetweet: _showRetweetMenu,
      onToggleBookmark: _toggleBookmark,
      onOpenQuoteComposer: _openQuoteComposer,
    );
  }
}
