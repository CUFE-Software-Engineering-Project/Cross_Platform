import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod/riverpod.dart';
import 'package:lite_x/features/chat/repositories/chat_local_repository.dart';
import 'package:mockito/mockito.dart';

class MockChatLocalRepository extends Mock implements ChatLocalRepository {}

void main() {
  test("chatLocalRepositoryProvider override works", () {
    final mockRepo = MockChatLocalRepository();

    final container = ProviderContainer(
      overrides: [chatLocalRepositoryProvider.overrideWithValue(mockRepo)],
    );

    final repo = container.read(chatLocalRepositoryProvider);

    expect(repo, mockRepo);
  });
}
