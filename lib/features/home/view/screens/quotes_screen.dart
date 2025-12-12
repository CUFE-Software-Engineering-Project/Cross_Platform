import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lite_x/core/providers/current_user_provider.dart';
import 'package:lite_x/features/home/models/tweet_model.dart';
import 'package:lite_x/features/home/repositories/home_repository.dart';
import 'package:lite_x/features/home/view/screens/quote_composer_screen.dart';
import 'package:lite_x/features/home/view/screens/tweet_screen.dart';
import 'package:lite_x/features/home/view/widgets/tweet_widget.dart';
import 'package:lite_x/features/home/view_model/home_view_model.dart';
import 'package:lite_x/features/profile/view/screens/profile_screen.dart';

class QuotesScreen extends ConsumerStatefulWidget {
  final String tweetId;

  const QuotesScreen({super.key, required this.tweetId});

  @override
  ConsumerState<QuotesScreen> createState() => _QuotesScreenState();
}

class _QuotesScreenState extends ConsumerState<QuotesScreen> {
  final ScrollController _scrollController = ScrollController();

  final Map<String, Future<TweetModel?>> _parentTweetFutures = {};

  List<TweetModel> _tweets = [];
  String? _cursor;
  bool _isLoadingInitial = true;
  bool _isLoadingMore = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadInitial();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isLoadingMore || _cursor == null) return;
    if (!_scrollController.hasClients) return;

    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 200) {
      _loadMore();
    }
  }

  Future<void> _loadInitial() async {
    setState(() {
      _isLoadingInitial = true;
      _isLoadingMore = false;
      _error = null;
      _tweets = [];
      _cursor = null;
    });

    try {
      final repo = ref.read(homeRepositoryProvider);
      final result = await repo.getQuotes(widget.tweetId, cursor: null);

      if (!mounted) return;
      setState(() {
        _tweets = result.tweets;
        _cursor = result.nextCursor;
        _isLoadingInitial = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoadingInitial = false;
      });
    }
  }

  Future<void> _loadMore() async {
    final next = _cursor;
    if (next == null || next.isEmpty) return;

    setState(() {
      _isLoadingMore = true;
    });

    try {
      final repo = ref.read(homeRepositoryProvider);
      final result = await repo.getQuotes(widget.tweetId, cursor: next);

      if (!mounted) return;
      setState(() {
        _tweets = [..._tweets, ...result.tweets];
        _cursor = result.nextCursor;
        _isLoadingMore = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoadingMore = false;
      });
    }
  }

  void _openProfile(String username) {
    final normalized = username.startsWith('@')
        ? username.substring(1)
        : username;
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => ProfilePage(username: normalized)),
    );
  }

  Future<TweetModel?> _getParentTweet(String parentId) {
    return _parentTweetFutures.putIfAbsent(parentId, () async {
      try {
        final repo = ref.read(homeRepositoryProvider);
        return await repo.getTweetById(parentId, fetchParent: false);
      } catch (_) {
        return null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = _isLoadingInitial;

    final body = isLoading
        ? const Center(child: CircularProgressIndicator())
        : _error != null
        ? Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Failed to load quotes',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _error!,
                    style: TextStyle(color: Colors.grey[500], fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: _loadInitial,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          )
        : RefreshIndicator(
            onRefresh: _loadInitial,
            child: _tweets.isEmpty
                ? ListView(
                    children: [
                      const SizedBox(height: 80),
                      Center(
                        child: Text(
                          'No quotes yet',
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  )
                : ListView.builder(
                    controller: _scrollController,
                    itemCount: _tweets.length + (_isLoadingMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index >= _tweets.length) {
                        return const Padding(
                          padding: EdgeInsets.all(16),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }

                      final tweet = _tweets[index];
                      final String? currentUserId = ref
                          .watch(currentUserProvider)
                          ?.id;
                      final isOwnTweet =
                          (currentUserId != null &&
                          tweet.userId == currentUserId);

                      final parentId = tweet.quotedTweetId ?? tweet.replyToId;

                      Widget buildTweet(TweetModel? parentTweet) {
                        return TweetWidget(
                          tweetId: tweet.id,
                          userDisplayName: tweet.authorName,
                          username: tweet.authorUsername,
                          avatarUrl: tweet.authorAvatar.isNotEmpty
                              ? tweet.authorAvatar
                              : null,
                          tweetType: tweet.tweetType,
                          timeAgo: TweetWidget.formatTimeAgoShort(
                            tweet.createdAt,
                          ),
                          content: tweet.content,
                          imageUrl: tweet.images.isNotEmpty
                              ? tweet.images.first
                              : null,
                          mediaUrls: tweet.images,
                          retweetedByUsernames: tweet.retweetedByUsernames,
                          onProfileTap: () =>
                              _openProfile(tweet.authorUsername),
                          replyCount: tweet.replies,
                          retweetCount: tweet.retweets,
                          likeCount: tweet.likes,
                          isSaved: tweet.isBookmarked,
                          isLiked: tweet.isLiked,
                          isRetweeted: tweet.isRetweeted,
                          isOwnTweet: isOwnTweet,
                          isVerified: tweet.isVerified,
                          quotedTweet: tweet.quotedTweet ?? parentTweet,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) =>
                                    TweetDetailScreen(tweetId: tweet.id),
                              ),
                            );
                          },
                          onReply: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) =>
                                    TweetDetailScreen(tweetId: tweet.id),
                              ),
                            );
                          },
                          onRetweet: () {
                            ref
                                .read(homeViewModelProvider.notifier)
                                .toggleRetweet(tweet.id);
                          },
                          onQuote: () async {
                            final result = await Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) =>
                                    QuoteComposerScreen(quotedTweet: tweet),
                              ),
                            );
                            if (result == true && context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Quote posted successfully'),
                                  backgroundColor: Colors.green,
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            }
                          },
                          onLike: () {
                            ref
                                .read(homeViewModelProvider.notifier)
                                .toggleLike(tweet.id);
                          },
                          onSave: () {
                            ref
                                .read(homeViewModelProvider.notifier)
                                .toggleBookmark(tweet.id);
                          },
                          onShare: () {},
                          onReach: () {},
                        );
                      }

                      if (tweet.quotedTweet != null || parentId == null) {
                        return buildTweet(null);
                      }

                      return FutureBuilder<TweetModel?>(
                        future: _getParentTweet(parentId),
                        builder: (context, snapshot) {
                          return buildTweet(snapshot.data);
                        },
                      );
                    },
                  ),
          );

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('Quotes'),
      ),
      body: body,
    );
  }
}
