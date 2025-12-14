import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:lite_x/features/notifications/mentions_provider.dart';
import 'package:lite_x/features/notifications/repositories/mentions_repository.dart';
import 'package:lite_x/features/notifications/mentions_model.dart';

import 'mentions_provider_test.mocks.dart';

@GenerateMocks([MentionsRepository])
void main() {
  group('MentionsNotifier', () {
    late MockMentionsRepository mockRepository;

    setUp(() {
      mockRepository = MockMentionsRepository();
    });

    test('build returns list of MentionItem', () async {
      final mentions = [
        MentionItem(
          id: '1',
          content: 'Test mention @user',
          createdAt: '2024-01-01',
          likesCount: 5,
          retweetCount: 2,
          repliesCount: 1,
          quotesCount: 0,
          replyControl: 'everyone',
          tweetType: 'tweet',
          user: TweetUser(
            id: 'user1',
            name: 'John',
            username: 'john',
            verified: false,
            protectedAccount: false,
          ),
          mediaIds: [],
          mediaUrls: [],
          isLiked: false,
          isRetweeted: false,
          isBookmarked: false,
        ),
      ];

      when(mockRepository.fetchMentions())
          .thenAnswer((_) async => mentions);

      final container = ProviderContainer(
        overrides: [
          mentionsRepositoryProvider.overrideWith((ref) => mockRepository),
        ],
      );

      final notifier = container.read(mentionsProvider.notifier);
      final result = await notifier.build();

      expect(result, equals(mentions));
    });

    test('build throws exception when repository fails', () async {
      when(mockRepository.fetchMentions())
          .thenThrow(Exception('Failed to fetch'));

      final container = ProviderContainer(
        overrides: [
          mentionsRepositoryProvider.overrideWith((ref) => mockRepository),
        ],
      );

      final notifier = container.read(mentionsProvider.notifier);

      expect(
        () => notifier.build(),
        throwsA(isA<Exception>()),
      );
    });

    test('refresh calls fetchMentions again', () async {
      final mentions = [
        MentionItem(
          id: '1',
          content: 'Test',
          createdAt: '2024-01-01',
          likesCount: 0,
          retweetCount: 0,
          repliesCount: 0,
          quotesCount: 0,
          replyControl: 'everyone',
          tweetType: 'tweet',
          user: TweetUser(
            id: 'user1',
            name: 'John',
            username: 'john',
            verified: false,
            protectedAccount: false,
          ),
          mediaIds: [],
          mediaUrls: [],
          isLiked: false,
          isRetweeted: false,
          isBookmarked: false,
        ),
      ];

      when(mockRepository.fetchMentions())
          .thenAnswer((_) async => mentions);

      final container = ProviderContainer(
        overrides: [
          mentionsRepositoryProvider.overrideWith((ref) => mockRepository),
        ],
      );

      final notifier = container.read(mentionsProvider.notifier);
      await notifier.build();
      await notifier.refresh();

      verify(mockRepository.fetchMentions()).called(greaterThanOrEqualTo(2));
    });

    test('handles empty mention list', () async {
      when(mockRepository.fetchMentions())
          .thenAnswer((_) async => []);

      final container = ProviderContainer(
        overrides: [
          mentionsRepositoryProvider.overrideWith((ref) => mockRepository),
        ],
      );

      final notifier = container.read(mentionsProvider.notifier);
      final result = await notifier.build();

      expect(result, isEmpty);
    });

    test('provider state is loading initially', () async {
      when(mockRepository.fetchMentions())
          .thenAnswer((_) async => []);

      final container = ProviderContainer(
        overrides: [
          mentionsRepositoryProvider.overrideWith((ref) => mockRepository),
        ],
      );

      final initialState = container.read(mentionsProvider);

      expect(initialState, isA<AsyncLoading>());
    });

    test('provider state is data after successful load', () async {
      final mentions = [
        MentionItem(
          id: '1',
          content: 'Test',
          createdAt: '2024-01-01',
          likesCount: 0,
          retweetCount: 0,
          repliesCount: 0,
          quotesCount: 0,
          replyControl: 'everyone',
          tweetType: 'tweet',
          user: TweetUser(
            id: 'user1',
            name: 'John',
            username: 'john',
            verified: false,
            protectedAccount: false,
          ),
          mediaIds: [],
          mediaUrls: [],
          isLiked: false,
          isRetweeted: false,
          isBookmarked: false,
        ),
      ];

      when(mockRepository.fetchMentions())
          .thenAnswer((_) async => mentions);

      final container = ProviderContainer(
        overrides: [
          mentionsRepositoryProvider.overrideWith((ref) => mockRepository),
        ],
      );

      await container.read(mentionsProvider.future);

      final state = container.read(mentionsProvider);

      expect(state, isA<AsyncData>());
      expect(state.value, equals(mentions));
    });
  });
}
