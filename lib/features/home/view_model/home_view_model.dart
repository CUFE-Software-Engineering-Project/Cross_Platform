import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lite_x/core/providers/current_user_provider.dart';
import 'package:lite_x/features/home/models/tweet_model.dart';
import 'package:lite_x/features/home/repositories/home_repository.dart';
import 'package:lite_x/features/home/view_model/home_state.dart';

final homeViewModelProvider = NotifierProvider<HomeViewModel, HomeState>(() {
  return HomeViewModel();
});

class HomeViewModel extends Notifier<HomeState> {
  late HomeRepository _repository;
  String? _activeUserKey;

  @override
  HomeState build() {
    _repository = ref.read(homeRepositoryProvider);

    // IMPORTANT: tie this state to the logged-in user.
    // Otherwise, when the user logs out and logs in with another account,
    // the provider can keep the old tweets in memory and show the old timeline.
    final user = ref.watch(currentUserProvider);
    final userKey = user?.id ?? user?.username;

    // If logged out, clear everything.
    if (userKey == null) {
      _activeUserKey = null;
      return const HomeState(
        tweets: [],
        forYouTweets: [],
        followingTweets: [],
        isLoading: false,
        currentFeed: FeedType.forYou,
      );
    }

    // If account changed, reset + fetch fresh feed for the new account.
    if (_activeUserKey != userKey) {
      _activeUserKey = userKey;
      Future.microtask(() => loadTweets(feedType: FeedType.forYou));
    }

    return const HomeState(
      tweets: [],
      forYouTweets: [],
      followingTweets: [],
      isLoading: true,
      currentFeed: FeedType.forYou, // Default to For You feed
    );
  }

  String _getFullPhotoUrl(String? photo) {
    if (photo == null || photo.isEmpty) return '';

    // If it's already a full URL, return it
    if (photo.startsWith('http://') || photo.startsWith('https://')) {
      return photo;
    }

    // Otherwise, construct the full media URL
    return 'https://litex.siematworld.online/media/$photo';
  }

  Future<void> loadTweets({FeedType? feedType}) async {
    final feed = feedType ?? state.currentFeed;
    state = state.copyWith(isLoading: true, error: null, currentFeed: feed);

    try {
      final result = await _fetchTweetsForFeed(feed, cursor: null);

      if (feed == FeedType.forYou) {
        state = state.copyWith(
          tweets: result.tweets,
          forYouTweets: result.tweets,
          isLoading: false,
          forYouCursor: result.nextCursor,
          hasMoreForYou: result.nextCursor != null,
        );
      } else {
        state = state.copyWith(
          tweets: result.tweets,
          followingTweets: result.tweets,
          isLoading: false,
          followingCursor: result.nextCursor,
          hasMoreFollowing: result.nextCursor != null,
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

    final cachedTweets = feedType == FeedType.forYou
        ? state.forYouTweets
        : state.followingTweets;

    if (cachedTweets.isNotEmpty) {
      // Use cached tweets without reloading
      state = state.copyWith(
        currentFeed: feedType,
        tweets: cachedTweets,
        isLoading: false,
      );
    } else {
      // Show loading indicator and clear tweets while fetching
      state = state.copyWith(
        currentFeed: feedType,
        tweets: [],
        isLoading: true,
        error: null,
      );

      // Load fresh tweets if cache is empty
      await loadTweets(feedType: feedType);
    }
  }

  Future<void> refreshTweets() async {
    state = state.copyWith(isRefreshing: true, error: null);

    try {
      final result = await _fetchTweetsForFeed(state.currentFeed, cursor: null);

      if (state.currentFeed == FeedType.forYou) {
        state = state.copyWith(
          tweets: result.tweets,
          forYouTweets: result.tweets,
          isRefreshing: false,
          forYouCursor: result.nextCursor,
          hasMoreForYou: result.nextCursor != null,
        );
      } else {
        state = state.copyWith(
          tweets: result.tweets,
          followingTweets: result.tweets,
          isRefreshing: false,
          followingCursor: result.nextCursor,
          hasMoreFollowing: result.nextCursor != null,
        );
      }
    } catch (e) {
      state = state.copyWith(
        isRefreshing: false,
        error: 'Failed to refresh tweets: $e',
      );
    }
  }

  Future<void> loadMoreTweets() async {
    // Don't load if already loading or no more tweets
    if (state.isLoadingMore) return;

    final hasMore = state.currentFeed == FeedType.forYou
        ? state.hasMoreForYou
        : state.hasMoreFollowing;

    if (!hasMore) return;

    final cursor = state.currentFeed == FeedType.forYou
        ? state.forYouCursor
        : state.followingCursor;

    if (cursor == null) return;

    state = state.copyWith(isLoadingMore: true);

    try {
      final result = await _fetchTweetsForFeed(
        state.currentFeed,
        cursor: cursor,
      );

      if (state.currentFeed == FeedType.forYou) {
        final updatedTweets = [...state.forYouTweets, ...result.tweets];
        state = state.copyWith(
          tweets: updatedTweets,
          forYouTweets: updatedTweets,
          isLoadingMore: false,
          forYouCursor: result.nextCursor,
          hasMoreForYou: result.nextCursor != null,
        );
      } else {
        final updatedTweets = [...state.followingTweets, ...result.tweets];
        state = state.copyWith(
          tweets: updatedTweets,
          followingTweets: updatedTweets,
          isLoadingMore: false,
          followingCursor: result.nextCursor,
          hasMoreFollowing: result.nextCursor != null,
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoadingMore: false,
        error: 'Failed to load more tweets: $e',
      );
    }
  }

  Future<({List<TweetModel> tweets, String? nextCursor})> _fetchTweetsForFeed(
    FeedType feedType, {
    String? cursor,
  }) async {
    switch (feedType) {
      case FeedType.forYou:
        return await _repository.fetchForYouTweets(cursor: cursor, limit: 20);
      case FeedType.following:
        return await _repository.fetchFollowingTweets(
          cursor: cursor,
          limit: 20,
        );
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
        // Ensure the tweet has current user data
        final currentUser = ref.read(currentUserProvider);
        print(
          '📝 CreatePost - Current User: ${currentUser?.username}, Photo: ${currentUser?.photo}',
        );
        print(
          '📝 CreatePost - New Tweet: name=${newTweet.authorName}, username=${newTweet.authorUsername}, avatar=${newTweet.authorAvatar}',
        );

        final enrichedTweet = currentUser != null
            ? newTweet.copyWith(
                authorName: newTweet.authorName == 'Unknown User'
                    ? currentUser.name
                    : newTweet.authorName,
                authorUsername: newTweet.authorUsername == 'unknown'
                    ? currentUser.username
                    : newTweet.authorUsername,
                authorAvatar: newTweet.authorAvatar.isEmpty
                    ? _getFullPhotoUrl(currentUser.photo)
                    : newTweet.authorAvatar,
                userId: newTweet.userId ?? currentUser.id,
              )
            : newTweet;

        print(
          '📝 CreatePost - Enriched Tweet: name=${enrichedTweet.authorName}, username=${enrichedTweet.authorUsername}, avatar=${enrichedTweet.authorAvatar}',
        );

        // New posts should only appear in the Following feed, not For You
        final updatedFollowing = [enrichedTweet, ...state.followingTweets];

        // Only update current tweets if we're on the Following feed
        final updatedTweets = state.currentFeed == FeedType.following
            ? [enrichedTweet, ...state.tweets]
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
        isFollowed: updatedTweet.isFollowed,
      ),
    );
  }

  /// Updates the follow status for all tweets by a specific user
  void updateFollowStatusForUser(String username, bool isFollowed) {
    final updateTweets = (List<TweetModel> tweets) {
      return tweets.map((tweet) {
        if (tweet.authorUsername == username) {
          return tweet.copyWith(isFollowed: isFollowed);
        }
        return tweet;
      }).toList();
    };

    state = state.copyWith(
      tweets: updateTweets(state.tweets),
      forYouTweets: updateTweets(state.forYouTweets),
      followingTweets: updateTweets(state.followingTweets),
    );
  }

  void incrementQuoteCount(String tweetId) {
    _updateTweetInAllFeeds(tweetId, (t) => t.copyWith(quotes: t.quotes + 1));
  }

  /// Updates a tweet with new data (content, media, etc.)
  void updateTweet(TweetModel updatedTweet) {
    _updateTweetInAllFeeds(updatedTweet.id, (_) => updatedTweet);
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
