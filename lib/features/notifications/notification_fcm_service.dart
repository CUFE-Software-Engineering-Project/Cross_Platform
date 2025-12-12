import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:lite_x/core/routes/AppRouter.dart';
import 'package:lite_x/core/routes/Route_Constants.dart';

class NotificationFcmService {
  NotificationFcmService._internal();

  static final NotificationFcmService _instance =
      NotificationFcmService._internal();

  factory NotificationFcmService() => _instance;

  bool _initialized = false;

  void Function()? notificationsRefreshCallback;
  void Function()? mentionsRefreshCallback;

  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;

    final token = await FirebaseMessaging.instance.getToken();
    print('FCM device token: $token');

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('FCM onMessage: ${message.messageId}, data: ${message.data}');
      _handleDataUpdate(message);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('FCM onMessageOpenedApp: ${message.messageId}, data: ${message.data}');
      _handleDataUpdate(message);
      _handleNavigation(message);
    });

    final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      print('FCM getInitialMessage: ${initialMessage.messageId}, data: ${initialMessage.data}');
      _handleDataUpdate(initialMessage);
      _handleNavigation(initialMessage);
    }
  }

  void _handleDataUpdate(RemoteMessage message) {
    final data = message.data;
    final type = data['type'] as String?;

    switch (type) {
      case 'notifications':
        notificationsRefreshCallback?.call();
        break;
      case 'mention':
        mentionsRefreshCallback?.call();
        break;
      default:
        break;
    }
  }

  void _handleNavigation(RemoteMessage message) {
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
        if (tweetId != null) {
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
  }
}
