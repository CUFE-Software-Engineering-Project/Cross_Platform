import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:lite_x/features/notifications/notification_socket_service.dart';
import 'dart:async';
import 'mentions_model.dart';
import './mentions_provider.dart';

part 'mentions_view_model.g.dart';

@riverpod
class MentionsViewModel extends _$MentionsViewModel {
  late StreamSubscription _mentionSub;

  @override
  Future<List<MentionItem>> build() async {
    ref.onDispose(() {
      _mentionSub.cancel();
    });
    
    // Initial fetch
    await _fetchMentions();
    
    // Listen to socket events
    _setupSocketListeners();
    
    return state.value ?? [];
  }

  Future<List<MentionItem>> _fetchMentions() async {
    final repo = ref.read(mentionsRepositoryProvider);
    return repo.fetchMentions();
  }

  void _setupSocketListeners() {
    try {
      final socketService = ref.read(notificationSocketServiceProvider);
      
      // Listen to new notifications and filter for mentions
      _mentionSub = socketService.newNotificationStream.listen(
      (notificationData) {
        try {
          final title = notificationData['title']?.toString() ?? '';
          
          // Only process mention-type notifications
          if (title == 'REPLY' || title == 'MENTION') {
            addMentionFromSocket(notificationData);
          }
        } catch (e) {
          print('Error processing socket mention: $e');
        }
      },
      onError: (e) {
        print('Socket mention stream error: $e');
      },
    );
    } catch (e) {
      print('Error setting up mention socket listeners: $e');
    }
  }

  Future<void> refresh() async {
    if (!ref.mounted) return;
    state = const AsyncLoading();
    
    final result = await AsyncValue.guard(() async {
      return _fetchMentions();
    });
    
    if (ref.mounted) {
      state = result;
    }
  }

  void addMentionFromSocket(Map<String, dynamic> notificationData) {
    if (!ref.mounted) return;

    try {
      print('Adding mention from socket: $notificationData');
      
      // Extract tweet data from notification
      final tweetData = notificationData['tweet'];
      if (tweetData == null) {
        print('No tweet data in notification');
        return;
      }

      // Parse tweet to MentionItem
      final tweet = Tweet.fromJson(tweetData);
      
      // Extract actor username from notification
      final actor = notificationData['actor'] as Map<String, dynamic>?;
      final actorUsername = actor?['username'] as String? ?? 'unknown';
      print('Actor username from notification: $actorUsername');
      
      final mentionItem = MentionItem(
        id: tweet.id,
        content: tweet.content,
        createdAt: tweet.createdAt,
        likesCount: tweet.likesCount,
        retweetCount: tweet.retweetCount,
        repliesCount: tweet.repliesCount,
        quotesCount: tweet.quotesCount,
        replyControl: tweet.replyControl,
        parentId: tweet.parentId,
        tweetType: tweet.tweetType,
        user: tweet.user,
        mediaIds: tweet.mediaIds,
        mediaUrls: [],
        isLiked: tweet.isLiked,
        isRetweeted: tweet.isRetweeted,
        isBookmarked: tweet.isBookmarked,
      );

      // Add to mentions list - PREPEND to show newest first
      final current = state.value ?? [];
      final updated = [mentionItem, ...current];
      
      print('Updated mentions list - new count: ${updated.length}');
      
      if (ref.mounted) {
        state = AsyncData(updated);
      }
    } catch (e) {
      print('Error adding mention from socket: $e');
    }
  }
}

