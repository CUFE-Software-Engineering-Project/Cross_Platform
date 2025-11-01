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

    final cachedTweets = feedType == FeedType.forYou
        ? state.forYouTweets
        : state.followingTweets;

    if (cachedTweets.isNotEmpty) {
      state = state.copyWith(currentFeed: feedType, tweets: cachedTweets);
    } else {
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
        final newLikeState = !tweet.isLiked;

        _updateTweetInAllFeeds(
          tweetId,
          (t) => t.copyWith(
            isLiked: newLikeState,
            likes: newLikeState ? t.likes + 1 : t.likes - 1,
          ),
        );

        final serverTweet = await _repository.toggleLike(tweetId, newLikeState);

        _updateTweetInAllFeeds(tweetId, (_) => serverTweet);
      }
    } catch (e) {
      await refreshTweets();
      state = state.copyWith(error: 'Failed to update like: $e');
    }
  }

  Future<void> toggleRetweet(String tweetId) async {
    try {
      final tweets = state.tweets;
      final tweetIndex = tweets.indexWhere((tweet) => tweet.id == tweetId);

      if (tweetIndex != -1) {
        final tweet = tweets[tweetIndex];
        final newRetweetState = !tweet.isRetweeted;

        _updateTweetInAllFeeds(
          tweetId,
          (t) => t.copyWith(
            isRetweeted: newRetweetState,
            retweets: newRetweetState ? t.retweets + 1 : t.retweets - 1,
          ),
        );

        final serverTweet = await _repository.toggleRetweet(
          tweetId,
          newRetweetState,
        );

        _updateTweetInAllFeeds(tweetId, (_) => serverTweet);
      }
    } catch (e) {
      await refreshTweets();
      state = state.copyWith(error: 'Failed to update retweet: $e');
    }
  }

  Future<void> toggleBookmark(String tweetId) async {
    try {
      final tweets = state.tweets;
      final tweetIndex = tweets.indexWhere((tweet) => tweet.id == tweetId);

      if (tweetIndex != -1) {
        final tweet = tweets[tweetIndex];
        final newBookmarkState = !tweet.isBookmarked;

        _updateTweetInAllFeeds(
          tweetId,
          (t) => t.copyWith(isBookmarked: newBookmarkState),
        );

        final serverTweet = await _repository.toggleBookmark(
          tweetId,
          newBookmarkState,
        );

        _updateTweetInAllFeeds(tweetId, (_) => serverTweet);
      }
    } catch (e) {
      await refreshTweets();
      state = state.copyWith(error: 'Failed to update bookmark: $e');
    }
  }

  Future<void> createPost({
    required String content,
    String replyControl = "EVERYONE",
    List<String> images = const [],
    String? replyToId,
  }) async {
    try {
      final newTweet = await _repository.createPost(
        content: content,
        replyControl: replyControl,
        images: images,
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
        final updatedTweets = [newTweet, ...state.tweets];
        final updatedForYou = [newTweet, ...state.forYouTweets];
        final updatedFollowing = [newTweet, ...state.followingTweets];

        state = state.copyWith(
          tweets: updatedTweets,
          forYouTweets: updatedForYou,
          followingTweets: updatedFollowing,
        );
      }
    } catch (e) {
      state = state.copyWith(error: 'Failed to create post: $e');
      rethrow;
    }
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
