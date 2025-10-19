import '../../models/notification.dart';

// --- Mock User Data ---
final _userAlex = User(
  username: 'alex',
  avatarUrl: 'https://picsum.photos/id/1011/100/100',
);

final _userJessica = User(
  username: 'jessica',
  avatarUrl: 'https://picsum.photos/id/1012/100/100',
);

final _userMike = User(
  username: 'mike_dev',
  avatarUrl: 'https://picsum.photos/id/1013/100/100',
);

final _userSarah = User(
  username: 'sarah_lee',
  avatarUrl: 'https://picsum.photos/id/1015/100/100',
);

final _verifiedElon = User(
  username: 'elonmusk',
  avatarUrl: 'https://picsum.photos/id/1016/100/100',
  isVerified: true,
);

final _verifiedMarques = User(
  username: 'MKBHD',
  avatarUrl: 'https://picsum.photos/id/1018/100/100',
  isVerified: true,
);


// --- All Tab Data ---
final List<AppNotification> allNotifications = [
  AppNotification(
    user: _userAlex,
    type: NotificationType.like,
    content: 'liked your post',
    timestamp: '5m',
    postSnippet: 'That new coffee shop is amazing! ☕️',
  ),
  AppNotification(
    user: _userJessica,
    type: NotificationType.follow,
    content: 'started following you',
    timestamp: '1h',
  ),
    AppNotification(
    user: _verifiedElon,
    type: NotificationType.mention,
    content: "mentioned you in a post",
    timestamp: '2h',
    postSnippet: "@you Starship is ready to fly! 🚀"
  ),
  AppNotification(
    user: _userMike,
    type: NotificationType.repost,
    content: 'reposted your article',
    timestamp: '1d',
    postSnippet: 'Flutter vs. React Native in 2025: A Deep Dive.',
  ),
  AppNotification(
    user: _userSarah,
    type: NotificationType.like,
    content: 'liked your photo',
    timestamp: '2d',
    postSnippet: 'Sunset at the beach was breathtaking. #nofilter',
  ),
];

// --- Verified Tab Data ---
final List<AppNotification> verifiedNotifications = [
  AppNotification(
    user: _verifiedElon,
    type: NotificationType.reply,
    content: 'replied to your post',
    timestamp: '2h',
    postSnippet: "Interesting take. Have you considered the impact on battery life?",
  ),
  AppNotification(
    user: _verifiedMarques,
    type: NotificationType.mention,
    content: 'mentioned you in a video review',
    timestamp: '1d',
    postSnippet: "Big shoutout to @you for the detailed breakdown on the new Pixel camera. It's spot on!",
  ),
];

// --- Mentions Tab Data ---
final List<AppNotification> mentionsNotifications = [
    AppNotification(
    user: _verifiedElon,
    type: NotificationType.mention,
    content: "mentioned you in a post:",
    timestamp: '2h',
    postSnippet: "@you Starship is ready to fly! 🚀"
  ),
  AppNotification(
    user: _userJessica,
    type: NotificationType.mention,
    content: "mentioned you:",
    timestamp: '3h',
    postSnippet: "Totally agree with you! That new framework is a game-changer.",
  ),
  AppNotification(
    user: _userMike,
    type: NotificationType.reply,
    content: 'replied:',
    timestamp: '1d',
    postSnippet: "That's a great point. I hadn't thought about it from that angle before.",
  ),
];
