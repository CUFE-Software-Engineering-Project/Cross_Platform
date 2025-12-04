import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lite_x/features/home/models/tweet_model.dart';
import 'package:lite_x/features/home/repositories/home_repository.dart';
import 'package:lite_x/features/home/view_model/home_state.dart';

final homeViewModelProvider = NotifierProvider<HomeViewModel, HomeState>(() {
  return HomeViewModel();
});

class HomeViewModel extends Notifier<HomeState> {
  late HomeRepository _repository;

  @override
  HomeState build() {
    _repository = ref.read(homeRepositoryProvider);

    Future.microtask(() => loadTweets());

    return const HomeState(
      tweets: [],
      forYouTweets: [],
      followingTweets: [],
      isLoading: true,
      currentFeed: FeedType.forYou, // Default to For You feed
    );
  }

  Future<void> loadTweets({FeedType? feedType}) async {
    final feed = feedType ?? state.currentFeed;
    state = state.copyWith(isLoading: true, error: null, currentFeed: feed);

    try {
      final tweets = await _fetchTweetsForFeed(feed);

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

  Future<void> switchFeed(FeedType feedType) async {
    if (state.currentFeed == feedType) return;

    // Update current feed immediately to show the correct cached tweets
    state = state.copyWith(currentFeed: feedType);

    final cachedTweets = feedType == FeedType.forYou
        ? state.forYouTweets
        : state.followingTweets;

    if (cachedTweets.isNotEmpty) {
      // Use cached tweets without reloading
      state = state.copyWith(tweets: cachedTweets);
    } else {
      // Load fresh tweets if cache is empty
      await loadTweets(feedType: feedType);
    }
  }

  Future<void> refreshTweets() async {
    state = state.copyWith(isRefreshing: true, error: null);

    try {
      final tweets = await _fetchTweetsForFeed(state.currentFeed);

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

  Future<List<TweetModel>> _fetchTweetsForFeed(FeedType feedType) async {
    switch (feedType) {
      case FeedType.forYou:
        return await _repository.fetchForYouTweets();
      case FeedType.following:
        return await _repository.fetchFollowingTweets();
    }
  }

  void _updateTweetInAllFeeds(
    String tweetId,
    TweetModel Function(TweetModel) updater,
  ) {
    final tweets = state.tweets;
    final tweetIndex = tweets.indexWhere((t) => t.id == tweetId);
    List<TweetModel> updatedTweets = tweets;
    if (tweetIndex != -1) {
      updatedTweets = List<TweetModel>.from(tweets);
      updatedTweets[tweetIndex] = updater(tweets[tweetIndex]);
    }

    final forYouIndex = state.forYouTweets.indexWhere((t) => t.id == tweetId);
    List<TweetModel> updatedForYou = state.forYouTweets;
    if (forYouIndex != -1) {
      updatedForYou = List<TweetModel>.from(state.forYouTweets);
      updatedForYou[forYouIndex] = updater(state.forYouTweets[forYouIndex]);
    }

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

  Future<void> toggleLike(String tweetId) async {
    try {
      final tweets = state.tweets;
      final tweetIndex = tweets.indexWhere((tweet) => tweet.id == tweetId);

      if (tweetIndex != -1) {
        final tweet = tweets[tweetIndex];
        final currentLikeState = tweet.isLiked;
        final newLikeState = !currentLikeState;

        // Optimistically update UI immediately
        _updateTweetInAllFeeds(
          tweetId,
          (t) => t.copyWith(
            isLiked: newLikeState,
            likes: newLikeState ? t.likes + 1 : t.likes - 1,
          ),
        );

        // Send request to server (don't wait for full response)
        await _repository.toggleLike(tweetId, currentLikeState);

        // Keep the optimistic update - don't overwrite with server response
        // The server response might not have the correct isLiked state
      }
    } catch (e) {
      // Revert the optimistic update on error
      final tweets = state.tweets;
      final tweetIndex = tweets.indexWhere((tweet) => tweet.id == tweetId);
      if (tweetIndex != -1) {
        final tweet = tweets[tweetIndex];
        _updateTweetInAllFeeds(
          tweetId,
          (t) => t.copyWith(
            isLiked: !tweet.isLiked,
            likes: tweet.isLiked ? t.likes - 1 : t.likes + 1,
          ),
        );
      }
      state = state.copyWith(error: 'Failed to update like: $e');
    }
  }

  Future<void> toggleRetweet(String tweetId) async {
    try {
      final tweets = state.tweets;
      final tweetIndex = tweets.indexWhere((tweet) => tweet.id == tweetId);

      if (tweetIndex != -1) {
        final tweet = tweets[tweetIndex];
        final currentRetweetState = tweet.isRetweeted;
        final newRetweetState = !currentRetweetState;

        // Optimistically update UI immediately
        _updateTweetInAllFeeds(
          tweetId,
          (t) => t.copyWith(
            isRetweeted: newRetweetState,
            retweets: newRetweetState ? t.retweets + 1 : t.retweets - 1,
          ),
        );

        // Send request to server
        await _repository.toggleRetweet(tweetId, currentRetweetState);

        // Keep the optimistic update
      }
    } catch (e) {
      // Revert the optimistic update on error
      final tweets = state.tweets;
      final tweetIndex = tweets.indexWhere((tweet) => tweet.id == tweetId);
      if (tweetIndex != -1) {
        final tweet = tweets[tweetIndex];
        _updateTweetInAllFeeds(
          tweetId,
          (t) => t.copyWith(
            isRetweeted: !tweet.isRetweeted,
            retweets: tweet.isRetweeted ? t.retweets - 1 : t.retweets + 1,
          ),
        );
      }
      state = state.copyWith(error: 'Failed to update retweet: $e');
    }
  }

  Future<void> toggleBookmark(String tweetId) async {
    try {
      final tweets = state.tweets;
      final tweetIndex = tweets.indexWhere((tweet) => tweet.id == tweetId);

      if (tweetIndex != -1) {
        final tweet = tweets[tweetIndex];
        final currentBookmarkState = tweet.isBookmarked;
        final newBookmarkState = !currentBookmarkState;

        // Optimistically update UI immediately
        _updateTweetInAllFeeds(
          tweetId,
          (t) => t.copyWith(isBookmarked: newBookmarkState),
        );

        // Send request to server
        await _repository.toggleBookmark(tweetId, currentBookmarkState);

        // Keep the optimistic update
      }
    } catch (e) {
      // Revert the optimistic update on error
      final tweets = state.tweets;
      final tweetIndex = tweets.indexWhere((tweet) => tweet.id == tweetId);
      if (tweetIndex != -1) {
        final tweet = tweets[tweetIndex];
        _updateTweetInAllFeeds(
          tweetId,
          (t) => t.copyWith(isBookmarked: !tweet.isBookmarked),
        );
      }
      state = state.copyWith(error: 'Failed to update bookmark: $e');
    }
  }

  Future<void> createPost({
    required String content,
    String replyControl = "EVERYONE",
    List<String> mediaIds = const [],
    String? replyToId,
  }) async {
    try {
      final newTweet = await _repository.createPost(
        content: content,
        replyControl: replyControl,
        mediaIds: mediaIds,
        replyToId: replyToId,
      );

      if (replyToId != null) {
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
        // New posts should only appear in the Following feed, not For You
        final updatedFollowing = [newTweet, ...state.followingTweets];

        // Only update current tweets if we're on the Following feed
        final updatedTweets = state.currentFeed == FeedType.following
            ? [newTweet, ...state.tweets]
            : state.tweets;

        state = state.copyWith(
          tweets: updatedTweets,
          followingTweets: updatedFollowing,
          // Don't add to forYouTweets
        );
      }
    } catch (e) {
      state = state.copyWith(error: 'Failed to create post: $e');
      rethrow;
    }
  }

  /// Keeps the cached feeds in sync with backend mutations that happen
  /// outside the home timelines (e.g. from the tweet detail screen).
  void syncTweetFromServer(TweetModel updatedTweet) {
    _updateTweetInAllFeeds(
      updatedTweet.id,
      (t) => t.copyWith(
        likes: updatedTweet.likes,
        retweets: updatedTweet.retweets,
        replies: updatedTweet.replies,
        replyIds: updatedTweet.replyIds,
        isLiked: updatedTweet.isLiked,
        isRetweeted: updatedTweet.isRetweeted,
        isBookmarked: updatedTweet.isBookmarked,
        quotes: updatedTweet.quotes,
        bookmarks: updatedTweet.bookmarks,
      ),
    );
  }

  void incrementQuoteCount(String tweetId) {
    _updateTweetInAllFeeds(tweetId, (t) => t.copyWith(quotes: t.quotes + 1));
  }

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

  Future<List<TweetModel>> getReplies(String tweetId) async {
    try {
      return await _repository.getReplies(tweetId);
    } catch (e) {
      state = state.copyWith(error: 'Failed to load replies: $e');
      return [];
    }
  }

  Future<void> createQuoteTweet({
    required String content,
    required String quotedTweetId,
    required TweetModel quotedTweet,
    String replyControl = "EVERYONE",
    List<String> mediaIds = const [],
  }) async {
    try {
      final newTweet = await _repository.createQuoteTweet(
        content: content,
        quotedTweetId: quotedTweetId,
        quotedTweet: quotedTweet,
        replyControl: replyControl,
        mediaIds: mediaIds,
      );

      // Quote tweets should only appear in the Following feed, not For You
      final updatedFollowing = [newTweet, ...state.followingTweets];

      // Only update current tweets if we're on the Following feed
      final updatedTweets = state.currentFeed == FeedType.following
          ? [newTweet, ...state.tweets]
          : state.tweets;

      state = state.copyWith(
        tweets: updatedTweets,
        followingTweets: updatedFollowing,
        // Don't add to forYouTweets
      );

      incrementQuoteCount(quotedTweetId);
    } catch (e) {
      state = state.copyWith(error: 'Failed to create quote tweet: $e');
    }
  }

  Future<void> deletePost(String tweetId) async {
    try {
      await _repository.deletePost(tweetId);

      final updatedTweets = state.tweets.where((t) {
        if (t.id == tweetId) return false;
        if (t.replyToId == tweetId) return false;
        return true;
      }).toList();

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
