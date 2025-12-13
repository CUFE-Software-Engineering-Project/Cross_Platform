import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/providers/dio_interceptor.dart';
import '../repositories/mentioned_tweets_repository.dart';
import '../models/tweet_model.dart';
import 'mentioned_tweets_state.dart';

part 'mentioned_tweets_view_model.g.dart';

final mentionedTweetsRepositoryProvider = Provider<MentionedTweetsRepository>((
  ref,
) {
  final dio = ref.watch(dioProvider);
  return MentionedTweetsRepository(dio);
});

@riverpod
class MentionedTweetsViewModel extends _$MentionedTweetsViewModel {
  late final MentionedTweetsRepository _repository;
  late final String _username;

  @override
  MentionedTweetsState build(String username) {
    _username = username;
    _repository = ref.read(mentionedTweetsRepositoryProvider);
    loadInitialTweets();
    return MentionedTweetsState(username: username);
  }

  Future<void> loadInitialTweets() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final result = await _repository.fetchMentionedTweets(
        username: _username,
        limit: 20,
      );

      state = state.copyWith(
        tweets: result['tweets'] as List<TweetModel>,
        nextCursor: result['nextCursor'] as String?,
        hasMore: result['hasMore'] as bool,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> loadMoreTweets() async {
    if (!state.hasMore || state.isLoadingMore) return;

    state = state.copyWith(isLoadingMore: true);

    try {
      final result = await _repository.fetchMentionedTweets(
        username: _username,
        limit: 20,
        cursor: state.nextCursor,
      );

      final newTweets = result['tweets'] as List<TweetModel>;
      final updatedTweets = [...state.tweets, ...newTweets];

      state = state.copyWith(
        tweets: updatedTweets,
        nextCursor: result['nextCursor'] as String?,
        hasMore: result['hasMore'] as bool,
        isLoadingMore: false,
      );
    } catch (e) {
      state = state.copyWith(isLoadingMore: false, error: e.toString());
    }
  }

  Future<void> refresh() async {
    state = MentionedTweetsState(username: _username);
    await loadInitialTweets();
  }

  void updateTweet(TweetModel updatedTweet) {
    final updatedTweets = state.tweets.map((tweet) {
      return tweet.id == updatedTweet.id ? updatedTweet : tweet;
    }).toList();

    state = state.copyWith(tweets: updatedTweets);
  }
}
