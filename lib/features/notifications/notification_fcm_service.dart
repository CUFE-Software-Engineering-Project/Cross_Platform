import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:lite_x/core/routes/AppRouter.dart';
import 'package:lite_x/core/routes/Route_Constants.dart';

class NotificationFcmService {
  NotificationFcmService._internal();

  static final NotificationFcmService _instance =
      NotificationFcmService._internal();

  factory NotificationFcmService() => _instance;

  bool _initialized = false;
  bool _listenersSetup = false;

  void Function()? notificationsRefreshCallback;
  void Function()? mentionsRefreshCallback;

  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;

    try {
      _setupListeners();

      final token = await FirebaseMessaging.instance.getToken();
      if (token != null) {
        print('FCM Token: $token');
      }
      
      FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
        print('FCM Token refreshed');
      });

      final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
      if (initialMessage != null) {
        _handleDataUpdate(initialMessage);
        _handleNavigation(initialMessage);
      }
    } catch (e) {
      print('FCM init error: $e');
    }
  }

  void _setupListeners() {
    if (_listenersSetup) return;
    _listenersSetup = true;

    FirebaseMessaging.onMessage.listen(
      (RemoteMessage message) {
        _handleDataUpdate(message);
      },
      onError: (error) {
        print('FCM foreground message error: $error');
      },
    );

    FirebaseMessaging.onMessageOpenedApp.listen(
      (RemoteMessage message) {
        _handleDataUpdate(message);
        _handleNavigation(message);
      },
      onError: (error) {
        print('FCM app opened message error: $error');
      },
    );
  }

  void _handleDataUpdate(RemoteMessage message) {
    try {
      final data = message.data;
      final type = data['type'] as String?;
      
      print('FCM _handleDataUpdate: type=$type');

      switch (type) {
        case 'notifications':
          notificationsRefreshCallback?.call();
          break;
        case 'mention':
          mentionsRefreshCallback?.call();
          break;
        default:
          notificationsRefreshCallback?.call();
          break;
      }
    } catch (e, st) {
      print('FCM _handleDataUpdate error: $e');
    }
  }

  void _handleNavigation(RemoteMessage message) {
    try {
      final data = message.data;
      final type = data['type'] as String?;

      if (type == null) {
        Approuter.router.goNamed(RouteConstants.notifications);
        return;
      }

      switch (type) {
        case 'notifications':
          Approuter.router.goNamed(RouteConstants.notifications);
          break;
        case 'tweet':
          final tweetId = data['tweetId'] as String?;
          if (tweetId != null && tweetId.isNotEmpty) {
            Approuter.router.goNamed(
              RouteConstants.TweetDetailsScreen,
              pathParameters: {'tweetId': tweetId},
            );
          } else {
            Approuter.router.goNamed(RouteConstants.notifications);
          }
          break;
        default:
          Approuter.router.goNamed(RouteConstants.notifications);
          break;
      }
    } catch (e, st) {
      print('FCM _handleNavigation error: $e');
    }
  }
}
