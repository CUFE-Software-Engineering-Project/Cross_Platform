import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:lite_x/core/providers/current_user_provider.dart';
import 'package:lite_x/features/home/models/tweet_model.dart';
import 'package:lite_x/features/home/repositories/home_repository.dart';
import 'package:lite_x/features/home/view/screens/reply_composer_screen.dart';
import 'package:lite_x/features/home/view/screens/reply_thread_screen.dart';
import 'package:lite_x/features/home/view/screens/quote_composer_screen.dart';
import 'package:lite_x/features/home/view/widgets/media_gallery.dart';
import 'package:lite_x/features/home/view/widgets/tweet_summary_dialog.dart';
import 'package:lite_x/features/profile/view/screens/profile_screen.dart';
import 'package:lite_x/features/profile/view_model/providers.dart';
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
  int? _viewCount;
  bool isFollowing = false;
  bool isFollowLoading = false;

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

  void _openProfileFromUsername(String username) {
    final normalized = _normalizeUsername(username);
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => ProfilePage(username: normalized)),
    );
  }

  String _normalizeUsername(String username) {
    if (username.isEmpty) return username;
    return username.startsWith('@') ? username.substring(1) : username;
  }

  Future<void> _toggleFollow() async {
    if (mainTweet == null || isFollowLoading) return;

    setState(() {
      isFollowLoading = true;
    });

    try {
      final username = mainTweet!.authorUsername;

      if (isFollowing) {
        final unfollowFunc = ref.read(unFollowControllerProvider);
        final result = await unfollowFunc(username);
        result.fold(
          (failure) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Failed to unfollow: ${failure.message}'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          (_) {
            if (mounted) {
              setState(() {
                isFollowing = false;
              });
            }
          },
        );
      } else {
        final followFunc = ref.read(followControllerProvider);
        final result = await followFunc(username);
        result.fold(
          (failure) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Failed to follow: ${failure.message}'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          (_) {
            if (mounted) {
              setState(() {
                isFollowing = true;
              });
            }
          },
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isFollowLoading = false;
        });
      }
    }
  }

  Future<void> _loadTweetData() async {
    final cachedTweet = _findCachedTweet(widget.tweetId);

    if (mounted) {
      setState(() {
        mainTweet = cachedTweet;
        replies = [];
        isLoading = cachedTweet == null;
        _viewCount = null;
      });
    }

    try {
      final repository = ref.read(homeRepositoryProvider);
      final fetchedTweet = await repository.getTweetById(widget.tweetId);

      ref
          .read(homeViewModelProvider.notifier)
          .syncTweetFromServer(fetchedTweet);

      if (mounted) {
        setState(() {
          mainTweet = fetchedTweet;
        });
      }

      _loadTweetSummary(fetchedTweet.id);
      await _loadRepliesForTweet(fetchedTweet.id);
    } catch (e) {
      if (mounted && cachedTweet == null) {
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

  TweetModel? _findCachedTweet(String tweetId) {
    final homeState = ref.read(homeViewModelProvider);
    final sources = [
      homeState.tweets,
      homeState.forYouTweets,
      homeState.followingTweets,
    ];

    for (final list in sources) {
      try {
        return list.firstWhere((tweet) => tweet.id == tweetId);
      } catch (_) {
        continue;
      }
    }

    return null;
  }

  Future<void> _loadTweetSummary(String tweetId) async {
    try {
      final summary = await ref
          .read(homeRepositoryProvider)
          .getTweetSummary(tweetId);
      if (mounted) {
        setState(() {
          _viewCount = summary.views;
        });
      }
    } catch (e) {
      if (mounted && _viewCount == null) {
        setState(() {
          _viewCount = 0;
        });
      }
    }
  }

  Future<void> _loadRepliesForTweet(String tweetId) async {
    try {
      final loadedReplies = await ref
          .read(homeViewModelProvider.notifier)
          .getReplies(tweetId);

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

    final optimisticLikes = mainTweet!.likes;

    try {
      final repository = ref.read(homeRepositoryProvider);
      final updatedTweet = await repository.toggleLike(
        mainTweet!.id,
        currentLikeState,
      );

      final normalizedTweet = updatedTweet.copyWith(
        isLiked: newLikeState,
        likes: optimisticLikes,
      );

      ref
          .read(homeViewModelProvider.notifier)
          .syncTweetFromServer(normalizedTweet);

      if (mounted) {
        setState(() {
          mainTweet = normalizedTweet;
        });
      }
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

    final optimisticRetweets = mainTweet!.retweets;

    try {
      final repository = ref.read(homeRepositoryProvider);
      final updatedTweet = await repository.toggleRetweet(
        mainTweet!.id,
        currentRetweetState,
      );

      final normalizedTweet = updatedTweet.copyWith(
        isRetweeted: newRetweetState,
        retweets: optimisticRetweets,
      );

      ref
          .read(homeViewModelProvider.notifier)
          .syncTweetFromServer(normalizedTweet);

      if (mounted) {
        setState(() {
          mainTweet = normalizedTweet;
        });
      }
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

    final optimisticBookmarkState = mainTweet!.isBookmarked;

    try {
      final repository = ref.read(homeRepositoryProvider);
      final updatedTweet = await repository.toggleBookmark(
        mainTweet!.id,
        currentBookmarkState,
      );

      final normalizedTweet = updatedTweet.copyWith(
        isBookmarked: optimisticBookmarkState,
      );

      ref
          .read(homeViewModelProvider.notifier)
          .syncTweetFromServer(normalizedTweet);

      if (mounted) {
        setState(() {
          mainTweet = normalizedTweet;
        });
      }
    } catch (e) {
      // Revert on error
      if (mounted) {
        setState(() {
          mainTweet!.isBookmarked = currentBookmarkState;
        });
      }
    }
  }

  Future<void> _showSummaryDialog() async {
    if (mainTweet == null) return;

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFF1DA1F2).withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1DA1F2)),
              ),
              const SizedBox(height: 16),
              Text(
                'Generating AI insights...',
                style: TextStyle(color: Colors.grey[400], fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );

    try {
      final repository = ref.read(homeRepositoryProvider);
      final summary = await repository.getTweetSummary(mainTweet!.id);

      if (mounted) {
        // Close loading dialog
        Navigator.of(context).pop();

        // Show summary dialog
        showDialog(
          context: context,
          builder: (context) => TweetSummaryDialog(summary: summary),
        );
      }
    } catch (e) {
      if (mounted) {
        // Close loading dialog
        Navigator.of(context).pop();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load summary: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _toggleReplyLike(TweetModel reply) async {
    final currentLikeState = reply.isLiked;
    final newLikeState = !currentLikeState;

    // Optimistic UI update
    setState(() {
      final replyIndex = replies.indexWhere((r) => r.id == reply.id);
      if (replyIndex != -1) {
        replies[replyIndex].isLiked = newLikeState;
        replies[replyIndex].likes += newLikeState ? 1 : -1;
      }
    });

    try {
      final repository = ref.read(homeRepositoryProvider);
      await repository.toggleLike(reply.id, currentLikeState);

      // Sync with home view model
      final updatedReply = reply.copyWith(
        isLiked: newLikeState,
        likes: reply.likes + (newLikeState ? 1 : -1),
      );
      ref
          .read(homeViewModelProvider.notifier)
          .syncTweetFromServer(updatedReply);
    } catch (e) {
      // Revert on error
      if (mounted) {
        setState(() {
          final replyIndex = replies.indexWhere((r) => r.id == reply.id);
          if (replyIndex != -1) {
            replies[replyIndex].isLiked = currentLikeState;
            replies[replyIndex].likes += currentLikeState ? 1 : -1;
          }
        });
      }
    }
  }

  Future<void> _toggleReplyRetweet(TweetModel reply) async {
    final currentRetweetState = reply.isRetweeted;
    final newRetweetState = !currentRetweetState;

    // Optimistic UI update
    setState(() {
      final replyIndex = replies.indexWhere((r) => r.id == reply.id);
      if (replyIndex != -1) {
        replies[replyIndex].isRetweeted = newRetweetState;
        replies[replyIndex].retweets += newRetweetState ? 1 : -1;
      }
    });

    try {
      final repository = ref.read(homeRepositoryProvider);
      await repository.toggleRetweet(reply.id, currentRetweetState);

      // Sync with home view model
      final updatedReply = reply.copyWith(
        isRetweeted: newRetweetState,
        retweets: reply.retweets + (newRetweetState ? 1 : -1),
      );
      ref
          .read(homeViewModelProvider.notifier)
          .syncTweetFromServer(updatedReply);
    } catch (e) {
      // Revert on error
      if (mounted) {
        setState(() {
          final replyIndex = replies.indexWhere((r) => r.id == reply.id);
          if (replyIndex != -1) {
            replies[replyIndex].isRetweeted = currentRetweetState;
            replies[replyIndex].retweets += currentRetweetState ? 1 : -1;
          }
        });
      }
    }
  }

  void _showRetweetMenuForReply(BuildContext context, TweetModel reply) {
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
              ListTile(
                leading: Icon(
                  reply.isRetweeted ? Icons.close : Icons.repeat,
                  color: Colors.white,
                ),
                title: Text(
                  reply.isRetweeted ? 'Undo Retweet' : 'Retweet',
                  style: const TextStyle(color: Colors.white),
                ),
                onTap: () {
                  Navigator.pop(modalContext);
                  _toggleReplyRetweet(reply);
                },
              ),
              ListTile(
                leading: const Icon(Icons.edit, color: Colors.white),
                title: const Text(
                  'Quote',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () async {
                  Navigator.pop(modalContext);
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          QuoteComposerScreen(quotedTweet: reply),
                    ),
                  );

                  if (result == true && mounted) {
                    await _loadTweetData();
                  }
                },
              ),
            ],
          ),
        );
      },
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

    if (result == true && mounted && mainTweet != null) {
      ref
          .read(homeViewModelProvider.notifier)
          .incrementQuoteCount(mainTweet!.id);

      setState(() {
        mainTweet = mainTweet!.copyWith(quotes: mainTweet!.quotes + 1);
      });

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
      body: RefreshIndicator(
        onRefresh: _loadTweetData,
        color: const Color(0xFF1DA1F2),
        backgroundColor: Colors.grey[900],
        child: ListView(
          children: [
            _buildMainTweet(),
            if (replies.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
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
    final profileTap = () =>
        _openProfileFromUsername(mainTweet!.authorUsername);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: profileTap,
          behavior: HitTestBehavior.opaque,
          child: CircleAvatar(
            radius: 24,
            backgroundImage: mainTweet!.authorAvatar.isNotEmpty
                ? NetworkImage(mainTweet!.authorAvatar)
                : null,
            backgroundColor: Colors.grey[800],
            child: mainTweet!.authorAvatar.isEmpty
                ? const Icon(Icons.person, color: Colors.white)
                : null,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: GestureDetector(
            onTap: profileTap,
            behavior: HitTestBehavior.opaque,
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
                  '@${mainTweet!.authorUsername}',
                  style: TextStyle(color: Colors.grey[600], fontSize: 15),
                ),
              ],
            ),
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
      return GestureDetector(
        key:const Key('followUnfollowButton_tweet_screen'),
        onTap: isFollowLoading ? null : _toggleFollow,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: isFollowing ? Colors.transparent : Colors.white,
            border: isFollowing
                ? Border.all(color: Colors.grey[700]!, width: 1)
                : null,
            borderRadius: BorderRadius.circular(20),
          ),
          child: isFollowLoading
              ? const SizedBox(
                  width: 60,
                  height: 20,
                  child: Center(
                    child: SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
                      ),
                    ),
                  ),
                )
              : Text(
                  isFollowing ? 'Following' : 'Follow',
                  style: TextStyle(
                    color: isFollowing ? Colors.white : Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
        ),
      );
    }
  }

  void _showEditDialog() {
    final TextEditingController controller = TextEditingController(
      text: mainTweet!.content,
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text(
          'Edit Tweet',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: TextField(
          controller: controller,
          maxLines: null,
          maxLength: 280,
          autofocus: true,
          style: const TextStyle(color: Colors.white, fontSize: 16),
          decoration: InputDecoration(
            hintText: 'What\'s happening?',
            hintStyle: TextStyle(color: Colors.grey[600]),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[800]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[800]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF1DA1F2)),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () async {
              final newContent = controller.text.trim();
              if (newContent.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Tweet cannot be empty'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              Navigator.pop(context);
              await _updateTweet(newContent);
            },
            child: const Text(
              'Save',
              style: TextStyle(
                color: Color(0xFF1DA1F2),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _updateTweet(String newContent) async {
    if (mainTweet == null) return;

    bool updateSuccessful = false;
    TweetModel? updatedTweet;

    try {
      final repository = ref.read(homeRepositoryProvider);
      updatedTweet = await repository.updateTweet(mainTweet!.id, {
        'content': newContent,
      });
      updateSuccessful = true;
    } catch (e) {
      // Check if the error is a harmless one (update succeeded but parsing failed)
      final errorMessage = e.toString().toLowerCase();
      final isHarmlessError =
          errorMessage.contains('duplicate') ||
          errorMessage.contains('already') ||
          errorMessage.contains('exists') ||
          errorMessage.contains('is not a subtype of type') ||
          errorMessage.contains('type \'string\' is not a subtype') ||
          errorMessage.contains('type \'int\' is not a subtype') ||
          errorMessage.contains('failed to parse');

      if (isHarmlessError) {
        // Treat as success - the tweet was updated on the server
        updateSuccessful = true;
      } else {
        // Real error - show it
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to update tweet: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }
    }

    // If update was successful (either directly or despite parsing errors)
    if (updateSuccessful && mounted) {
      // Update local state immediately with new content
      setState(() {
        if (updatedTweet != null) {
          mainTweet = updatedTweet;
        } else {
          // If we don't have the parsed tweet, update the content locally
          mainTweet = mainTweet?.copyWith(content: newContent);
        }
      });

      // Sync with view model if we have the updated tweet
      if (updatedTweet != null) {
        ref
            .read(homeViewModelProvider.notifier)
            .syncTweetFromServer(updatedTweet);
      }

      // Reload the entire tweet screen to fetch fresh data from server
      await _loadTweetData();

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tweet updated successfully'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    }
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

        if (mainTweet != null) {
          await _loadRepliesForTweet(mainTweet!.id);
        }
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
          textDirection: _textDirectionFor(mainTweet!.content),
        ),

        if (mainTweet!.images.isNotEmpty) ...[
          const SizedBox(height: 16),
          MediaGallery(urls: mainTweet!.images, borderRadius: 16),
        ],
        if (mainTweet!.quotedTweet != null) ...[
          const SizedBox(height: 16),
          _buildQuotedTweet(mainTweet!.quotedTweet!),
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
                backgroundImage: quotedTweet.authorAvatar.isNotEmpty
                    ? NetworkImage(quotedTweet.authorAvatar)
                    : null,
                backgroundColor: Colors.grey[800],
                child: quotedTweet.authorAvatar.isEmpty
                    ? const Icon(Icons.person, color: Colors.white, size: 16)
                    : null,
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
            textDirection: _textDirectionFor(quotedTweet.content),
          ),

          if (quotedTweet.images.isNotEmpty) ...[
            const SizedBox(height: 8),
            MediaGallery(
              urls: quotedTweet.images,
              borderRadius: 8,
              minHeight: 120,
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
    final viewsCount = _viewCount ?? 0;
    final viewsLabel = '${_formatNumber(viewsCount)} Views';

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
                await _loadRepliesForTweet(mainTweet!.id);

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
          _buildSvgIconButton(
            svgPath: 'assets/svg/grok.svg',
            color: const Color(0xFF1DA1F2),
            onTap: _showSummaryDialog,
          ),
          _buildIconButton(
            icon: mainTweet!.isBookmarked
                ? Icons.bookmark
                : Icons.bookmark_border,
            color: mainTweet!.isBookmarked ? Colors.blue : Colors.grey[600]!,
            onTap: _toggleBookmark,
          ),
          _buildIconButton(
            icon: Icons.share_outlined,
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

  Widget _buildSvgIconButton({
    required String svgPath,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: SvgPicture.asset(
          svgPath,
          width: 20,
          height: 20,
          colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
        ),
      ),
    );
  }

  Widget _buildReplyCard(TweetModel reply) {
    final profileTap = () => _openProfileFromUsername(reply.authorUsername);
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
            GestureDetector(
              onTap: profileTap,
              behavior: HitTestBehavior.opaque,
              child: CircleAvatar(
                radius: 20,
                backgroundImage: reply.authorAvatar.isNotEmpty
                    ? NetworkImage(reply.authorAvatar)
                    : null,
                backgroundColor: Colors.grey[800],
                child: reply.authorAvatar.isEmpty
                    ? const Icon(Icons.person, color: Colors.white)
                    : null,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildReplyHeader(reply, onTap: profileTap),
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
                    textDirection: _textDirectionFor(reply.content),
                  ),
                  if (reply.images.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    MediaGallery(urls: reply.images, borderRadius: 12),
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

  Widget _buildReplyHeader(TweetModel reply, {VoidCallback? onTap}) {
    const String knownUserId = '6552d72c-3f27-445d-8ad8-bc22cda9ddd9';
    final bool isOwnReply =
        (currentUserId != null &&
            reply.userId != null &&
            currentUserId == reply.userId) ||
        (reply.userId != null && reply.userId == knownUserId);

    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: onTap,
            behavior: HitTestBehavior.opaque,
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
                Flexible(
                  child: Text(
                    '@${reply.authorUsername}',
                    style: TextStyle(color: Colors.grey[600], fontSize: 15),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 4),
                Flexible(
                  fit: FlexFit.loose,
                  child: Text(
                    '· ${timeago.format(reply.createdAt, locale: 'en_short')}',
                    style: TextStyle(color: Colors.grey[600], fontSize: 15),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
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
        Flexible(
          child: GestureDetector(
            onTap: () => _openProfileFromUsername(mainTweet!.authorUsername),
            child: Text(
              '@${mainTweet!.authorUsername}',
              style: const TextStyle(color: Colors.blue, fontSize: 15),
              overflow: TextOverflow.ellipsis,
            ),
          ),
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
              await _loadRepliesForTweet(mainTweet!.id);
              await _loadTweetData();
            }
          },
          child: _buildReplyActionButton(
            Icons.chat_bubble_outline,
            reply.replies > 0 ? reply.replies.toString() : '',
          ),
        ),
        InkWell(
          onTap: () => _showRetweetMenuForReply(context, reply),
          child: _buildReplyActionButton(
            Icons.repeat,
            reply.retweets > 0 ? _formatNumber(reply.retweets) : '',
            color: reply.isRetweeted ? Colors.green : null,
          ),
        ),
        InkWell(
          onTap: () => _toggleReplyLike(reply),
          child: _buildReplyActionButton(
            reply.isLiked ? Icons.favorite : Icons.favorite_border,
            reply.likes > 0 ? _formatNumber(reply.likes) : '',
            color: reply.isLiked ? Colors.pink : null,
          ),
        ),
        _buildReplyActionButton(Icons.bar_chart_outlined, ''),
        _buildReplyActionButton(Icons.share_outlined, ''),
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
            await _loadRepliesForTweet(mainTweet!.id);

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

  ui.TextDirection _textDirectionFor(String text) {
    return _isArabicText(text) ? ui.TextDirection.rtl : ui.TextDirection.ltr;
  }

  bool _isArabicText(String text) {
    return RegExp(r'[\u0600-\u06FF]').hasMatch(text);
  }
}
