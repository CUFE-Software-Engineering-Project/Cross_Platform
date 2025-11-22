import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lite_x/core/providers/current_user_provider.dart';
import 'package:lite_x/features/home/models/tweet_model.dart';
import 'package:lite_x/features/home/repositories/home_repository.dart';
import 'package:lite_x/features/home/view/screens/reply_composer_screen.dart';
import 'package:lite_x/features/home/view/widgets/media_gallery.dart';
import 'package:timeago/timeago.dart' as timeago;

class ReplyThreadScreen extends ConsumerStatefulWidget {
  final List<String> pathTweetIds;

  const ReplyThreadScreen({super.key, required this.pathTweetIds});

  @override
  ConsumerState<ReplyThreadScreen> createState() => _ReplyThreadScreenState();
}

class _ReplyThreadScreenState extends ConsumerState<ReplyThreadScreen> {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _currentReplyKey = GlobalKey();

  Map<String, TweetModel> allTweets = {};
  List<TweetModel> childReplies = [];
  bool isLoading = true;
  String? currentUserId;
  final Map<String, int> _viewCounts = {};

  @override
  void initState() {
    super.initState();
    _loadThreadData();
    _loadCurrentUser();
  }

  void _loadCurrentUser() {
    // Get current user from the provider
    final user = ref.read(currentUserProvider);
    if (user != null) {
      currentUserId = user.id;
    }
  }

  Future<void> _toggleLike(String tweetId) async {
    // Find tweet in allTweets or childReplies
    TweetModel? tweet = allTweets[tweetId];
    if (tweet == null) {
      try {
        tweet = childReplies.firstWhere((t) => t.id == tweetId);
      } catch (e) {
        return;
      }
    }

    final currentLikeState = tweet.isLiked;
    final newLikeState = !currentLikeState;

    // Optimistically update UI
    setState(() {
      tweet!.isLiked = newLikeState;
      tweet.likes += newLikeState ? 1 : -1;
    });

    try {
      final repository = ref.read(homeRepositoryProvider);
      await repository.toggleLike(tweetId, currentLikeState);
      // Keep the optimistic update
    } catch (e) {
      // Revert on error
      if (mounted) {
        setState(() {
          tweet!.isLiked = currentLikeState;
          tweet.likes += currentLikeState ? 1 : -1;
        });
      }
    }
  }

  Future<void> _toggleRetweet(String tweetId) async {
    // Find tweet in allTweets or childReplies
    TweetModel? tweet = allTweets[tweetId];
    if (tweet == null) {
      try {
        tweet = childReplies.firstWhere((t) => t.id == tweetId);
      } catch (e) {
        return;
      }
    }

    final currentRetweetState = tweet.isRetweeted;
    final newRetweetState = !currentRetweetState;

    // Optimistically update UI
    setState(() {
      tweet!.isRetweeted = newRetweetState;
      tweet.retweets += newRetweetState ? 1 : -1;
    });

    try {
      final repository = ref.read(homeRepositoryProvider);
      await repository.toggleRetweet(tweetId, currentRetweetState);
      // Keep the optimistic update
    } catch (e) {
      // Revert on error
      if (mounted) {
        setState(() {
          tweet!.isRetweeted = currentRetweetState;
          tweet.retweets += currentRetweetState ? 1 : -1;
        });
      }
    }
  }

  Future<void> _toggleBookmark(String tweetId) async {
    // Find tweet in allTweets or childReplies
    TweetModel? tweet = allTweets[tweetId];
    if (tweet == null) {
      try {
        tweet = childReplies.firstWhere((t) => t.id == tweetId);
      } catch (e) {
        return;
      }
    }

    final currentBookmarkState = tweet.isBookmarked;
    final newBookmarkState = !currentBookmarkState;

    // Optimistically update UI
    setState(() {
      tweet!.isBookmarked = newBookmarkState;
    });

    try {
      final repository = ref.read(homeRepositoryProvider);
      await repository.toggleBookmark(tweetId, currentBookmarkState);
      // Keep the optimistic update
    } catch (e) {
      // Revert on error
      if (mounted) {
        setState(() {
          tweet!.isBookmarked = currentBookmarkState;
        });
      }
    }
  }

  Future<void> _loadThreadData() async {
    try {
      setState(() => isLoading = true);

      final repository = ref.read(homeRepositoryProvider);
      final Map<String, TweetModel> loadedTweets = {};

      for (String tweetId in widget.pathTweetIds) {
        try {
          final tweet = await repository.getTweetById(tweetId);
          loadedTweets[tweetId] = tweet;
        } catch (e) {}
      }

      final currentReplyId = widget.pathTweetIds.last;
      final replies = await repository.getReplies(currentReplyId);

      if (mounted) {
        setState(() {
          allTweets = loadedTweets;
          childReplies = replies;
          isLoading = false;
        });

        _prefetchViewCounts([...loadedTweets.values, ...replies]);

        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollToCurrentReply();
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  Future<void> _prefetchViewCounts(List<TweetModel> tweets) async {
    final tweetsToFetch = tweets
        .where((tweet) => !_viewCounts.containsKey(tweet.id))
        .toList();

    if (tweetsToFetch.isEmpty) {
      return;
    }

    try {
      final repository = ref.read(homeRepositoryProvider);
      final results = await Future.wait(
        tweetsToFetch.map((tweet) async {
          try {
            final summary = await repository.getTweetSummary(tweet.id);
            return MapEntry(tweet.id, summary.views);
          } catch (_) {
            return MapEntry(tweet.id, 0);
          }
        }),
      );

      if (!mounted) return;

      setState(() {
        for (final entry in results) {
          _viewCounts[entry.key] = entry.value;
        }
      });
    } catch (_) {
      // Ignore summary failures to avoid interrupting the thread rendering
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToCurrentReply() {
    final context = _currentReplyKey.currentContext;
    if (context != null) {
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        alignment: 0.2, // Position reply at 20% from top of screen
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator(color: Colors.blue)),
      );
    }

    final tweets = widget.pathTweetIds
        .map((id) => allTweets[id])
        .where((t) => t != null)
        .cast<TweetModel>()
        .toList();

    if (tweets.isEmpty) {
      return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: const Center(
          child: Text(
            'Thread not found',
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }

    final mainTweet = tweets.first;
    final currentReply = tweets.last;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Post',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.ios_share, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: ListView(
        controller: _scrollController,
        children: [
          _buildTimelineTweetCard(mainTweet),
          const Divider(color: Color(0xFF2F3336), height: 1),

          for (int i = 1; i < tweets.length - 1; i++) ...[
            _buildCompactReply(
              context,
              tweets[i],
              replyingTo: tweets[i - 1].authorUsername,
              pathSoFar: widget.pathTweetIds.sublist(0, i + 1),
            ),
            const Divider(color: Color(0xFF2F3336), height: 1),
          ],

          Container(
            key: _currentReplyKey,
            child: _buildCurrentReplyDetail(
              currentReply,
              replyingTo: tweets.length > 1
                  ? tweets[tweets.length - 2].authorUsername
                  : null,
            ),
          ),
          const Divider(color: Color(0xFF2F3336), height: 1),

          if (childReplies.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Text(
                'Most relevant replies',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ),

          ...childReplies.map(
            (r) => Column(
              children: [
                _buildCompactReply(
                  context,
                  r,
                  replyingTo: currentReply.authorUsername,
                  pathSoFar: [...widget.pathTweetIds, r.id],
                ),
                const Divider(color: Color(0xFF2F3336), height: 1),
              ],
            ),
          ),
          const SizedBox(height: 60),
        ],
      ),
      bottomNavigationBar: _buildReplyBar(),
    );
  }

  Widget _buildTimelineTweetCard(TweetModel tweet) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 20,
                backgroundImage: NetworkImage(tweet.authorAvatar),
                backgroundColor: Colors.grey[800],
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
                            tweet.authorName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          tweet.authorUsername,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '· ${timeago.format(tweet.createdAt, locale: 'en_short')}',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      tweet.content,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.more_horiz, color: Colors.grey[600], size: 18),
            ],
          ),
          if (tweet.images.isNotEmpty) ...[
            const SizedBox(height: 12),
            MediaGallery(urls: tweet.images, borderRadius: 12),
          ],
          const SizedBox(height: 12),
          _inlineActions(tweet),
        ],
      ),
    );
  }

  Widget _buildCompactReply(
    BuildContext context,
    TweetModel reply, {
    required String replyingTo,
    required List<String> pathSoFar,
  }) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ReplyThreadScreen(pathTweetIds: pathSoFar),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 20,
              backgroundImage: NetworkImage(reply.authorAvatar),
              backgroundColor: Colors.grey[800],
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
                          reply.authorName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        reply.authorUsername,
                        style: TextStyle(color: Colors.grey[600], fontSize: 15),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '· ${timeago.format(reply.createdAt, locale: 'en_short')}',
                        style: TextStyle(color: Colors.grey[600], fontSize: 15),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Text(
                        'Replying to ',
                        style: TextStyle(color: Colors.grey[600], fontSize: 15),
                      ),
                      Text(
                        replyingTo,
                        style: const TextStyle(
                          color: Colors.blue,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    reply.content,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      height: 1.4,
                    ),
                  ),
                  if (reply.images.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    MediaGallery(urls: reply.images, borderRadius: 12),
                  ],
                  const SizedBox(height: 12),
                  _inlineActions(reply),
                ],
              ),
            ),
            Icon(Icons.more_horiz, color: Colors.grey[600], size: 18),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentReplyDetail(TweetModel tweet, {String? replyingTo}) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 24,
                backgroundImage: NetworkImage(tweet.authorAvatar),
                backgroundColor: Colors.grey[800],
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
                            tweet.authorName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      tweet.authorUsername,
                      style: TextStyle(color: Colors.grey[600], fontSize: 15),
                    ),
                  ],
                ),
              ),
              _buildActionButton(tweet),
            ],
          ),
          if (replyingTo != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  'Replying to ',
                  style: TextStyle(color: Colors.grey[600], fontSize: 15),
                ),
                Text(
                  replyingTo,
                  style: const TextStyle(color: Colors.blue, fontSize: 15),
                ),
              ],
            ),
          ],
          const SizedBox(height: 12),
          Text(
            tweet.content,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              height: 1.4,
            ),
          ),
          if (tweet.images.isNotEmpty) ...[
            const SizedBox(height: 16),
            MediaGallery(urls: tweet.images, borderRadius: 16),
          ],
          const SizedBox(height: 16),
          _timestampWithViews(tweet),
          const Divider(color: Color(0xFF2F3336), height: 1),
          _replyStats(tweet),
          const Divider(color: Color(0xFF2F3336), height: 1),
          _actionButtons(tweet),
        ],
      ),
    );
  }

  Widget _inlineActions(TweetModel t) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _miniAction(
          Icons.chat_bubble_outline,
          t.replies > 0 ? t.replies.toString() : '',
        ),
        _miniAction(
          Icons.repeat,
          t.retweets > 0 ? _formatNumber(t.retweets) : '',
        ),
        _miniAction(
          t.isLiked ? Icons.favorite : Icons.favorite_border,
          t.likes > 0 ? _formatNumber(t.likes) : '',
          color: t.isLiked ? Colors.pink : null,
        ),
        _miniAction(Icons.bar_chart_outlined, ''),
        _miniAction(Icons.ios_share, ''),
      ],
    );
  }

  Widget _miniAction(IconData icon, String count, {Color? color}) {
    return Row(
      children: [
        Icon(icon, color: color ?? Colors.grey[600], size: 16),
        if (count.isNotEmpty) ...[
          const SizedBox(width: 4),
          Text(count, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
        ],
      ],
    );
  }

  Widget _buildActionButton(TweetModel tweet) {
    const String knownUserId = '6552d72c-3f27-445d-8ad8-bc22cda9ddd9';
    final bool isOwnTweet =
        (currentUserId != null && tweet.userId == currentUserId) ||
        (tweet.userId == knownUserId);

    if (isOwnTweet) {
      return PopupMenuButton<String>(
        icon: Icon(Icons.more_horiz, color: Colors.grey[600], size: 20),
        color: const Color(0xFF1E1E1E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        onSelected: (value) {
          if (value == 'delete') {
            _showDeleteDialog(tweet);
          }
        },
        itemBuilder: (BuildContext context) => [
          const PopupMenuItem<String>(
            value: 'delete',
            child: Row(
              children: [
                Icon(Icons.delete, color: Colors.red, size: 20),
                SizedBox(width: 12),
                Text('Delete', style: TextStyle(color: Colors.red)),
              ],
            ),
          ),
        ],
      );
    } else {
      return Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'Follow',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ),
          const SizedBox(width: 6),
          Icon(Icons.more_horiz, color: Colors.grey[600], size: 18),
        ],
      );
    }
  }

  void _showDeleteDialog(TweetModel tweet) {
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
              onPressed: () async {
                Navigator.pop(dialogContext);
                await _deleteTweet(tweet);
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

  Future<void> _deleteTweet(TweetModel tweet) async {
    try {
      final repository = ref.read(homeRepositoryProvider);
      await repository.deletePost(tweet.id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Post deleted successfully'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );

        final isInPath = widget.pathTweetIds.contains(tweet.id);

        if (isInPath) {
          Navigator.pop(context, true); // Return true to indicate deletion
        } else {
          await _loadThreadData();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete post: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Widget _timestampWithViews(TweetModel t) {
    final formattedTime = DateFormat('h:mm a · d MMM yy').format(t.createdAt);
    final views = _viewCounts[t.id];
    final viewsLabel = views == null
        ? '... Views'
        : '${_formatNumber(views)} Views';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Text(
            formattedTime,
            style: TextStyle(color: Colors.grey[600], fontSize: 15),
          ),
          const SizedBox(width: 4),
          Text('·', style: TextStyle(color: Colors.grey[600])),
          const SizedBox(width: 4),
          Text(
            viewsLabel,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _replyStats(TweetModel t) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _statItem(_formatStat(t.likes), 'Likes'),
              const SizedBox(width: 16),
              _statItem(_formatStat(t.bookmarks), 'Bookmarks'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statItem(String value, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
        const SizedBox(width: 4),
        Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 15)),
      ],
    );
  }

  Widget _actionButtons(TweetModel t) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _iconButton(
            icon: Icons.chat_bubble_outline,
            color: Colors.grey[600]!,
            onTap: () {},
          ),
          _iconButton(
            icon: Icons.repeat,
            color: t.isRetweeted ? Colors.green : Colors.grey[600]!,
            onTap: () => _toggleRetweet(t.id),
          ),
          _iconButton(
            icon: t.isLiked ? Icons.favorite : Icons.favorite_border,
            color: t.isLiked ? Colors.pink : Colors.grey[600]!,
            onTap: () => _toggleLike(t.id),
          ),
          _iconButton(
            icon: t.isBookmarked ? Icons.bookmark : Icons.bookmark_border,
            color: t.isBookmarked ? Colors.blue : Colors.grey[600]!,
            onTap: () => _toggleBookmark(t.id),
          ),
          _iconButton(
            icon: Icons.ios_share,
            color: Colors.grey[600]!,
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _iconButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Icon(icon, color: color, size: 20),
      ),
    );
  }

  Widget _buildReplyBar() {
    final currentReply = widget.pathTweetIds.isNotEmpty
        ? allTweets[widget.pathTweetIds.last]
        : null;

    return SafeArea(
      child: GestureDetector(
        onTap: currentReply != null
            ? () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        ReplyComposerScreen(replyingToTweet: currentReply),
                  ),
                );

                if (result == true && mounted) {
                  await _loadThreadData();
                }
              }
            : null,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.black,
            border: Border(
              top: BorderSide(color: Colors.grey[900]!, width: 0.5),
            ),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: Colors.blue,
                child: const Icon(Icons.person, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Post your reply',
                  style: TextStyle(color: Colors.grey[600], fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }

  String _formatStat(int number) {
    if (number < 10000) {
      return NumberFormat.decimalPattern().format(number);
    }
    return _formatNumber(number);
  }
}
