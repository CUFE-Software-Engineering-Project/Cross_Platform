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
import 'package:timeago/timeago.dart' as timeago;

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  late PageController _pageController;
  late ScrollController _scrollController;
  double _lastScrollOffset = 0.0;
  bool _isScrollingDown = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final currentOffset = _scrollController.offset;
    final isScrollingDown =
        currentOffset > _lastScrollOffset && currentOffset > 50;

    if (isScrollingDown != _isScrollingDown) {
      setState(() {
        _isScrollingDown = isScrollingDown;
      });
      ref.read(bottomNavVisibilityProvider.notifier).state = !isScrollingDown;
    }
    _lastScrollOffset = currentOffset;
  }

  @override
  Widget build(BuildContext context) {
    final selectedTab = ref.watch(homeTabProvider);
    final homeState = ref.watch(homeViewModelProvider);

    // Listen to tab changes and animate the PageView
    ref.listen<HomeTab>(homeTabProvider, (previous, next) {
      if (_pageController.hasClients) {
        final pageIndex = next == HomeTab.forYou ? 0 : 1;
        _pageController.animateToPage(
          pageIndex,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    });

    return Scaffold(
      backgroundColor: Colors.black,
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          final newTab = index == 0 ? HomeTab.forYou : HomeTab.following;
          if (selectedTab != newTab) {
            ref.read(homeTabProvider.notifier).state = newTab;
          }
        },
        // **REFACTORED:** Use the new, reusable builder for each page
        children: [
          _buildFeedPage(ref, homeState, "For You"),
          _buildFeedPage(ref, homeState, "Following"),
        ],
      ),
    );
  }

  // **NEW REUSABLE METHOD:** Replaces the two duplicated feed methods
  Widget _buildFeedPage(WidgetRef ref, HomeState homeState, String feedType) {
    // In a real app, you might have separate lists in your state,
    // e.g., homeState.forYouTweets and homeState.followingTweets.
    // For now, we use the main list for both feeds.
    final tweets = homeState.tweets;

    return RefreshIndicator(
      onRefresh: () => ref.read(homeViewModelProvider.notifier).refreshTweets(),
      backgroundColor: Colors.grey[900],
      color: Colors.white,
      child: CustomScrollView(
        controller: _scrollController,
        slivers: [
          const SliverAppBar(
            expandedHeight: 120.0,
            floating: true,
            snap: true,
            pinned: false,
            backgroundColor: Colors.black,
            elevation: 0,
            automaticallyImplyLeading: false,
            flexibleSpace: FlexibleSpaceBar(background: HomeAppBar()),
          ),
          // Pass the specific list of tweets to the list builder
          _buildSliverTweetList(context, tweets, homeState.isLoading, feedType),
        ],
      ),
    );
  }

  // **CORRECTED METHOD:** This now correctly uses the state passed into it
  Widget _buildSliverTweetList(
    BuildContext context,
    List<TweetModel> tweets,
    bool isLoading,
    String feedType,
  ) {
    // 1. Handle loading state
    if (isLoading && tweets.isEmpty) {
      return const SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.only(top: 50.0),
          child: Center(child: CircularProgressIndicator(color: Colors.white)),
        ),
      );
    }

    // 2. Handle empty state (after loading is finished)
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

    // 3. Display the list of tweets
    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        final tweet = tweets[index];
        return TweetWidget(
          userDisplayName: tweet.authorName,
          username: tweet.authorUsername,
          timeAgo: timeago.format(tweet.createdAt),
          content: tweet.content,
          imageUrl: tweet.images.isNotEmpty ? tweet.images.first : null,
          replyCount: tweet.replies,
          retweetCount: tweet.retweets,
          likeCount: tweet.likes,

          isSaved: false, // Placeholder for save state

          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => TweetDetailScreen(tweetId: 't1'),
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
          onLike: () {
            ref.read(homeViewModelProvider.notifier).toggleLike(tweet.id);
          },
          onShare: () => print('Share tweet: ${tweet.id}'),
          onSave: () => print('Save tweet: ${tweet.id}'),
          onReach: () => print('View reach analytics for tweet: ${tweet.id}'),
        );
      }, childCount: tweets.length),
    );
  }
}
