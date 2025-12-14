import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:lite_x/features/notifications/notification_provider.dart';
import 'package:lite_x/features/notifications/repositories/notification_repository.dart';
import 'package:lite_x/features/notifications/notification_model.dart';

import 'notification_provider_test.mocks.dart';

@GenerateMocks([NotificationRepository])
void main() {
  group('NotificationNotifier', () {
    late MockNotificationRepository mockRepository;

    setUp(() {
      mockRepository = MockNotificationRepository();
    });

    test('build returns list of NotificationItem', () async {
      final notifications = [
        NotificationItem(
          id: '1',
          title: 'Test 1',
          body: 'Body 1',
          isRead: false,
          createdAt: '2024-01-01',
          mediaUrl: '',
          actor: Actor(name: 'John', username: 'john', profileMediaId: ''),
        ),
      ];

      when(mockRepository.fetchNotifications())
          .thenAnswer((_) async => notifications);

      final container = ProviderContainer(
        overrides: [
          notificationRepositoryProvider.overrideWith((ref) => mockRepository),
        ],
      );

      final notifier = container.read(notificationsProvider.notifier);
      final result = await notifier.build();

      expect(result, equals(notifications));
    });

    test('build throws exception when repository fails', () async {
      when(mockRepository.fetchNotifications())
          .thenThrow(Exception('Failed to fetch'));

      final container = ProviderContainer(
        overrides: [
          notificationRepositoryProvider.overrideWith((ref) => mockRepository),
        ],
      );

      final notifier = container.read(notificationsProvider.notifier);

      expect(
        () => notifier.build(),
        throwsA(isA<Exception>()),
      );
    });

    test('refresh calls fetchNotifications again', () async {
      final notifications = [
        NotificationItem(
          id: '1',
          title: 'Test',
          body: 'Body',
          isRead: false,
          createdAt: '2024-01-01',
          mediaUrl: '',
          actor: Actor(name: 'John', username: 'john', profileMediaId: ''),
        ),
      ];

      when(mockRepository.fetchNotifications())
          .thenAnswer((_) async => notifications);

      final container = ProviderContainer(
        overrides: [
          notificationRepositoryProvider.overrideWith((ref) => mockRepository),
        ],
      );

      final notifier = container.read(notificationsProvider.notifier);
      await notifier.build();
      await notifier.refresh();

      verify(mockRepository.fetchNotifications()).called(greaterThanOrEqualTo(2));
    });

    test('handles empty notification list', () async {
      when(mockRepository.fetchNotifications())
          .thenAnswer((_) async => []);

      final container = ProviderContainer(
        overrides: [
          notificationRepositoryProvider.overrideWith((ref) => mockRepository),
        ],
      );

      final notifier = container.read(notificationsProvider.notifier);
      final result = await notifier.build();

      expect(result, isEmpty);
    });

    test('provider state is loading initially', () async {
      when(mockRepository.fetchNotifications())
          .thenAnswer((_) async => []);

      final container = ProviderContainer(
        overrides: [
          notificationRepositoryProvider.overrideWith((ref) => mockRepository),
        ],
      );

      final initialState = container.read(notificationsProvider);

      expect(initialState, isA<AsyncLoading>());
    });

    test('provider state is data after successful load', () async {
      final notifications = [
        NotificationItem(
          id: '1',
          title: 'Test',
          body: 'Body',
          isRead: false,
          createdAt: '2024-01-01',
          mediaUrl: '',
          actor: Actor(name: 'John', username: 'john', profileMediaId: ''),
        ),
      ];

      when(mockRepository.fetchNotifications())
          .thenAnswer((_) async => notifications);

      final container = ProviderContainer(
        overrides: [
          notificationRepositoryProvider.overrideWith((ref) => mockRepository),
        ],
      );

      await container.read(notificationsProvider.future);

      final state = container.read(notificationsProvider);

      expect(state, isA<AsyncData>());
      expect(state.value, equals(notifications));
    });
  });
}
