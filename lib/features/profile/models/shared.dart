import 'package:flutter/material.dart';

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

enum EditProfileStatus {
  changedSuccessfully,
  unChanged,
  failedToChange,
}
