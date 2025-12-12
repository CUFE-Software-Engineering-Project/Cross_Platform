import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lite_x/core/providers/current_user_provider.dart';
import 'package:lite_x/features/profile/models/profile_model.dart';
import 'package:lite_x/features/profile/models/profile_tweet_model.dart';
import 'package:lite_x/features/profile/models/shared.dart';
import 'package:lite_x/features/profile/view/widgets/profile_tweets/profile_normal_tweet_widget.dart';
import 'package:lite_x/features/profile/view/widgets/profile_tweets/profile_quote_widget.dart';

class ProfileRetweetWidget extends ConsumerWidget implements ProfileTweet {
  const ProfileRetweetWidget({
    super.key,
    required this.tweetModel,
    required this.profileModel,
  });
  final ProfileModel profileModel;
  final ProfileTweetModel tweetModel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currUser = ref.read(currentUserProvider);
    bool myRetweet = false;
    if (currUser != null && currUser.username == tweetModel.retweeterUserName)
      myRetweet = true;
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.only(left: 40, top: 10),
          child: Row(
            children: [
              RotatedBox(
                quarterTurns: 1,
                child: Icon(
                  Icons.repeat,
                  weight: 10,
                  size: 17,
                  color: Colors.grey,
                ),
              ),
              SizedBox(width: 5),
              Text(
                "${myRetweet ? "You" : this.tweetModel.retweeterName} reposted",
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        tweetModel.type == TweetType.Quote
            ? ProfileQuoteWidget(
                tweetModel: tweetModel,
                profileModel: this.profileModel,
              )
            : ProfileNormalTweetWidget(
                profileModel: this.profileModel,
                profilePostModel: this.tweetModel,
              ),
      ],
    );
  }
}
