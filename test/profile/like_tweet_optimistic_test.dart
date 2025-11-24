import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lite_x/features/profile/models/shared.dart';
import 'package:lite_x/features/profile/view_model/providers.dart';
import 'package:mockito/mockito.dart';

import 'profile_repo_extended_test.mocks.dart';

void main() {
  late MockProfileRepo mockRepo;

  setUp(() {
    mockRepo = MockProfileRepo();
  });

  group('Like/Unlike Tweet Optimistic Update Tests', () {
    testWidgets('like tweet provider calls repo and returns Right on success', (tester) async {
      when(mockRepo.likeTweet('tweet123'))
          .thenAnswer((_) async => const Right(()));

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            profileRepoProvider.overrideWithValue(mockRepo),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: Consumer(
                builder: (context, ref, child) {
                  return ElevatedButton(
                    onPressed: () async {
                      final like = ref.read(likeTweetProvider);
                      await like('tweet123');
                    },
                    child: Text('Like'),
                  );
                },
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Like'));
      await tester.pumpAndSettle();

      verify(mockRepo.likeTweet('tweet123')).called(1);
    });

    testWidgets('unlike tweet provider calls repo and returns Right on success', (tester) async {
      when(mockRepo.unLikeTweet('tweet123'))
          .thenAnswer((_) async => const Right(()));

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            profileRepoProvider.overrideWithValue(mockRepo),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: Consumer(
                builder: (context, ref, child) {
                  return ElevatedButton(
                    onPressed: () async {
                      final unlike = ref.read(unlikeTweetProvider);
                      await unlike('tweet123');
                    },
                    child: Text('Unlike'),
                  );
                },
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Unlike'));
      await tester.pumpAndSettle();

      verify(mockRepo.unLikeTweet('tweet123')).called(1);
    });

    testWidgets('like tweet returns Left on failure', (tester) async {
      when(mockRepo.likeTweet('tweet123'))
          .thenAnswer((_) async => Left(Failure("Network error")));

      String? errorMessage;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            profileRepoProvider.overrideWithValue(mockRepo),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: Consumer(
                builder: (context, ref, child) {
                  return ElevatedButton(
                    onPressed: () async {
                      final like = ref.read(likeTweetProvider);
                      final result = await like('tweet123');
                      result.fold(
                        (fail) => errorMessage = fail.message,
                        (r) => errorMessage = null,
                      );
                    },
                    child: Text('Like'),
                  );
                },
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Like'));
      await tester.pumpAndSettle();

      expect(errorMessage, 'Network error');
      verify(mockRepo.likeTweet('tweet123')).called(1);
    });

    testWidgets('unlike tweet returns Left on failure', (tester) async {
      when(mockRepo.unLikeTweet('tweet123'))
          .thenAnswer((_) async => Left(Failure("Network error")));

      String? errorMessage;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            profileRepoProvider.overrideWithValue(mockRepo),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: Consumer(
                builder: (context, ref, child) {
                  return ElevatedButton(
                    onPressed: () async {
                      final unlike = ref.read(unlikeTweetProvider);
                      final result = await unlike('tweet123');
                      result.fold(
                        (fail) => errorMessage = fail.message,
                        (r) => errorMessage = null,
                      );
                    },
                    child: Text('Unlike'),
                  );
                },
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Unlike'));
      await tester.pumpAndSettle();

      expect(errorMessage, 'Network error');
      verify(mockRepo.unLikeTweet('tweet123')).called(1);
    });

    testWidgets('multiple like calls are handled correctly', (tester) async {
      when(mockRepo.likeTweet('tweet123'))
          .thenAnswer((_) async => const Right(()));
      when(mockRepo.likeTweet('tweet456'))
          .thenAnswer((_) async => const Right(()));

      int likeCount = 0;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            profileRepoProvider.overrideWithValue(mockRepo),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: Consumer(
                builder: (context, ref, child) {
                  return Column(
                    children: [
                      ElevatedButton(
                        onPressed: () async {
                          final like = ref.read(likeTweetProvider);
                          await like('tweet123');
                          likeCount++;
                        },
                        child: Text('Like 1'),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          final like = ref.read(likeTweetProvider);
                          await like('tweet456');
                          likeCount++;
                        },
                        child: Text('Like 2'),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Like 1'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Like 2'));
      await tester.pumpAndSettle();

      expect(likeCount, 2);
      verify(mockRepo.likeTweet('tweet123')).called(1);
      verify(mockRepo.likeTweet('tweet456')).called(1);
    });
  });

  group('Save/Unsave Tweet Tests', () {
    testWidgets('save tweet provider calls repo and returns Right', (tester) async {
      when(mockRepo.saveTweet('tweet123'))
          .thenAnswer((_) async => const Right(()));

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            profileRepoProvider.overrideWithValue(mockRepo),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: Consumer(
                builder: (context, ref, child) {
                  return ElevatedButton(
                    onPressed: () async {
                      final save = ref.read(saveTweetProvider);
                      await save('tweet123');
                    },
                    child: Text('Save'),
                  );
                },
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      verify(mockRepo.saveTweet('tweet123')).called(1);
    });

    testWidgets('unsave tweet provider calls repo and returns Right', (tester) async {
      when(mockRepo.unSaveTweet('tweet123'))
          .thenAnswer((_) async => const Right(()));

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            profileRepoProvider.overrideWithValue(mockRepo),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: Consumer(
                builder: (context, ref, child) {
                  return ElevatedButton(
                    onPressed: () async {
                      final unsave = ref.read(unSaveTweetProvider);
                      await unsave('tweet123');
                    },
                    child: Text('Unsave'),
                  );
                },
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Unsave'));
      await tester.pumpAndSettle();

      verify(mockRepo.unSaveTweet('tweet123')).called(1);
    });

    testWidgets('save tweet returns Left on failure', (tester) async {
      when(mockRepo.saveTweet('tweet123'))
          .thenAnswer((_) async => Left(Failure("Save failed")));

      String? errorMessage;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            profileRepoProvider.overrideWithValue(mockRepo),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: Consumer(
                builder: (context, ref, child) {
                  return ElevatedButton(
                    onPressed: () async {
                      final save = ref.read(saveTweetProvider);
                      final result = await save('tweet123');
                      result.fold(
                        (fail) => errorMessage = fail.message,
                        (r) => errorMessage = null,
                      );
                    },
                    child: Text('Save'),
                  );
                },
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(errorMessage, 'Save failed');
      verify(mockRepo.saveTweet('tweet123')).called(1);
    });
  });

  group('Tweet Interaction Performance Tests', () {
    testWidgets('rapid like/unlike calls are handled correctly', (tester) async {
      int callCount = 0;
      when(mockRepo.likeTweet('tweet123')).thenAnswer((_) async {
        callCount++;
        return const Right(());
      });

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            profileRepoProvider.overrideWithValue(mockRepo),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: Consumer(
                builder: (context, ref, child) {
                  return ElevatedButton(
                    onPressed: () async {
                      final like = ref.read(likeTweetProvider);
                      await like('tweet123');
                    },
                    child: Text('Like'),
                  );
                },
              ),
            ),
          ),
        ),
      );

      // Rapidly tap like button
      await tester.tap(find.text('Like'));
      await tester.pump(const Duration(milliseconds: 10));
      await tester.tap(find.text('Like'));
      await tester.pump(const Duration(milliseconds: 10));
      await tester.tap(find.text('Like'));
      await tester.pumpAndSettle();

      expect(callCount, 3);
    });
  });
}
