import 'package:lite_x/features/home/models/tweet_model.dart';

// This map simulates a database table where the key is the tweet's ID.
final Map<String, TweetModel> mockTweets = {
  't1': TweetModel(
    id: 't1',
    authorName: 'FlutterDev',
    authorUsername: '@flutterdev',
    authorAvatar: 'https://placehold.co/100x100/42A5F5/FFFFFF?text=F',
    createdAt: DateTime.now().subtract(const Duration(hours: 2)),
    content:
        'Just launched a new UI showcase for a Twitter-style app! 🚀\n\nBuilt with Flutter, it feels incredibly smooth. What do you all think?',
    images: [
      'https://images.unsplash.com/photo-1618401471353-b98afee0b2eb?q=80&w=2088',
    ],
    likes: 1200,
    retweets: 450,
    replies: 2,
    replyIds: ['t2', 't3'], // This tweet has two replies
  ),
  't2': TweetModel(
    id: 't2',
    replyToId: 't1', // This is a reply to t1
    authorName: 'Jane Doe',
    authorUsername: '@janedev',
    authorAvatar: 'https://placehold.co/100x100/E57373/FFFFFF?text=J',
    createdAt: DateTime.now().subtract(const Duration(hours: 1)),
    content:
        'This looks amazing! The animations are buttery smooth. Can you share the source code?',
    likes: 98,
    retweets: 5,
    replies: 1,
    replyIds: ['t4'], // This reply has its own reply
  ),
  't3': TweetModel(
    id: 't3',
    replyToId: 't1', // This is also a reply to t1
    authorName: 'Alex Smith',
    authorUsername: '@coderalex',
    authorAvatar: 'https://placehold.co/100x100/81C784/FFFFFF?text=A',
    createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
    content: 'Great work! What state management solution did you use for this?',
    likes: 76,
    retweets: 2,
  ),
  't4': TweetModel(
    id: 't4',
    replyToId: 't2', // This is a nested reply to t2
    authorName: 'FlutterDev',
    authorUsername: '@flutterdev',
    authorAvatar: 'https://placehold.co/100x100/42A5F5/FFFFFF?text=F',
    createdAt: DateTime.now().subtract(const Duration(minutes: 15)),
    content: 'Thanks! I used Riverpod. Source code coming soon!',
    likes: 45,
    retweets: 3,
  ),
};
