import 'package:flutter_test/flutter_test.dart';
import 'package:lite_x/core/providers/dio_interceptor.dart';
import 'package:mockito/mockito.dart';
import 'package:lite_x/features/chat/repositories/chat_remote_repository.dart';
import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

class MockChatRemoteRepository extends Mock implements ChatRemoteRepository {}

class MockDio extends Mock implements Dio {}

void main() {
  group('ChatRemoteRepositoryProvider (Generated Code Coverage)', () {
    late MockChatRemoteRepository mockRepository;
    late MockDio mockDio;

    setUp(() {
      mockRepository = MockChatRemoteRepository();
      mockDio = MockDio();
    });

    test('debugGetCreateSourceHash returns correct hash', () {
      const expectedHash = '81c94e0fe24045de098611518454af76f602902b';
      expect(
        chatRemoteRepositoryProvider.debugGetCreateSourceHash(),
        expectedHash,
      );
    });

    test('overrideWithValue creates a valid ProviderOverride', () {
      final override = chatRemoteRepositoryProvider.overrideWithValue(
        mockRepository,
      );

      expect(override, isA<Override>());
      final container = ProviderContainer(overrides: [override]);
      addTearDown(container.dispose);

      final result = container.read(chatRemoteRepositoryProvider);
      expect(result, mockRepository);
    });

    test(
      'create initializes the repository correctly via ProviderContainer',
      () {
        final container = ProviderContainer(
          overrides: [dioProvider.overrideWithValue(mockDio)],
        );
        addTearDown(container.dispose);
        final repository = container.read(chatRemoteRepositoryProvider);

        expect(repository, isA<ChatRemoteRepository>());
      },
    );

    test('ProviderElement creation (Internal coverage)', () {
      final container = ProviderContainer(
        overrides: [dioProvider.overrideWithValue(mockDio)],
      );
      addTearDown(container.dispose);
      final subscription = container.listen(
        chatRemoteRepositoryProvider,
        (_, __) {},
      );
      expect(subscription, isNotNull);
    });
  });
}
