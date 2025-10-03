// lib/features/home/view/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:lite_x/core/routes/app_shell.dart';
import 'package:lite_x/features/home/repositories/home_repository.dart';
import 'package:lite_x/features/home/view/widgets/home_app_bar.dart';
import 'package:lite_x/features/home/view/widgets/home_tab_bar.dart';
import 'package:lite_x/features/home/view/widgets/tweet_widget.dart';
import 'package:lite_x/features/home/view_model/home_view_model.dart';
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
      // Update bottom navigation visibility
      ref.read(bottomNavVisibilityProvider.notifier).state = !isScrollingDown;
    }
    _lastScrollOffset = currentOffset;
  }

  @override
  Widget build(BuildContext context) {
    final selectedTab = ref.watch(homeTabProvider);
    final homeState = ref.watch(homeViewModelProvider);

    // Debug: Create a test repository to check if sample tweets work
    final testRepo = HomeRepository();
    final testTweets = testRepo.getSampleTweets();
    print('Test tweets count: ${testTweets.length}');
    if (testTweets.isNotEmpty) {
      print('First tweet: ${testTweets.first.content}');
    }

    // Listen to tab changes and animate to the correct page
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
          // Update tab state when user swipes between pages
          final newTab = index == 0 ? HomeTab.forYou : HomeTab.following;
          if (selectedTab != newTab) {
            ref.read(homeTabProvider.notifier).state = newTab;
          }
        },
        children: [
          _buildForYouFeedWithSliverAppBar(homeState, ref),
          _buildFollowingFeedWithSliverAppBar(homeState, ref),
        ],
      ),
    );
  }

  Widget _buildForYouFeedWithSliverAppBar(homeState, WidgetRef ref) {
    return RefreshIndicator(
      onRefresh: () => ref.read(homeViewModelProvider.notifier).refreshTweets(),
      backgroundColor: Colors.grey[900],
      color: Colors.white,
      child: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverAppBar(
            expandedHeight: 120.0, // Height for app bar + tab bar
            floating: true, // App bar will show when scrolling up
            snap: true, // App bar will snap to visible/hidden states
            pinned: false, // App bar will completely hide when scrolling down
            backgroundColor: Colors.black,
            elevation: 0,
            automaticallyImplyLeading: false,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                color: Colors.black,
                child: const HomeAppBar(),
              ),
            ),
          ),
          _buildSliverTweetList(homeState, 'For You'),
        ],
      ),
    );
  }

  Widget _buildFollowingFeedWithSliverAppBar(homeState, WidgetRef ref) {
    return RefreshIndicator(
      onRefresh: () => ref.read(homeViewModelProvider.notifier).refreshTweets(),
      backgroundColor: Colors.grey[900],
      color: Colors.white,
      child: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverAppBar(
            expandedHeight: 120.0, // Height for app bar + tab bar
            floating: true, // App bar will show when scrolling up
            snap: true, // App bar will snap to visible/hidden states
            pinned: false, // App bar will completely hide when scrolling down
            backgroundColor: Colors.black,
            elevation: 0,
            automaticallyImplyLeading: false,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                color: Colors.black,
                child: const HomeAppBar(),
              ),
            ),
          ),
          _buildSliverTweetList(homeState, 'Following'),
        ],
      ),
    );
  }

  Widget _buildSliverTweetList(homeState, String feedType) {
    print(
      'Building tweet list for $feedType - tweets count: ${homeState.tweets.length}',
    );
    print('Loading state: ${homeState.isLoading}');
    print('Error: ${homeState.error}');

    // Force display of sample tweets for demo
    final testRepo = HomeRepository();
    final staticTweets = testRepo.getSampleTweets();

    if (staticTweets.isNotEmpty) {
      print('Displaying ${staticTweets.length} static sample tweets');
      return SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
          final tweet = staticTweets[index];
          return TweetWidget(
            userDisplayName: tweet.authorName,
            username: tweet.authorUsername,
            timeAgo: timeago.format(tweet.createdAt),
            content: tweet.content,
            imageUrl: tweet.images.isNotEmpty ? tweet.images.first : null,
            replyCount: tweet.replies,
            retweetCount: tweet.retweets,
            likeCount: tweet.likes,
            shareCount: 0,
            reachCount: (tweet.likes * 2.5)
                .round(), // Estimated reach based on likes
            isSaved: false, // Default to not saved
            onReply: () {
              print('Reply to tweet: ${tweet.id}');
            },
            onRetweet: () {
              print('Retweet: ${tweet.id}');
            },
            onLike: () {
              print('Like: ${tweet.id}');
            },
            onShare: () {
              print('Share tweet: ${tweet.id}');
            },
            onSave: () {
              print('Save tweet: ${tweet.id}');
            },
            onReach: () {
              print('View reach analytics for tweet: ${tweet.id}');
            },
          );
        }, childCount: staticTweets.length),
      );
    }

    if (homeState.isLoading && homeState.tweets.isEmpty) {
      return const SliverToBoxAdapter(
        child: Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }

    if (homeState.tweets.isEmpty) {
      return SliverToBoxAdapter(
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
                'Pull to refresh or start following accounts',
                style: TextStyle(color: Colors.grey[500], fontSize: 14),
              ),
            ],
          ),
        ),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        final tweet = homeState.tweets[index];
        return TweetWidget(
          userDisplayName: tweet.authorName,
          username: tweet.authorUsername,
          timeAgo: timeago.format(tweet.createdAt),
          content: tweet.content,
          imageUrl: tweet.images.isNotEmpty ? tweet.images.first : null,
          replyCount: tweet.replies,
          retweetCount: tweet.retweets,
          likeCount: tweet.likes,
          shareCount: 0,
          reachCount: (tweet.likes * 2.5)
              .round(), // Estimated reach based on likes
          isSaved: tweet.isLiked, // Use like status as save status for demo
          onReply: () {
            // Handle reply action
            print('Reply to tweet: ${tweet.id}');
          },
          onRetweet: () {
            // Handle retweet action
            ref.read(homeViewModelProvider.notifier).toggleRetweet(tweet.id);
          },
          onLike: () {
            // Handle like action
            ref.read(homeViewModelProvider.notifier).toggleLike(tweet.id);
          },
          onShare: () {
            // Handle share action
            print('Share tweet: ${tweet.id}');
          },
          onSave: () {
            // Handle save action
            print('Save tweet: ${tweet.id}');
            // TODO: Implement save functionality in view model
          },
          onReach: () {
            // Handle reach analytics action
            print('View reach analytics for tweet: ${tweet.id}');
          },
        );
      }, childCount: homeState.tweets.length),
    );
  }
}
