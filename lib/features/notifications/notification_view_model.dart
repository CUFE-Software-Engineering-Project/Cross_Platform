import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'notification_provider.dart';
import 'notification_model.dart';

part 'notification_view_model.g.dart';

/// ViewModel for all notifications (All tab)
@riverpod
class NotificationViewModel extends _$NotificationViewModel {
  @override
  Future<List<NotificationItem>> build() async {
    final repo = ref.read(notificationRepositoryProvider);
    final notifications = await repo.fetchNotifications();
    
    // Listen to the repository stream for real-time updates from socket
    ref.listen(
      notificationsStreamProvider,
      (previous, next) {
        next.whenData((updatedNotifications) {
          print('NOTI:ViewModel: Received stream update with ${updatedNotifications.length} notifications');
          if (ref.mounted) {
            state = AsyncValue.data(updatedNotifications);
          }
        });
      },
    );
    
    return notifications;
  }

  Future<void> refresh() async {
    if (!ref.mounted) return;
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(notificationRepositoryProvider);
      return await repo.fetchNotifications(forceRefresh: true);
    });
  }

  Future<void> markAsRead(String id) async {
    if (!ref.mounted) return;
    
    final current = state.value;
    if (current == null) return;

    final updated = current.map((n) {
      if (n.id == id) {
        return n.copyWith(isRead: true);
      }
      return n;
    }).toList();

    if (ref.mounted) {
      state = AsyncData(updated);
    }
  }

  Future<void> markNotificationsAsRead() async {
    if (!ref.mounted) return;
    final repo = ref.read(notificationRepositoryProvider);
    await repo.markNotificationsAsRead();
  }

  void updateTweetInteractions(
    String tweetId, {
    int? likesCount,
    int? repostsCount,
    bool? isLiked,
    bool? isRetweeted,
    bool? isBookmarked,
  }) {
    if (!ref.mounted) return;


    final repo = ref.read(notificationRepositoryProvider);

    // Update the main notifications list
    final current = state.value;
    if (current != null) {
      final updated = current.map((n) {
        if (n.tweetId == tweetId) {
          return n.copyWith(
            likesCount: likesCount ?? n.likesCount,
            repostsCount: repostsCount ?? n.repostsCount,
            isLiked: isLiked ?? n.isLiked,
            isRetweeted: isRetweeted ?? n.isRetweeted,
            isBookmarked: isBookmarked ?? n.isBookmarked,
          );
        }
        return n;
      }).toList();

      if (ref.mounted) {
        state = AsyncData(updated);
        repo.updateNotificationsDirectly(updated);
      }
    }

    // Also update mentions if they have the same tweetId
    try {
      final updatedMentions = repo.mentions.map((m) {
        if (m.tweetId == tweetId) {
          return m.copyWith(
            likesCount: likesCount ?? m.likesCount,
            repostsCount: repostsCount ?? m.repostsCount,
            isLiked: isLiked ?? m.isLiked,
            isRetweeted: isRetweeted ?? m.isRetweeted,
            isBookmarked: isBookmarked ?? m.isBookmarked,
          );
        }
        return m;
      }).toList();
      
      // Only update if there were mentions with this tweetId
      final hasMatches = updatedMentions.any((m) => m.tweetId == tweetId);
      if (hasMatches) {
        repo.updateMentionsDirectly(updatedMentions);
        print('NOTI:ViewModel: Tweet interactions updated in mentions list');
      }
    } catch (e) {
      print('NOTI:ViewModel: Error updating mentions: $e');
    }
  }
}

/// Notifier class for mentions-only view model
class _MentionsViewModelNotifier extends AsyncNotifier<List<NotificationItem>> {
  @override
  Future<List<NotificationItem>> build() async {
    print('NOTI:MentionsViewModel: Building mentions view model...');
    final repo = ref.read(notificationRepositoryProvider);
    final mentions = await repo.fetchMentions();
    print('NOTI:MentionsViewModel: Loaded ${mentions.length} mentions');
    
    // Listen to the repository stream for real-time updates from socket
    ref.listen(
      mentionsStreamProvider,
      (previous, next) {
        next.whenData((updatedMentions) {
          print('NOTI:MentionsViewModel: Received stream update with ${updatedMentions.length} mentions');
          if (ref.mounted) {
            state = AsyncValue.data(updatedMentions);
          }
        });
      },
    );
    
    return mentions;
  }

  Future<void> refresh() async {
    if (!ref.mounted) return;
    print('NOTI:MentionsViewModel: Refresh called - reloading from mentions API');
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(notificationRepositoryProvider);
      return await repo.fetchMentions(forceRefresh: true);
    });
    print('NOTI:MentionsViewModel: Refresh completed');
  }

  void updateMentionTweetInteractions(
    String tweetId, {
    int? likesCount,
    int? repostsCount,
    bool? isLiked,
    bool? isRetweeted,
    bool? isBookmarked,
  }) {
    if (!ref.mounted) return;

    print('NOTI:MentionsViewModel: Updating tweet interactions for: $tweetId');
    final repo = ref.read(notificationRepositoryProvider);

    final current = state.value;
    if (current != null) {
      final updated = current.map((m) {
        if (m.tweetId == tweetId) {
          return m.copyWith(
            likesCount: likesCount ?? m.likesCount,
            repostsCount: repostsCount ?? m.repostsCount,
            isLiked: isLiked ?? m.isLiked,
            isRetweeted: isRetweeted ?? m.isRetweeted,
            isBookmarked: isBookmarked ?? m.isBookmarked,
          );
        }
        return m;
      }).toList();

      if (ref.mounted) {
        state = AsyncData(updated);
        repo.updateMentionsDirectly(updated);
        print('NOTI:MentionsViewModel: Tweet interactions updated in mentions list');
      }
    }
  }
}

/// Provider for mentions view model
final mentionsViewModelProvider = AsyncNotifierProvider<
    _MentionsViewModelNotifier,
    List<NotificationItem>>(
  () => _MentionsViewModelNotifier(),
);
