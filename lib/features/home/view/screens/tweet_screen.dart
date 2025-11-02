import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lite_x/core/providers/current_user_provider.dart';
import 'package:lite_x/features/home/models/tweet_model.dart';
import 'package:lite_x/features/home/repositories/home_repository.dart';
import 'package:lite_x/features/home/view/screens/reply_composer_screen.dart';
import 'package:lite_x/features/home/view/screens/reply_thread_screen.dart';
import 'package:lite_x/features/home/view/screens/quote_composer_screen.dart';
import 'package:lite_x/features/home/view_model/home_view_model.dart';
import 'package:timeago/timeago.dart' as timeago;

class TweetDetailScreen extends ConsumerStatefulWidget {
  final String tweetId;

  const TweetDetailScreen({super.key, required this.tweetId});

  @override
  ConsumerState<TweetDetailScreen> createState() => _TweetDetailScreenState();
}

class _TweetDetailScreenState extends ConsumerState<TweetDetailScreen> {
  TweetModel? mainTweet;
  List<TweetModel> replies = [];
  bool isLoading = true;
  String? currentUserId;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
    _loadTweetData();
  }

  void _loadCurrentUser() {
    // Get current user from the provider
    final user = ref.read(currentUserProvider);
    if (user != null) {
      currentUserId = user.id;
    }
  }

  Future<void> _loadTweetData() async {
    setState(() {
      isLoading = true;
    });

    try {
      final homeState = ref.read(homeViewModelProvider);
      TweetModel? tweet;

      try {
        tweet = homeState.tweets.firstWhere((t) => t.id == widget.tweetId);
      } catch (e) {
        try {
          tweet = homeState.forYouTweets.firstWhere(
            (t) => t.id == widget.tweetId,
          );
        } catch (e) {
          try {
            tweet = homeState.followingTweets.firstWhere(
              (t) => t.id == widget.tweetId,
            );
          } catch (e) {
            final repository = ref.read(homeRepositoryProvider);
            tweet = await repository.getTweetById(widget.tweetId);
          }
        }
      }

      if (mounted) {
        setState(() {
          mainTweet = tweet;
        });
      }

      await _loadReplies();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load tweet: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> _loadReplies() async {
    if (mainTweet == null) return;

    try {
      final loadedReplies = await ref
          .read(homeViewModelProvider.notifier)
          .getReplies(mainTweet!.id);

      if (mounted) {
        setState(() {
          replies = loadedReplies;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load replies: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _toggleLike() async {
    if (mainTweet == null) return;

    final currentLikeState = mainTweet!.isLiked;
    final newLikeState = !currentLikeState;

    // Optimistically update UI
    setState(() {
      mainTweet!.isLiked = newLikeState;
      mainTweet!.likes += newLikeState ? 1 : -1;
    });

    try {
      final repository = ref.read(homeRepositoryProvider);
      // Pass current state (before toggle) to repository
      await repository.toggleLike(mainTweet!.id, currentLikeState);

      // Keep the optimistic update - don't overwrite with server response
    } catch (e) {
      // Revert on error
      if (mounted) {
        setState(() {
          mainTweet!.isLiked = currentLikeState;
          mainTweet!.likes += currentLikeState ? 1 : -1;
        });
      }
    }
  }

  Future<void> _toggleRetweet() async {
    if (mainTweet == null) return;

    final currentRetweetState = mainTweet!.isRetweeted;
    final newRetweetState = !currentRetweetState;

    // Optimistically update UI
    setState(() {
      mainTweet!.isRetweeted = newRetweetState;
      mainTweet!.retweets += newRetweetState ? 1 : -1;
    });

    try {
      final repository = ref.read(homeRepositoryProvider);
      // Pass current state (before toggle) to repository
      await repository.toggleRetweet(mainTweet!.id, currentRetweetState);

      // Keep the optimistic update
    } catch (e) {
      // Revert on error
      if (mounted) {
        setState(() {
          mainTweet!.isRetweeted = currentRetweetState;
          mainTweet!.retweets += currentRetweetState ? 1 : -1;
        });
      }
    }
  }

  Future<void> _toggleBookmark() async {
    if (mainTweet == null) return;

    final currentBookmarkState = mainTweet!.isBookmarked;
    final newBookmarkState = !currentBookmarkState;

    // Optimistically update UI
    setState(() {
      mainTweet!.isBookmarked = newBookmarkState;
    });

    try {
      final repository = ref.read(homeRepositoryProvider);
      // Pass current state (before toggle) to repository
      await repository.toggleBookmark(mainTweet!.id, currentBookmarkState);

      // Keep the optimistic update
    } catch (e) {
      // Revert on error
      if (mounted) {
        setState(() {
          mainTweet!.isBookmarked = currentBookmarkState;
        });
      }
    }
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
                  mainTweet!.isRetweeted ? Icons.repeat : Icons.repeat,
                  color: mainTweet!.isRetweeted
                      ? Colors.green
                      : Colors.grey[300],
                ),
                title: Text(
                  mainTweet!.isRetweeted ? 'Undo Repost' : 'Repost',
                  style: TextStyle(
                    color: mainTweet!.isRetweeted
                        ? Colors.green
                        : Colors.grey[300],
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
                title: Text(
                  'Quote',
                  style: TextStyle(color: Colors.grey[300], fontSize: 16),
                ),
                onTap: () {
                  Navigator.pop(modalContext);
                  _navigateToQuoteComposer();
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Future<void> _navigateToQuoteComposer() async {
    if (mainTweet == null) return;

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QuoteComposerScreen(quotedTweet: mainTweet!),
      ),
    );

    if (result == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Quote posted to your timeline'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF1DA1F2)),
        ),
      );
    }

    if (mainTweet == null) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Tweet not found!',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1DA1F2),
                ),
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: _buildAppBar(),
      body: ListView(
        children: [
          _buildMainTweet(),
          if (replies.isNotEmpty) ...[
            Container(
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
            ...replies.map((reply) => _buildReplyCard(reply)),
          ],
        ],
      ),
      bottomNavigationBar: _buildReplyBar(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
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
    );
  }

  Widget _buildMainTweet() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildUserInfo(),
          const SizedBox(height: 12),
          _buildTweetContent(),
          const SizedBox(height: 16),
          _buildTimestamp(),
          const Divider(color: Color(0xFF2F3336), height: 1),
          _buildEngagementStats(),
          const Divider(color: Color(0xFF2F3336), height: 1),
          _buildActionButtons(),
          const Divider(color: Color(0xFF2F3336), height: 1),
        ],
      ),
    );
  }

  Widget _buildUserInfo() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 24,
          backgroundImage: NetworkImage(mainTweet!.authorAvatar),
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
                      mainTweet!.authorName,
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
                mainTweet!.authorUsername,
                style: TextStyle(color: Colors.grey[600], fontSize: 15),
              ),
            ],
          ),
        ),
        _buildActionButton(),
      ],
    );
  }

  Widget _buildActionButton() {
    const String knownUserId = '6552d72c-3f27-445d-8ad8-bc22cda9ddd9';

    final bool isOwnTweet =
        (currentUserId != null &&
            mainTweet!.userId != null &&
            currentUserId == mainTweet!.userId) ||
        (mainTweet!.userId != null && mainTweet!.userId == knownUserId);

    if (isOwnTweet) {
      return PopupMenuButton<String>(
        icon: const Icon(Icons.more_horiz, color: Colors.white),
        color: const Color(0xFF1E1E1E),
        onSelected: (value) {
          if (value == 'edit') {
            _showEditDialog();
          } else if (value == 'delete') {
            _showDeleteDialog();
          }
        },
        itemBuilder: (context) => [
          const PopupMenuItem(
            value: 'edit',
            child: Row(
              children: [
                Icon(Icons.edit, color: Colors.white, size: 20),
                SizedBox(width: 12),
                Text('Edit', style: TextStyle(color: Colors.white)),
              ],
            ),
          ),
          const PopupMenuItem(
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
      return Container(
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
      );
    }
  }

  void _showEditDialog() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Edit functionality coming soon!'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text(
          'Delete Tweet?',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'This can\'t be undone and it will be removed from your profile, the timeline of any accounts that follow you, and from search results.',
          style: TextStyle(color: Colors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.white)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _deleteTweet();
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteTweet() async {
    try {
      final repository = ref.read(homeRepositoryProvider);
      await repository.deletePost(mainTweet!.id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tweet deleted successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete tweet: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showDeleteReplyDialog(TweetModel reply) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text(
          'Delete Reply?',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'This can\'t be undone and it will be removed from this conversation.',
          style: TextStyle(color: Colors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel', style: TextStyle(color: Colors.white)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              await _deleteReply(reply);
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteReply(TweetModel reply) async {
    try {
      final repository = ref.read(homeRepositoryProvider);
      await repository.deletePost(reply.id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Reply deleted successfully!'),
            backgroundColor: Colors.green,
          ),
        );

        await _loadReplies();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete reply: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildTweetContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          mainTweet!.content,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            height: 1.4,
          ),
        ),

        if (mainTweet!.quotedTweet != null) ...[
          const SizedBox(height: 16),
          _buildQuotedTweet(mainTweet!.quotedTweet!),
        ],
        if (mainTweet!.images.isNotEmpty) ...[
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.network(
              mainTweet!.images.first,
              width: double.infinity,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  height: 200,
                  color: Colors.grey[900],
                  child: const Center(
                    child: CircularProgressIndicator(color: Colors.blue),
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 200,
                  color: Colors.grey[900],
                  child: const Center(
                    child: Icon(
                      Icons.broken_image,
                      color: Colors.grey,
                      size: 48,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildQuotedTweet(TweetModel quotedTweet) {
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
                radius: 14,
                backgroundImage: NetworkImage(quotedTweet.authorAvatar),
                backgroundColor: Colors.grey[800],
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Row(
                  children: [
                    Flexible(
                      child: Text(
                        quotedTweet.authorName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        '@${quotedTweet.authorUsername}',
                        style: TextStyle(color: Colors.grey[500], fontSize: 15),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '· ${timeago.format(quotedTweet.createdAt, locale: 'en_short')}',
                      style: TextStyle(color: Colors.grey[500], fontSize: 15),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          Text(
            quotedTweet.content,
            style: TextStyle(color: Colors.grey[300], fontSize: 15),
          ),

          if (quotedTweet.images.isNotEmpty) ...[
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                quotedTweet.images.first,
                height: 150,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 150,
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

  Widget _buildTimestamp() {
    final formattedTime = DateFormat(
      'h:mm a · d MMM yy',
    ).format(mainTweet!.createdAt);
    final views = 0; // TODO: Get views from backend when available

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
            '${_formatNumber(views)} Views',
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

  Widget _buildEngagementStats() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _buildStatItem(_formatStat(mainTweet!.retweets), 'Reposts'),
              const SizedBox(width: 16),
              _buildStatItem(_formatStat(mainTweet!.quotes), 'Quotes'),
              const SizedBox(width: 16),
              _buildStatItem(_formatStat(mainTweet!.likes), 'Likes'),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              _buildStatItem(_formatStat(mainTweet!.bookmarks), 'Bookmarks'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label) {
    return GestureDetector(
      onTap: () {},
      child: Row(
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
      ),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildIconButton(
            icon: Icons.chat_bubble_outline,
            color: Colors.grey[600]!,
            onTap: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      ReplyComposerScreen(replyingToTweet: mainTweet!),
                ),
              );

              if (result == true && mounted) {
                await _loadReplies();

                await _loadTweetData();
              }
            },
          ),
          _buildIconButton(
            icon: mainTweet!.isRetweeted ? Icons.repeat : Icons.repeat,
            color: mainTweet!.isRetweeted ? Colors.green : Colors.grey[600]!,
            onTap: () => _showRetweetMenu(context),
          ),
          _buildIconButton(
            icon: mainTweet!.isLiked ? Icons.favorite : Icons.favorite_border,
            color: mainTweet!.isLiked ? Colors.pink : Colors.grey[600]!,
            onTap: _toggleLike,
          ),
          _buildIconButton(
            icon: mainTweet!.isBookmarked
                ? Icons.bookmark
                : Icons.bookmark_border,
            color: mainTweet!.isBookmarked ? Colors.blue : Colors.grey[600]!,
            onTap: _toggleBookmark,
          ),
          _buildIconButton(
            icon: Icons.ios_share,
            color: Colors.grey[600]!,
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildIconButton({
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

  Widget _buildReplyCard(TweetModel reply) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                ReplyThreadScreen(pathTweetIds: [mainTweet!.id, reply.id]),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Colors.grey[900]!, width: 0.5),
          ),
        ),
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
                  _buildReplyHeader(reply),
                  const SizedBox(height: 4),
                  _buildReplyingTo(),
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
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        reply.images.first,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  _buildReplyActions(reply),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReplyHeader(TweetModel reply) {
    const String knownUserId = '6552d72c-3f27-445d-8ad8-bc22cda9ddd9';
    final bool isOwnReply =
        (currentUserId != null &&
            reply.userId != null &&
            currentUserId == reply.userId) ||
        (reply.userId != null && reply.userId == knownUserId);

    return Row(
      children: [
        Expanded(
          child: Row(
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
        ),

        if (isOwnReply)
          PopupMenuButton<String>(
            icon: Icon(Icons.more_horiz, color: Colors.grey[600], size: 18),
            color: const Color(0xFF1E1E1E),
            onSelected: (value) {
              if (value == 'delete') {
                _showDeleteReplyDialog(reply);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
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
          )
        else
          Icon(Icons.more_horiz, color: Colors.grey[600], size: 18),
      ],
    );
  }

  Widget _buildReplyingTo() {
    return Row(
      children: [
        Text(
          'Replying to ',
          style: TextStyle(color: Colors.grey[600], fontSize: 15),
        ),
        Text(
          mainTweet!.authorUsername,
          style: const TextStyle(color: Colors.blue, fontSize: 15),
        ),
      ],
    );
  }

  Widget _buildReplyActions(TweetModel reply) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        InkWell(
          onTap: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    ReplyComposerScreen(replyingToTweet: reply),
              ),
            );

            if (result == true && mounted) {
              await _loadReplies();
              await _loadTweetData();
            }
          },
          child: _buildReplyActionButton(
            Icons.chat_bubble_outline,
            reply.replies > 0 ? reply.replies.toString() : '',
          ),
        ),
        _buildReplyActionButton(
          Icons.repeat,
          reply.retweets > 0 ? _formatNumber(reply.retweets) : '',
        ),
        _buildReplyActionButton(
          reply.isLiked ? Icons.favorite : Icons.favorite_border,
          reply.likes > 0 ? _formatNumber(reply.likes) : '',
          color: reply.isLiked ? Colors.pink : null,
        ),
        _buildReplyActionButton(Icons.bar_chart_outlined, ''),
        _buildReplyActionButton(Icons.ios_share, ''),
      ],
    );
  }

  Widget _buildReplyActionButton(IconData icon, String count, {Color? color}) {
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

  Widget _buildReplyBar() {
    return SafeArea(
      child: GestureDetector(
        onTap: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  ReplyComposerScreen(replyingToTweet: mainTweet!),
            ),
          );

          if (result == true && mounted) {
            await _loadReplies();

            await _loadTweetData();
          }
        },
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
