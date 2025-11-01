import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lite_x/core/routes/app_shell.dart';
import 'package:lite_x/features/home/models/tweet_model.dart';
import 'package:lite_x/features/home/view/screens/tweet_screen.dart';
import 'package:lite_x/features/home/view_model/home_state.dart';
import 'package:lite_x/features/home/view_model/home_view_model.dart';
import 'package:lite_x/features/home/view/widgets/home_app_bar.dart';
import 'package:lite_x/features/home/view/widgets/home_tab_bar.dart';
import 'package:lite_x/features/home/view/widgets/tweet_widget.dart';
import 'package:lite_x/features/home/view/screens/create_post_screen.dart';
import 'package:lite_x/features/home/view/screens/quote_composer_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with AutomaticKeepAliveClientMixin {
  late ScrollController _forYouScrollController;
  late ScrollController _followingScrollController;
  double _lastScrollOffset = 0.0;
  String? currentUserId;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _forYouScrollController = ScrollController();
    _followingScrollController = ScrollController();
    _forYouScrollController.addListener(_onScroll);
    _followingScrollController.addListener(_onScroll);
    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    try {
      final repository = ref.read(homeRepositoryProvider);
      final userData = await repository.getCurrentUser();
      if (mounted) {
        setState(() {
          currentUserId = userData['id'];
        });
      }
    } catch (e) {}
  }

  @override
  void dispose() {
    _forYouScrollController.removeListener(_onScroll);
    _followingScrollController.removeListener(_onScroll);
    _forYouScrollController.dispose();
    _followingScrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final selectedTab = ref.read(homeTabProvider);
    final activeController = selectedTab == HomeTab.forYou
        ? _forYouScrollController
        : _followingScrollController;

    if (!activeController.hasClients) return;

    final currentOffset = activeController.offset;
    final isScrollingDown =
        currentOffset > _lastScrollOffset && currentOffset > 50;
    final isScrollingUp = currentOffset < _lastScrollOffset;

    if (isScrollingDown) {
      ref.read(bottomNavVisibilityProvider.notifier).state = false;
    } else if (isScrollingUp || currentOffset <= 50) {
      ref.read(bottomNavVisibilityProvider.notifier).state = true;
    }

    _lastScrollOffset = currentOffset;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final selectedTab = ref.watch(homeTabProvider);
    final homeState = ref.watch(homeViewModelProvider);

    ref.listen<HomeTab>(homeTabProvider, (previous, next) {
      final feedType = next == HomeTab.forYou
          ? FeedType.forYou
          : FeedType.following;
      ref.read(homeViewModelProvider.notifier).switchFeed(feedType);
    });

    List<TweetModel> tweets;
    if (selectedTab == HomeTab.forYou) {
      tweets = homeState.forYouTweets.isNotEmpty
          ? homeState.forYouTweets
          : (homeState.currentFeed == FeedType.forYou ? homeState.tweets : []);
    } else {
      tweets = homeState.followingTweets.isNotEmpty
          ? homeState.followingTweets
          : (homeState.currentFeed == FeedType.following
                ? homeState.tweets
                : []);
    }

    final feedName = selectedTab == HomeTab.forYou ? "For You" : "Following";

    return Scaffold(
      backgroundColor: Colors.black,
      body: RefreshIndicator(
        onRefresh: () =>
            ref.read(homeViewModelProvider.notifier).refreshTweets(),
        backgroundColor: Colors.grey[900],
        color: Colors.white,
        child: CustomScrollView(
          controller: selectedTab == HomeTab.forYou
              ? _forYouScrollController
              : _followingScrollController,
          slivers: [
            SliverAppBar(
              expandedHeight: 120.0,
              floating: true,
              snap: true,
              pinned: false,
              backgroundColor: Colors.black,
              elevation: 0,
              automaticallyImplyLeading: false,
              flexibleSpace: FlexibleSpaceBar(
                background: HomeAppBar(),
                collapseMode: CollapseMode.pin,
              ),
            ),

            _buildSliverTweetList(
              context,
              tweets,
              homeState.isLoading,
              feedName,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CreatePostScreen()),
          );
        },
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
    );
  }

  Widget _buildSliverTweetList(
    BuildContext context,
    List<TweetModel> tweets,
    bool isLoading,
    String feedType,
  ) {
    if (isLoading && tweets.isEmpty) {
      return const SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.only(top: 50.0),
          child: Center(child: CircularProgressIndicator(color: Colors.white)),
        ),
      );
    }

    if (tweets.isEmpty) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.only(top: 50.0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.timeline, size: 64, color: Colors.grey[600]),
                const SizedBox(height: 16),
                Text(
                  'No tweets in $feedType feed',
                  style: TextStyle(color: Colors.grey[400], fontSize: 18),
                ),
                const SizedBox(height: 8),
                Text(
                  'Pull to refresh or check back later.',
                  style: TextStyle(color: Colors.grey[500], fontSize: 14),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        final tweet = tweets[index];

        const String knownUserId = '6552d72c-3f27-445d-8ad8-bc22cda9ddd9';
        final isOwnTweet =
            (currentUserId != null && tweet.userId == currentUserId) ||
            (tweet.userId == knownUserId);

        return TweetWidget(
          tweetId: tweet.id,
          userDisplayName: tweet.authorName,
          username: tweet.authorUsername,
          timeAgo: TweetWidget.formatTimeAgoShort(tweet.createdAt),
          content: tweet.content,
          imageUrl: tweet.images.isNotEmpty ? tweet.images.first : null,
          replyCount: tweet.replies,
          retweetCount: tweet.retweets,
          likeCount: tweet.likes,
          isSaved: tweet.isBookmarked,
          isLiked: tweet.isLiked,
          isRetweeted: tweet.isRetweeted,
          isOwnTweet: isOwnTweet,
          quotedTweet: tweet.quotedTweet,

          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => TweetDetailScreen(tweetId: tweet.id),
              ),
            );
          },
          onReply: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => TweetDetailScreen(tweetId: tweet.id),
              ),
            );
          },
          onRetweet: () {
            ref.read(homeViewModelProvider.notifier).toggleRetweet(tweet.id);
          },
          onQuote: () async {
            final result = await Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => QuoteComposerScreen(quotedTweet: tweet),
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
            ref.read(homeViewModelProvider.notifier).toggleLike(tweet.id);
          },
          onShare: () {},
          onReach: () {},
          onSave: () {
            ref.read(homeViewModelProvider.notifier).toggleBookmark(tweet.id);
          },
          onDelete: isOwnTweet
              ? () async {
                  await ref
                      .read(homeViewModelProvider.notifier)
                      .deletePost(tweet.id);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Post deleted successfully'),
                        backgroundColor: Colors.green,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                }
              : null,
        );
      }, childCount: tweets.length),
    );
  }
}
