// lib/features/home/view_model/home_view_model.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lite_x/features/home/models/tweet_model.dart';
import 'package:lite_x/features/home/repositories/home_repository.dart';
import 'package:lite_x/features/home/view_model/home_state.dart';

// Provider for HomeRepository
final homeRepositoryProvider = Provider<HomeRepository>((ref) {
  return HomeRepository();
});

// StateNotifier for managing home page state
class HomeViewModel extends Notifier<HomeState> {
  late HomeRepository _repository;

  @override
  HomeState build() {
    _repository = ref.read(homeRepositoryProvider);

    // Start with empty state and load tweets asynchronously
    // This is more realistic - no data immediately available
    Future.microtask(() => loadTweets());

    return const HomeState(
      tweets: [],
      forYouTweets: [],
      followingTweets: [],
      isLoading: true,
    );
  }

  // Load tweets based on current feed type
  Future<void> loadTweets({FeedType? feedType}) async {
    final feed = feedType ?? state.currentFeed;
    state = state.copyWith(isLoading: true, error: null, currentFeed: feed);

    try {
      // Fetch tweets based on feed type
      final tweets = await _fetchTweetsForFeed(feed);

      // Cache tweets in the appropriate feed and update current tweets
      if (feed == FeedType.forYou) {
        state = state.copyWith(
          tweets: tweets,
          forYouTweets: tweets,
          isLoading: false,
        );
      } else {
        state = state.copyWith(
          tweets: tweets,
          followingTweets: tweets,
          isLoading: false,
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load tweets: $e',
      );
    }
  }

  // Switch between feeds
  Future<void> switchFeed(FeedType feedType) async {
    if (state.currentFeed == feedType) return;

    // Check if we have cached data for this feed
    final cachedTweets = feedType == FeedType.forYou
        ? state.forYouTweets
        : state.followingTweets;

    if (cachedTweets.isNotEmpty) {
      // Use cached data immediately for instant switching
      state = state.copyWith(currentFeed: feedType, tweets: cachedTweets);
    } else {
      // Load fresh data if no cache available
      await loadTweets(feedType: feedType);
    }
  }

  // Refresh tweets (pull to refresh)
  Future<void> refreshTweets() async {
    state = state.copyWith(isRefreshing: true, error: null);

    try {
      // Fetch fresh data for current feed
      final tweets = await _fetchTweetsForFeed(state.currentFeed);

      // Update both current tweets and the appropriate cached feed
      if (state.currentFeed == FeedType.forYou) {
        state = state.copyWith(
          tweets: tweets,
          forYouTweets: tweets,
          isRefreshing: false,
        );
      } else {
        state = state.copyWith(
          tweets: tweets,
          followingTweets: tweets,
          isRefreshing: false,
        );
      }
    } catch (e) {
      state = state.copyWith(
        isRefreshing: false,
        error: 'Failed to refresh tweets: $e',
      );
    }
  }

  // Helper method to fetch tweets based on feed type
  Future<List<TweetModel>> _fetchTweetsForFeed(FeedType feedType) async {
    switch (feedType) {
      case FeedType.forYou:
        return await _repository.fetchForYouTweets();
      case FeedType.following:
        return await _repository.fetchFollowingTweets();
    }
  }

  // Helper method to update a tweet in all cached feeds
  void _updateTweetInAllFeeds(
    String tweetId,
    TweetModel Function(TweetModel) updater,
  ) {
    // Update current tweets
    final tweets = state.tweets;
    final tweetIndex = tweets.indexWhere((t) => t.id == tweetId);
    List<TweetModel> updatedTweets = tweets;
    if (tweetIndex != -1) {
      updatedTweets = List<TweetModel>.from(tweets);
      updatedTweets[tweetIndex] = updater(tweets[tweetIndex]);
    }

    // Update forYouTweets cache
    final forYouIndex = state.forYouTweets.indexWhere((t) => t.id == tweetId);
    List<TweetModel> updatedForYou = state.forYouTweets;
    if (forYouIndex != -1) {
      updatedForYou = List<TweetModel>.from(state.forYouTweets);
      updatedForYou[forYouIndex] = updater(state.forYouTweets[forYouIndex]);
    }

    // Update followingTweets cache
    final followingIndex = state.followingTweets.indexWhere(
      (t) => t.id == tweetId,
    );
    List<TweetModel> updatedFollowing = state.followingTweets;
    if (followingIndex != -1) {
      updatedFollowing = List<TweetModel>.from(state.followingTweets);
      updatedFollowing[followingIndex] = updater(
        state.followingTweets[followingIndex],
      );
    }

    state = state.copyWith(
      tweets: updatedTweets,
      forYouTweets: updatedForYou,
      followingTweets: updatedFollowing,
    );
  }

  // Like/unlike a tweet
  Future<void> toggleLike(String tweetId) async {
    try {
      final tweets = state.tweets;
      final tweetIndex = tweets.indexWhere((tweet) => tweet.id == tweetId);

      if (tweetIndex != -1) {
        final tweet = tweets[tweetIndex];
        final newLikeState = !tweet.isLiked;

        // Optimistic update - update UI immediately in all feeds
        _updateTweetInAllFeeds(
          tweetId,
          (t) => t.copyWith(
            isLiked: newLikeState,
            likes: newLikeState ? t.likes + 1 : t.likes - 1,
          ),
        );

        // Call backend API
        final serverTweet = await _repository.toggleLike(tweetId, newLikeState);

        // Update with server response (in case of any differences)
        _updateTweetInAllFeeds(tweetId, (_) => serverTweet);
      }
    } catch (e) {
      // Revert optimistic update on error
      await refreshTweets();
      state = state.copyWith(error: 'Failed to update like: $e');
    }
  }

  // Retweet/unretweet a tweet
  Future<void> toggleRetweet(String tweetId) async {
    try {
      final tweets = state.tweets;
      final tweetIndex = tweets.indexWhere((tweet) => tweet.id == tweetId);

      if (tweetIndex != -1) {
        final tweet = tweets[tweetIndex];
        final newRetweetState = !tweet.isRetweeted;

        // Optimistic update - update UI immediately in all feeds
        _updateTweetInAllFeeds(
          tweetId,
          (t) => t.copyWith(
            isRetweeted: newRetweetState,
            retweets: newRetweetState ? t.retweets + 1 : t.retweets - 1,
          ),
        );

        // Call backend API
        final serverTweet = await _repository.toggleRetweet(
          tweetId,
          newRetweetState,
        );

        // Update with server response (in case of any differences)
        _updateTweetInAllFeeds(tweetId, (_) => serverTweet);
      }
    } catch (e) {
      // Revert optimistic update on error
      await refreshTweets();
      state = state.copyWith(error: 'Failed to update retweet: $e');
    }
  }

  // Bookmark/unbookmark a tweet
  Future<void> toggleBookmark(String tweetId) async {
    try {
      final tweets = state.tweets;
      final tweetIndex = tweets.indexWhere((tweet) => tweet.id == tweetId);

      if (tweetIndex != -1) {
        final tweet = tweets[tweetIndex];
        final newBookmarkState = !tweet.isBookmarked;

        // Optimistic update - update UI immediately in all feeds
        _updateTweetInAllFeeds(
          tweetId,
          (t) => t.copyWith(isBookmarked: newBookmarkState),
        );

        // Call backend API
        final serverTweet = await _repository.toggleBookmark(
          tweetId,
          newBookmarkState,
        );

        // Update with server response (in case of any differences)
        _updateTweetInAllFeeds(tweetId, (_) => serverTweet);
      }
    } catch (e) {
      // Revert optimistic update on error
      await refreshTweets();
      state = state.copyWith(error: 'Failed to update bookmark: $e');
    }
  }

  // Create a new post
  Future<void> createPost({
    required String content,
    String replyControl = "EVERYONE", // EVERYONE, FOLLOWING, MENTIONED
    List<String> images = const [],
    String? replyToId,
  }) async {
    try {
      // Create the post via repository (matches API POST /api/tweets)
      final newTweet = await _repository.createPost(
        content: content,
        replyControl: replyControl,
        images: images,
        replyToId: replyToId,
      );

      // If it's a reply, don't add to main feed - only update parent tweet
      if (replyToId != null) {
        // Update parent tweet's reply count in all feeds
        final updatedTweets = _updateParentTweetInList(
          state.tweets,
          replyToId,
          newTweet.id,
        );
        final updatedForYou = _updateParentTweetInList(
          state.forYouTweets,
          replyToId,
          newTweet.id,
        );
        final updatedFollowing = _updateParentTweetInList(
          state.followingTweets,
          replyToId,
          newTweet.id,
        );

        state = state.copyWith(
          tweets: updatedTweets,
          forYouTweets: updatedForYou,
          followingTweets: updatedFollowing,
        );
      } else {
        // Regular post (not a reply) - add to main feed
        final updatedTweets = [newTweet, ...state.tweets];

        state = state.copyWith(
          tweets: updatedTweets,
          forYouTweets: state.currentFeed == FeedType.forYou
              ? updatedTweets
              : [newTweet, ...state.forYouTweets],
          followingTweets: state.currentFeed == FeedType.following
              ? updatedTweets
              : [newTweet, ...state.followingTweets],
        );
      }
    } catch (e) {
      state = state.copyWith(error: 'Failed to create post: $e');
    }
  }

  // Helper method to update parent tweet in a list
  List<TweetModel> _updateParentTweetInList(
    List<TweetModel> tweets,
    String parentId,
    String replyId,
  ) {
    final parentIndex = tweets.indexWhere((t) => t.id == parentId);
    if (parentIndex == -1) return tweets;

    final updatedTweets = [...tweets];
    final parentTweet = updatedTweets[parentIndex];
    updatedTweets[parentIndex] = parentTweet.copyWith(
      replies: parentTweet.replies + 1,
      replyIds: [...parentTweet.replyIds, replyId],
    );
    return updatedTweets;
  }

  // Get replies for a tweet
  Future<List<TweetModel>> getReplies(String tweetId) async {
    try {
      return await _repository.getReplies(tweetId);
    } catch (e) {
      state = state.copyWith(error: 'Failed to load replies: $e');
      return [];
    }
  }

  // Create a quote tweet
  Future<void> createQuoteTweet({
    required String content,
    required String quotedTweetId,
    required TweetModel quotedTweet,
    String replyControl = "EVERYONE",
    List<String> images = const [],
  }) async {
    try {
      final newTweet = await _repository.createQuoteTweet(
        content: content,
        quotedTweetId: quotedTweetId,
        quotedTweet: quotedTweet,
        replyControl: replyControl,
        images: images,
      );

      // Update state with the new quote tweet
      final updatedTweets = [newTweet, ...state.tweets];

      state = state.copyWith(
        tweets: updatedTweets,
        forYouTweets: state.currentFeed == FeedType.forYou
            ? updatedTweets
            : [newTweet, ...state.forYouTweets],
        followingTweets: state.currentFeed == FeedType.following
            ? updatedTweets
            : [newTweet, ...state.followingTweets],
      );
    } catch (e) {
      state = state.copyWith(error: 'Failed to create quote tweet: $e');
    }
  }

  // Delete a post
  Future<void> deletePost(String tweetId) async {
    try {
      // Delete via repository
      await _repository.deletePost(tweetId);

      // Update state by removing the deleted tweet and its replies
      final updatedTweets = state.tweets.where((t) {
        // Remove the tweet itself
        if (t.id == tweetId) return false;
        // Remove replies to the deleted tweet
        if (t.replyToId == tweetId) return false;
        return true;
      }).toList();

      // Also update cached feeds
      final updatedForYouTweets = state.forYouTweets.where((t) {
        if (t.id == tweetId) return false;
        if (t.replyToId == tweetId) return false;
        return true;
      }).toList();

      final updatedFollowingTweets = state.followingTweets.where((t) {
        if (t.id == tweetId) return false;
        if (t.replyToId == tweetId) return false;
        return true;
      }).toList();

      // Update parent tweet's reply count if this was a reply
      final deletedTweet = state.tweets.firstWhere(
        (t) => t.id == tweetId,
        orElse: () => state.tweets.first,
      );

      if (deletedTweet.replyToId != null) {
        final parentIndex = updatedTweets.indexWhere(
          (t) => t.id == deletedTweet.replyToId,
        );
        if (parentIndex != -1) {
          final parent = updatedTweets[parentIndex];
          updatedTweets[parentIndex] = parent.copyWith(
            replies: parent.replies > 0 ? parent.replies - 1 : 0,
            replyIds: parent.replyIds.where((id) => id != tweetId).toList(),
          );
        }
      }

      state = state.copyWith(
        tweets: updatedTweets,
        forYouTweets: updatedForYouTweets,
        followingTweets: updatedFollowingTweets,
      );
    } catch (e) {
      state = state.copyWith(error: 'Failed to delete post: $e');
    }
  }
}

// Provider for HomeViewModel
final homeViewModelProvider = NotifierProvider<HomeViewModel, HomeState>(() {
  return HomeViewModel(); // Creates a new HomeViewModel instance
});
