import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lite_x/core/providers/current_user_provider.dart';
import 'package:lite_x/core/view/screen/app_shell.dart';
import 'package:lite_x/features/home/models/tweet_model.dart';
import 'package:lite_x/features/home/providers/user_profile_provider.dart';
import 'package:lite_x/features/home/view/screens/tweet_screen.dart';
import 'package:lite_x/features/home/view_model/home_state.dart';
import 'package:lite_x/features/home/view_model/home_view_model.dart';
import 'package:lite_x/features/home/view/widgets/home_app_bar.dart';
import 'package:lite_x/features/home/view/widgets/tweet_widget.dart';
import 'package:lite_x/features/home/view/screens/create_post_screen.dart';
import 'package:lite_x/features/home/view/screens/quote_composer_screen.dart';
import 'package:lite_x/features/home/view/widgets/profile_side_drawer.dart';
import 'package:lite_x/features/home/view/widgets/expandable_fab.dart';
import 'package:lite_x/features/profile/models/shared.dart';
import 'package:lite_x/features/profile/view/screens/profile_screen.dart';
import 'package:lite_x/features/profile/view/widgets/profile_tweets/profile_posts_list.dart';
import 'package:lite_x/features/profile/view_model/providers.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with AutomaticKeepAliveClientMixin {
  late ScrollController _forYouScrollController;
  late ScrollController _followingScrollController;
  late GlobalKey<ScaffoldState> _scaffoldKey;
  double _lastScrollOffset = 0.0;
  String? currentUserId;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _scaffoldKey = GlobalKey<ScaffoldState>();
    _forYouScrollController = ScrollController();
    _followingScrollController = ScrollController();
    _forYouScrollController.addListener(_onScroll);
    _followingScrollController.addListener(_onScroll);
    _loadCurrentUser();
  }

  void _loadCurrentUser() {
    // Get current user from the provider
    final user = ref.read(currentUserProvider);
    if (user != null) {
      currentUserId = user.id;
      // Load user profile data after the widget tree is built
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(userProfileControllerProvider).fetchUserProfile(user.username);
      });
    }
  }

  Future<void> _openCreatePost() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CreatePostScreen()),
    );
  }

  void _openProfile(String username) {
    final normalized = _normalizeUsername(username);
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => ProfilePage(username: normalized)),
    );
  }

  String _normalizeUsername(String username) {
    if (username.isEmpty) return username;
    return username.startsWith('@') ? username.substring(1) : username;
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
    final currentFeed = ref.read(homeViewModelProvider).currentFeed;
    final activeController = currentFeed == FeedType.forYou
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
    final homeState = ref.watch(homeViewModelProvider);
    final currentFeed = homeState.currentFeed;
    final tweets = currentFeed == FeedType.forYou
        ? homeState.forYouTweets
        : homeState.followingTweets;
    final feedName = currentFeed == FeedType.forYou ? "For You" : "Following";
    final currentUserName = ref.watch(currentUserProvider)?.username ?? "";

    final profileData = ref.watch(profileDataProvider(currentUserName));
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.black,
      drawer: const ProfileSideDrawer(),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.read(homeViewModelProvider.notifier).refreshTweets();
          // ignore: unused_result
          await ref.refresh(profilePostsProvider(currentUserName));
        },
        backgroundColor: Colors.grey[900],
        color: Colors.white,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          controller: currentFeed == FeedType.forYou
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
                background: HomeAppBar(scaffoldKey: _scaffoldKey),
                collapseMode: CollapseMode.pin,
              ),
            ),

            // _buildSliverTweetList(
            //   context,
            //   tweets,
            //   homeState.isLoading,
            //   feedName,
            // ),
            SliverFillRemaining(
              child: profileData.when(
                data: (res) {
                  return res.fold(
                    (l) {
                      return RefreshIndicator(
                        onRefresh: () async {
                          // ignore: unused_result
                          await ref.refresh(
                            profileDataProvider(currentUserName),
                          );
                        },
                        child: ListView(
                          children: [Center(child: Text(l.message))],
                        ),
                      );
                    },
                    (data) {
                      return ProfilePostsList(
                        profile: data,
                        tabType: ProfileTabType.Posts,
                      );
                    },
                  );
                },
                error: (err, _) {
                  return RefreshIndicator(
                    onRefresh: () async {
                      // ignore: unused_result
                      await ref.refresh(profileDataProvider(currentUserName));
                    },
                    child: ListView(
                      children: [
                        Center(child: Text("Can't get profile posts")),
                      ],
                    ),
                  );
                },
                loading: () {
                  return ListView(
                    children: [Center(child: CircularProgressIndicator())],
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: ExpandableFab(
        key:const Key('plusButton_home_screen'),
        mainIcon: Icons.add,
        mainIconColor: Colors.white,
        mainBackgroundColor: const Color(0xFF1DA1F2),
        onPrimaryAction: _openCreatePost,
        children: [
          ActionButton(
            icon: Icons.videocam,
            label: 'Go Live',
            onPressed: () {
              // TODO: Implement Go Live functionality
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Go Live feature coming soon'),
                  backgroundColor: Colors.blue,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
          ActionButton(
            icon: Icons.groups,
            label: 'Spaces',
            onPressed: () {
              // TODO: Implement Spaces functionality
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Spaces feature coming soon'),
                  backgroundColor: Colors.blue,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
          ActionButton(
            icon: Icons.image,
            label: 'Photos',
            onPressed: _openCreatePost,
          ),
        ],
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

        // Prefer the current user provider; fall back to the already-loaded currentUserId.
        // Replace `currentUserProvider` with your actual provider name if different.
        final String? knownUserId =
            ref.watch(currentUserProvider)?.id ?? currentUserId;
        final isOwnTweet =
            (currentUserId != null && tweet.userId == currentUserId) ||
            (tweet.userId == knownUserId);

        return TweetWidget(
          tweetId: tweet.id,
          userDisplayName: tweet.authorName,
          username: tweet.authorUsername,
          avatarUrl: tweet.authorAvatar.isNotEmpty ? tweet.authorAvatar : null,
          tweetType: tweet.tweetType,
          timeAgo: TweetWidget.formatTimeAgoShort(tweet.createdAt),
          content: tweet.content,
          imageUrl: tweet.images.isNotEmpty ? tweet.images.first : null,
          mediaUrls: tweet.images,
          onProfileTap: () => _openProfile(tweet.authorUsername),
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
