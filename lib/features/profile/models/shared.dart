import 'package:flutter/material.dart';
import 'package:lite_x/features/profile/models/profile_model.dart';
import 'package:lite_x/features/profile/models/profile_tweet_model.dart';
import 'package:lite_x/features/profile/view/widgets/profile_tweets/profile_normal_tweet_widget.dart';
import 'package:lite_x/features/profile/view/widgets/profile_tweets/profile_retweet_widget.dart';

abstract class Shared {
  static String formatCount(int count) {
    String formatedCount;
    if (count < 1000)
      formatedCount = "$count";
    else if (count >= 1000 && count < 1000000) {
      if (count % 1000 == 0)
        formatedCount = "${(count / 1000)}K";
      else
        formatedCount = "${(count / 1000).toStringAsFixed(1)}K";
    } else {
      if (count % 1000000 == 0)
        formatedCount = "${count / 1000000}M";
      else
        formatedCount = "${(count / 1000000).toStringAsFixed(1)}M";
    }
    return formatedCount;
  }
}

class Failure {
  final String message;
  Failure(this.message);
}

class FollowingFollowersInitialTab {
  static const int VerifiedFollowers = 0;
  static const int FollowersYouKnow = 1;
  static const int Followers = 2;
  static const int Following = 3;
  static const int Subscribed = 4;
  static const int Subscriptions = 5;
}

Future<bool> showUnFollowDialog(
  BuildContext context,
  String nameOfUnfollowedUser,
) async {
  final result = await showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        backgroundColor: Color(0xFF0f0f0f),
        title: Text(
          'Unfollow ${nameOfUnfollowedUser}?',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'Their posts will no longer show up in your home timeline. You can still view their profile, unless their posts are protected.',
          style: TextStyle(fontSize: 14, color: Colors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              // your unfollow logic
              Navigator.of(context).pop(true);
            },
            child: const Text(
              'Unfollow',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      );
    },
  );

  return result;
}

enum EditProfileStatus { changedSuccessfully, unChanged, failedToChange }

enum DateFormatType { monthAndDayOnly, yearOnly, fullDate }

String mapMonth(int month) {
  const months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];
  return months[month - 1];
}

String formatDate(DateTime? date, DateFormatType type) {
  if (date == null) return "";
  switch (type) {
    case DateFormatType.monthAndDayOnly:
      return "${mapMonth(date.month)} ${date.day}";
    case DateFormatType.yearOnly:
      return "${date.year}";
    case DateFormatType.fullDate:
      return "${mapMonth(date.month)} ${date.day}, ${date.year}";
  }
}

DateTime? parseFormattedDate(String formattedDate) {
  if (formattedDate.isEmpty) return null;
  final months = {
    'January': 1,
    'February': 2,
    'March': 3,
    'April': 4,
    'May': 5,
    'June': 6,
    'July': 7,
    'August': 8,
    'September': 9,
    'October': 10,
    'November': 11,
    'December': 12,
  };

  final regex = RegExp(r'([A-Za-z]+)\s(\d{1,2}),\s(\d{4})');
  final match = regex.firstMatch(formattedDate);
  if (match == null) {
    return null;
  }

  final monthName = match.group(1)!;
  final day = int.parse(match.group(2)!);
  final year = int.parse(match.group(3)!);
  final month = months[monthName]!;

  return DateTime(year, month, day);
}

Future<bool?> showPopupMessage({
  required BuildContext context,
  required Text title,
  required Text message,
  String confirmText = 'Yes',
  String cancelText = 'No',
}) async {
  return showDialog<bool>(
    context: context,
    barrierDismissible: true, // prevent closing by tapping outside
    builder: (BuildContext context) {
      return AlertDialog(
        title: title,
        content: message,
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              cancelText,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              confirmText,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      );
    },
  );
}

class ProfilePhotoScreenArgs {
  final bool isMe;
  final ProfileModel profileModel;

  ProfilePhotoScreenArgs({required this.isMe, required this.profileModel});
}

enum TweetType { Tweet, ReTweet, Quote, Reply }

abstract class ProfileTweet implements Widget {}

ProfileTweet getCorrectTweetType(
  ProfileTweetModel tweetModel,
  ProfileModel pm,
) {
  TweetType type = tweetModel.type;

  if (type == TweetType.ReTweet)
    return ProfileRetweetWidget(profileModel: pm, tweetModel: tweetModel);

  return ProfileNormalTweetWidget(
    profileModel: pm,
    profilePostModel: tweetModel,
  );
}

void showSmallPopUpMessage({
  required BuildContext context,
  required String message,
  required Color borderColor,
  required Icon icon,
}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            icon,
            SizedBox(width: 10),
            Flexible(
              child: Text(
                message,
                style: TextStyle(fontSize: 16),
                overflow: TextOverflow.clip,
              ),
            ),
          ],
        ),
      ),
      duration: Duration(seconds: 2),
      behavior: SnackBarBehavior.floating,
      margin: EdgeInsets.all(30),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(width: 0.8, color: borderColor),
      ),
    ),
  );
}

String getTimeAgo(String backendTime) {
  try {
    DateTime postTime = DateTime.parse(backendTime);
    DateTime currentTime = DateTime.now().toUtc();
    Duration difference = currentTime.difference(postTime);

    if (difference.isNegative) {
      return 'now';
    }

    int seconds = difference.inSeconds;

    if (seconds < 60) {
      return '${seconds}s';
    }

    int minutes = difference.inMinutes;
    if (minutes < 60) {
      return '${minutes}m';
    }

    int hours = difference.inHours;
    if (hours < 24) {
      return '${hours}h';
    }

    int days = difference.inDays;
    if (days < 7) {
      return '${days}d';
    }

    if (days < 30) {
      int weeks = (days / 7).floor();
      return '${weeks}w';
    }

    if (days < 365) {
      int months = (days / 30).floor();
      return '${months}mo';
    }

    int years = (days / 365).floor();
    return '${years}y';
  } catch (e) {
    return 'now';
  }
}
