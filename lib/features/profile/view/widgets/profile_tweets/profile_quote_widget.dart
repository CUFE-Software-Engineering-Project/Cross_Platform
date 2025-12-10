import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lite_x/features/profile/models/profile_model.dart';
import 'package:lite_x/features/profile/models/profile_tweet_model.dart';
import 'package:lite_x/features/profile/models/shared.dart';
import 'package:lite_x/features/profile/view/widgets/profile_tweets/profile_normar_tweet_quot.dart'
    hide InterActionsRowOfTweet;
import 'package:lite_x/features/profile/view_model/providers.dart';

class ProfileQuoteWidget extends ConsumerWidget implements ProfileTweet {
  const ProfileQuoteWidget({
    super.key,
    required this.tweetModel,
    required this.profileModel,
  });
  final ProfileModel profileModel;
  final ProfileTweetModel tweetModel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final paredTweet = ref.watch(
      profileTweetProvider(this.tweetModel.parentId),
    );
    return Column(
      children: [
        ProfileNormarTweetQuot(
          profileModel: profileModel,
          profilePostModel: this.tweetModel,
        ),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(12),
          ),
          margin: EdgeInsets.only(left: 20, right: 5, top: 5, bottom: 10),
          child: paredTweet.when(
            data: (res) {
              return res.fold(
                (l) {
                  return ListView(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    children: [
                      SizedBox(height: 5),
                      Center(child: Text(l.message)),
                      IconButton(
                        onPressed: () async {
                          // ignore: unused_result
                          ref.refresh(
                            profileTweetProvider(this.tweetModel.parentId),
                          );
                        },
                        icon: Icon(Icons.refresh, color: Colors.white),
                      ),
                    ],
                  );
                },
                (r) {
                  return ProfileNormarTweetQuot(
                    profileModel: profileModel,
                    profilePostModel: r,
                  );
                },
              );
            },
            error: ((err, _) {
              return Center(child: Text("Can't get parent tweet"));
            }),
            loading: (() {
              return Center(
                child: CircularProgressIndicator(color: Colors.white),
              );
            }),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(
            right: 5,
            left: 20,
          ).copyWith(bottom: 5),
          child: InterActionsRowOfTweet(tweet: this.tweetModel),
        ),
      ],
    );
  }
}
