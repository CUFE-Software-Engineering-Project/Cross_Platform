import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:lite_x/features/notifications/notification_socket_service.dart';
import 'dart:async';
import 'notification_model.dart';
import './notification_provider.dart';
import 'mentions_view_model.dart';

part 'notification_view_model.g.dart';

@riverpod
class NotificationViewModel extends _$NotificationViewModel {
  late StreamSubscription _notificationSub;

  @override
  Future<List<NotificationItem>> build() async {
    ref.onDispose(() {
      _notificationSub.cancel();
    });
    
    // Setup socket listeners first
    _setupSocketListeners();
    _setupUnseenCountListener();
    
    // Initial fetch - this will be the initial data
    final initialNotifications = await _fetchInitialNotifications();
    print('Initial notifications loaded: ${initialNotifications.length}');
    
    return initialNotifications;
  }

  Future<List<NotificationItem>> _fetchInitialNotifications() async {
    final repo = ref.read(notificationRepositoryProvider);
    return repo.fetchNotifications();
  }

  void _setupSocketListeners() {
    try {
      final socketService = ref.read(notificationSocketServiceProvider);
      
      // Listen to new notifications from socket
      _notificationSub = socketService.newNotificationStream.listen(
      (notificationData) {
        try {
          print('Socket notification received: $notificationData');
          
          // Parse the incoming notification
          final notification = Notification.fromJson(notificationData);
          
          // Extract actor username
          final actorUsername = notification.actor.username;
          print('Actor username: $actorUsername');
          
          // Convert to NotificationItem with actor data
          final item = NotificationItem(
            id: notification.id,
            title: notification.title,
            body: notification.body,
            isRead: notification.isRead,
            mediaUrl: notification.actor.media?.url ?? '',
            tweetId: notification.tweetId,
            createdAt: notification.createdAt,
            actor: notification.actor,
            targetUsername: actorUsername,
            quotedAuthor: null,
            quotedContent: null,
            repliesCount: 0,
            repostsCount: 0,
            likesCount: 0,
            isLiked: false,
            isRetweeted: false,
            isBookmarked: false,
            tweet: null,
          );
          
          // Get current list from the current state
          final currentState = state;
          print('Current state: ${currentState.runtimeType}');
          
          List<NotificationItem> currentList = [];
          if (currentState is AsyncData<List<NotificationItem>>) {
            currentList = currentState.value;
            print('Current list count: ${currentList.length}');
          } else {
            print('State is not AsyncData, starting with empty list');
          }
          
          // Prepend new item to the list
          final updated = [item, ...currentList];
          print('Updated list count: ${updated.length}, prepended to front');
          
          if (ref.mounted) {
            state = AsyncData(updated);
          }
          
          // If it's a mention, also add to mentions tab
          if (notification.title == 'REPLY' || notification.title == 'MENTION') {
            print('Routing notification to mentions tab');
            ref.read(mentionsViewModelProvider.notifier).addMentionFromSocket(notificationData);
          }
        } catch (e) {
          print('Error processing socket notification: $e');
        }
      },
      onError: (e) {
        print('Socket notification stream error: $e');
      },
    );
    } catch (e) {
      print('Error setting up socket listeners: $e');
    }
  }

  void _setupUnseenCountListener() {
    try {
      final socketService = ref.read(notificationSocketServiceProvider);
      
      // Listen to unseen count updates from socket
      socketService.unseenCountStream.listen((countData) {
        try {
          final count = countData['count'] as int? ?? 0;
          print('Unseen notifications count from socket: $count');
          
          if (ref.mounted) {
            ref.read(unseenNotificationsCountProvider.notifier).state = count;
          }
        } catch (e) {
          print('Error processing unseen count: $e');
        }
      });
    } catch (e) {
      print('Error setting up unseen count listener: $e');
    }
  }

  Future<void> refresh() async {
    if (!ref.mounted) return;
    state = const AsyncLoading();
    
    final result = await AsyncValue.guard(() async {
      return _fetchInitialNotifications();
    });
    
    if (ref.mounted) {
      state = result;
    }
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
    
    // Emit open-notification event to server
    try {
      final socketService = ref.read(notificationSocketServiceProvider);
      socketService.openNotification(id);
    } catch (e) {
      print('Error opening notification: $e');
    }
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

    final current = state.value;
    if (current == null) return;

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
    }
  }
}
