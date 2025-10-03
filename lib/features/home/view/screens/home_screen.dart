// lib/features/home/view/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
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
      appBar: const HomeAppBar(),
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
          _buildForYouFeed(homeState, ref),
          _buildFollowingFeed(homeState, ref),
        ],
      ),
    );
  }

  Widget _buildForYouFeed(homeState, WidgetRef ref) {
    return RefreshIndicator(
      onRefresh: () => ref.read(homeViewModelProvider.notifier).refreshTweets(),
      backgroundColor: Colors.grey[900],
      color: Colors.white,
      child: _buildTweetList(homeState, 'For You'),
    );
  }

  Widget _buildFollowingFeed(homeState, WidgetRef ref) {
    return RefreshIndicator(
      onRefresh: () => ref.read(homeViewModelProvider.notifier).refreshTweets(),
      backgroundColor: Colors.grey[900],
      color: Colors.white,
      child: _buildTweetList(homeState, 'Following'),
    );
  }

  Widget _buildTweetList(homeState, String feedType) {
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
      return ListView.builder(
        itemCount: staticTweets.length,
        itemBuilder: (context, index) {
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
        },
      );
    }

    if (homeState.isLoading && homeState.tweets.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    if (homeState.tweets.isEmpty) {
      return Center(
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
      );
    }

    return ListView.builder(
      itemCount: homeState.tweets.length,
      itemBuilder: (context, index) {
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
      },
    );
  }
}
