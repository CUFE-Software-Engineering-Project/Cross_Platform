import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lite_x/core/providers/dio_interceptor.dart';
import 'package:lite_x/core/providers/socket_provider.dart';
import '../notification_model.dart';

/// Repository for managing notifications via WebSocket connection.
/// 
/// This repository:
/// - Loads initial notifications from REST API on first fetch
/// - Maintains real-time notifications received via socket
/// - Streams notifications and unseen count updates via Dart streams
/// - Fetches additional data (media, tweet info) via HTTP for each notification
/// - Emits socket events to mark notifications as read
/// - Separates mention notifications into a dedicated list
class NotificationRepository {
  final Ref ref;
  final List<NotificationItem> _notifications = [];
  final List<NotificationItem> _mentions = [];
  final StreamController<List<NotificationItem>> _notificationsController =
      StreamController<List<NotificationItem>>.broadcast();
  final StreamController<List<NotificationItem>> _mentionsController =
      StreamController<List<NotificationItem>>.broadcast();
  final StreamController<int> _unseenCountController =
      StreamController<int>.broadcast();
  int _unseenCount = 0;
  bool _initialDataLoaded = false;
  bool _initialMentionsLoaded = false;

  NotificationRepository(this.ref) {
    _setupSocketListeners();
  }

  /// Stream of all notifications in real-time
  Stream<List<NotificationItem>> get notificationsStream =>
      _notificationsController.stream;

  /// Stream of mention notifications only
  Stream<List<NotificationItem>> get mentionsStream =>
      _mentionsController.stream;

  /// Stream of unseen notification count updates
  Stream<int> get unseenCountStream => _unseenCountController.stream;

  /// Get immutable list of current notifications
  List<NotificationItem> get notifications => List.unmodifiable(_notifications);

  /// Get immutable list of mentions
  List<NotificationItem> get mentions => List.unmodifiable(_mentions);

  /// Get current unseen notification count
  int get unseenCount => _unseenCount;

  /// Setup listeners for socket events:
  /// - 'unseen-notifications-count': Initial count on connection
  /// - 'notification': New notification received
  /// - Connection status events
  void _setupSocketListeners() {
    final socketService = ref.read(socketServiceProvider);
    socketService.connect();

    // Listen for unseen count updates from server
    // This event is received when connection is established or count changes
    socketService.on('unseen-notifications-count', (data) {
      _unseenCount = data is int ? data : (data as num).toInt();
      _unseenCountController.add(_unseenCount);
    });

    // Listen for new notifications in real-time
    // Each notification is enriched with additional data (media, tweet details)
    socketService.on('notification', (data) {
      try {
        if (data is Map<String, dynamic>) {
          final notificationData =
              data['notification'] ?? data;
          final notification = Notification.fromJson(
            notificationData is Map<String, dynamic>
                ? notificationData
                : (notificationData as Map).cast<String, dynamic>(),
          );
          _processAndAddNotification(notification).then((_) {
          }).catchError((e) {
            print('NOTI:Socket: Error processing notification: $e');
          });
        }
      } catch (e, st) {
        print('NOTI:Socket: Error parsing notification: $e');
      }
    });

    // Handle connection events
    socketService.on('connect', (_) {});
    socketService.on('disconnect', (_) {});
  }

  /// Process and add a new notification to the list
  /// 
  /// This method:
  /// 1. Fetches the profile media for the actor
  /// 2. Fetches tweet data if this is a tweet notification
  /// 3. Fetches parent tweet for quote notifications
  /// 4. Creates a NotificationItem and adds it to the beginning of the list
  /// 5. Emits the updated list to subscribers
  Future<void> _processAndAddNotification(Notification notification) async {
    final dio = ref.read(dioProvider);

    try {
      String mediaUrl = '';
      final profileMediaId = notification.actor.profileMediaId;

      if (profileMediaId.isNotEmpty && profileMediaId != 'null') {
        try {
          final mediaResp = await dio.get(
            'api/media/download-request/$profileMediaId',
          );

          if (mediaResp.statusCode == 200) {
            final media = MediaInfo.fromJson(mediaResp.data);
            mediaUrl = media.url;
          }
        } catch (e) {
          // Error fetching media
        }
      }

      int repliesCount = 0;
      int repostsCount = 0;
      int likesCount = 0;
      bool isLiked = false;
      bool isRetweeted = false;
      EmbeddedTweet? embeddedTweet;
      String? quotedAuthor;
      String? quotedUsername;
      String? quotedProfileMediaId;
      String? quotedContent;

      final tweetId = notification.tweetId;
      if (tweetId != null && tweetId.isNotEmpty) {
        try {
          final tweetResp = await dio.get('api/tweets/$tweetId');

          if (tweetResp.statusCode == 200 && tweetResp.data is Map) {
            final tweetJson =
                (tweetResp.data as Map<dynamic, dynamic>).cast<String, dynamic>();

            embeddedTweet = EmbeddedTweet.fromJson(tweetJson);
            repliesCount = embeddedTweet.repliesCount;
            repostsCount = embeddedTweet.retweetCount;
            likesCount = embeddedTweet.likesCount;
            isLiked = embeddedTweet.isLiked;
            isRetweeted = embeddedTweet.isRetweeted;

            // For quote notifications, fetch the parent tweet
            if (notification.title == 'QUOTE' &&
                embeddedTweet.parentId != null &&
                embeddedTweet.parentId!.isNotEmpty) {
              try {
                final parentResp = await dio.get(
                  'api/tweets/${embeddedTweet.parentId}',
                );

                if (parentResp.statusCode == 200 && parentResp.data is Map) {
                  final parentJson = (parentResp.data as Map<dynamic, dynamic>)
                      .cast<String, dynamic>();
                  final parentTweet = EmbeddedTweet.fromJson(parentJson);
                  quotedAuthor = parentTweet.user.name;
                  quotedUsername = parentTweet.user.username;
                  quotedProfileMediaId = parentTweet.user.profileMediaId;
                  quotedContent = parentTweet.content;
                }
              } catch (e) {
                // Error fetching parent tweet
              }
            }
          }
        } catch (e) {
          // Error fetching tweet
        }
      }

      final item = NotificationItem(
        id: notification.id,
        title: notification.title,
        body: notification.body,
        isRead: notification.isRead,
        mediaUrl: mediaUrl,
        tweetId: notification.tweetId,
        createdAt: notification.createdAt,
        actor: notification.actor,
        targetUsername: null,
        quotedAuthor: quotedAuthor,
        quotedUsername: quotedUsername,
        quotedProfileMediaId: quotedProfileMediaId,
        quotedContent: quotedContent,
        repliesCount: repliesCount,
        repostsCount: repostsCount,
        likesCount: likesCount,
        isLiked: isLiked,
        isRetweeted: isRetweeted,
        isBookmarked: embeddedTweet?.isBookmarked ?? false,
        tweet: embeddedTweet,
      );

      // Check if notification already exists to prevent duplicates
      final notificationExists = _notifications.any((n) => n.id == item.id);
      if (notificationExists) {
        return;
      }

      // Add to beginning of list (newest first)
      _notifications.insert(0, item);
      _notificationsController.add(List.from(_notifications));

      // Also add to mentions list if it's a mention or reply
      if (notification.title == 'MENTION' || notification.title == 'REPLY') {
        final mentionExists = _mentions.any((m) => m.id == item.id);
        if (!mentionExists) {
          _mentions.insert(0, item);
          _mentionsController.add(List.from(_mentions));
        }
      }
    } catch (e, stackTrace) {
      print('ERROR processing notification: $e');
    }
  }

  /// Fetch notifications: Load from REST API on first call, then stream from socket
  Future<List<NotificationItem>> fetchNotifications({bool forceRefresh = false}) async {
    if (!_initialDataLoaded || forceRefresh) {
      try {
        final dio = ref.read(dioProvider);
        
        final response = await dio.get('api/notifications');
        
        if (response.statusCode == 200) {
          // API returns {notifications: [...]}, unwrap it
          List<dynamic> notificationsList = [];
          if (response.data is Map<String, dynamic>) {
            final dataMap = response.data as Map<String, dynamic>;
            if (dataMap['notifications'] is List) {
              notificationsList = dataMap['notifications'] as List<dynamic>;
            }
          } else if (response.data is List) {
            notificationsList = response.data as List<dynamic>;
          }
          
          if (notificationsList.isNotEmpty) {
            // Clear existing notifications on refresh
            if (forceRefresh) {
              _notifications.clear();
              _mentions.clear();
            }
            
            // Process notifications in reverse order (API returns oldest to newest)
            // So we reverse to process newest first, which will insert them at position 0
            // resulting in newest-first ordering
            for (final notif in notificationsList.reversed) {
              if (notif is Map<String, dynamic>) {
                final notification = Notification.fromJson(notif);
                
                // Add 5ms timeout for processing each notification
                try {
                  await Future.wait(
                    [_processAndAddNotification(notification)],
                    eagerError: false,
                  ).timeout(
                    const Duration(milliseconds: 500000000),
                    onTimeout: () {
                      return [];
                    },
                  );
                } catch (e) {
                  // Continue processing other notifications
                }
              }
            }
            
            _initialDataLoaded = true;
          }
        }
      } catch (e, stackTrace) {
        // Error fetching notifications
      }
    }
    
    return _notifications;
  }

  /// Fetch mentions: Load from dedicated REST API endpoint on first call
  Future<List<NotificationItem>> fetchMentions({bool forceRefresh = false}) async {
    if (!_initialMentionsLoaded || forceRefresh) {
      print('NOTI:Mentions load (forceRefresh=$forceRefresh)');
      
      try {
        final dio = ref.read(dioProvider);
        print('NOTI:Making GET request to api/notifications/mentions');
        final response = await dio.get('api/notifications/mentions');
        print('NOTI:Got response with status: ${response.statusCode}');
        
        if (response.statusCode == 200) {
          print('NOTI:Response data type: ${response.data.runtimeType}');
          
          // Clear existing mentions on refresh
          if (forceRefresh) {
            _mentions.clear();
            print('NOTI:Cleared existing mentions for refresh');
          }
          
          // Handle different response formats
          List<dynamic> mentionsList = [];
          if (response.data is Map<String, dynamic>) {
            final dataMap = response.data as Map<String, dynamic>;
            // Try different possible keys
            if (dataMap['mentionNotifications'] is List) {
              mentionsList = dataMap['mentionNotifications'] as List<dynamic>;
              print('NOTI:Got mentions from mentionNotifications key: ${mentionsList.length} items');
            } else if (dataMap['notifications'] is List) {
              mentionsList = dataMap['notifications'] as List<dynamic>;
              print('NOTI:Unwrapped mentions list, received ${mentionsList.length} items');
            } else if (dataMap['data'] is List) {
              mentionsList = dataMap['data'] as List<dynamic>;
              print('NOTI:Got mentions from data key: ${mentionsList.length} items');
            } else {
              print('NOTI:Response structure: $dataMap');
            }
          } else if (response.data is List) {
            mentionsList = response.data as List<dynamic>;
            print('NOTI:Received ${mentionsList.length} mentions directly from REST API');
          }
          
          if (mentionsList.isNotEmpty) {
            // Process mentions in reverse order (API returns oldest to newest)
            // So we reverse to process newest first, which will insert them at position 0
            // resulting in newest-first ordering
            for (final mention in mentionsList.reversed) {
              if (mention is Map<String, dynamic>) {
                final notification = Notification.fromJson(mention);
                
                // Add 5ms timeout for processing each mention
                try {
                  await Future.wait(
                    [_processAndAddMention(notification)],
                    eagerError: false,
                  ).timeout(
                    const Duration(milliseconds: 500000000),
                    onTimeout: () {
                      print('NOTI:TIMEOUT - Skipping mention ${notification.id} (exceeded 5ms)');
                      return [];
                    },
                  );
                } catch (e) {
                  print('NOTI:ERROR processing mention ${notification.id}: $e');
                }
              }
            }
            
            print('NOTI:Mentions load complete. Total mentions: ${_mentions.length}');
            _mentionsController.add(List.from(_mentions));
          } else {
            print('NOTI:No mentions found');
            _mentionsController.add([]);
          }
          
          _initialMentionsLoaded = true;
        }
      } catch (e, stackTrace) {
        print('NOTI:ERROR fetching mentions from REST API: $e');
        print('NOTI:Stack trace: $stackTrace');
        _initialMentionsLoaded = false;
      }
    } else {
      print('NOTI:Skipping fetch - already loaded (initialMentionsLoaded=$_initialMentionsLoaded, forceRefresh=$forceRefresh)');
    }
    
    return _mentions;
  }

  /// Process and add a mention notification to the mentions list
  /// 
  /// This method processes mention notifications using the same enrichment logic
  /// and adds them only to the mentions list (not to all notifications)
  /// Note: Does not emit stream updates - caller handles that
  Future<void> _processAndAddMention(Notification notification) async {
    print('NOTI:Processing mention: ${notification.title} from ${notification.actor.name}');
    final dio = ref.read(dioProvider);

    try {
      String mediaUrl = '';
      final profileMediaId = notification.actor.profileMediaId;

      if (profileMediaId.isNotEmpty && profileMediaId != 'null') {
        print('NOTI:Fetching media for mention actor: $profileMediaId');
        try {
          final mediaResp = await dio.get(
            'api/media/download-request/$profileMediaId',
          );

          if (mediaResp.statusCode == 200) {
            final media = MediaInfo.fromJson(mediaResp.data);
            mediaUrl = media.url;
            print('NOTI:Got media URL for mention: $mediaUrl');
          }
        } catch (e) {
          print('NOTI:Error fetching media for mention: $e');
        }
      }

      int repliesCount = 0;
      int repostsCount = 0;
      int likesCount = 0;
      bool isLiked = false;
      bool isRetweeted = false;
      EmbeddedTweet? embeddedTweet;
      String? quotedAuthor;
      String? quotedUsername;
      String? quotedProfileMediaId;
      String? quotedContent;

      final tweetId = notification.tweetId;
      if (tweetId != null && tweetId.isNotEmpty) {
        print('NOTI:Fetching tweet data for mention: $tweetId');
        try {
          final tweetResp = await dio.get('api/tweets/$tweetId');

          if (tweetResp.statusCode == 200 && tweetResp.data is Map) {
            final tweetJson =
                (tweetResp.data as Map<dynamic, dynamic>).cast<String, dynamic>();

            embeddedTweet = EmbeddedTweet.fromJson(tweetJson);
            repliesCount = embeddedTweet.repliesCount;
            repostsCount = embeddedTweet.retweetCount;
            likesCount = embeddedTweet.likesCount;
            isLiked = embeddedTweet.isLiked;
            isRetweeted = embeddedTweet.isRetweeted;
            print('NOTI:Mention tweet stats - replies: $repliesCount, reposts: $repostsCount, likes: $likesCount');

            // For quote notifications, fetch the parent tweet
            if (notification.title == 'QUOTE' &&
                embeddedTweet.parentId != null &&
                embeddedTweet.parentId!.isNotEmpty) {
              print('NOTI:Fetching parent tweet for mention: ${embeddedTweet.parentId}');
              try {
                final parentResp = await dio.get(
                  'api/tweets/${embeddedTweet.parentId}',
                );

                if (parentResp.statusCode == 200 && parentResp.data is Map) {
                  final parentJson = (parentResp.data as Map<dynamic, dynamic>)
                      .cast<String, dynamic>();
                  final parentTweet = EmbeddedTweet.fromJson(parentJson);
                  quotedAuthor = parentTweet.user.name;
                  quotedUsername = parentTweet.user.username;
                  quotedProfileMediaId = parentTweet.user.profileMediaId;
                  quotedContent = parentTweet.content;
                  print('NOTI:Got parent tweet for mention from: $quotedAuthor');
                }
              } catch (e) {
                print('NOTI:Error fetching parent tweet for mention: $e');
              }
            }
          }
        } catch (e) {
          print('NOTI:Error fetching tweet for mention: $e');
        }
      } else {
        print('NOTI:No tweet ID for this mention');
      }

      final item = NotificationItem(
        id: notification.id,
        title: notification.title,
        body: notification.body,
        isRead: notification.isRead,
        mediaUrl: mediaUrl,
        tweetId: notification.tweetId,
        createdAt: notification.createdAt,
        actor: notification.actor,
        targetUsername: null,
        quotedAuthor: quotedAuthor,
        quotedUsername: quotedUsername,
        quotedProfileMediaId: quotedProfileMediaId,
        quotedContent: quotedContent,
        repliesCount: repliesCount,
        repostsCount: repostsCount,
        likesCount: likesCount,
        isLiked: isLiked,
        isRetweeted: isRetweeted,
        isBookmarked: embeddedTweet?.isBookmarked ?? false,
        tweet: embeddedTweet,
      );

      // Add only to mentions list (newest first)
      _mentions.insert(0, item);
      print('NOTI:Added mention to mentions list. Total mentions: ${_mentions.length}');
    } catch (e, stackTrace) {
      print('NOTI:FATAL Error processing mention: $e');
      print('NOTI:Stack trace: $stackTrace');
    }
  }

  /// Mark all notifications as read by emitting 'open-notification' socket event
  /// 
  /// This event tells the server to:
  /// - Reset the unseenNotificationCount to 0
  /// - Mark all notifications as seen in the database
  Future<void> markNotificationsAsRead() async {
    final socketService = ref.read(socketServiceProvider);
    try {
      await socketService.emitWhenConnected('open-notification', {});
    } catch (e) {
      // Error marking notifications as read
    }
  }

  /// Update notifications list directly (used when tweet interactions are updated)
  void updateNotificationsDirectly(List<NotificationItem> updatedNotifications) {
    _notifications.clear();
    _notifications.addAll(updatedNotifications);
    _notificationsController.add(List.unmodifiable(_notifications));
  }

  /// Update mentions list directly (used when tweet interactions are updated)
  void updateMentionsDirectly(List<NotificationItem> updatedMentions) {
    _mentions.clear();
    _mentions.addAll(updatedMentions);
    _mentionsController.add(List.unmodifiable(_mentions));
  }

  /// Clean up resources
  void dispose() {
    _notificationsController.close();
    _mentionsController.close();
    _unseenCountController.close();
  }
}