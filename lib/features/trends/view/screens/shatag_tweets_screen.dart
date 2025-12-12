import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lite_x/features/profile/models/profile_model.dart';
import 'package:lite_x/features/profile/models/profile_tweet_model.dart';
import 'package:lite_x/features/profile/models/shared.dart';
import 'package:lite_x/features/profile/view_model/providers.dart';
import 'package:lite_x/features/trends/models/trend_model.dart';

class HashtagTweetsScreen extends ConsumerWidget {
  HashtagTweetsScreen({super.key, required dynamic list}) {
    trend = list[0];
    pm = list[1];
  }
  late final TrendModel trend;
  late final ProfileModel pm;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncTweets = ref.watch(hashtagTweetsProvider(trend.id));

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          onPressed: () {
            if (context.canPop()) context.pop();
          },
        ),
        title: Text(
          "#${trend.title}",
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: asyncTweets.when(
        data: (res) {
          return res.fold(
            (l) {
              return ListView(
                padding: EdgeInsets.all(20),
                children: [
                  Center(child: Text(l.message)),
                  GestureDetector(
                    child: Icon(Icons.refresh),
                    onTap: () async {
                      // ignore: unused_result
                      await ref.refresh(hashtagTweetsProvider(trend.id));
                    },
                  ),
                ],
              );
            },
            (data) {
              final List<ProfileTweetModel> tweets = data;
              if (tweets.isEmpty) {
                return RefreshIndicator(
                  onRefresh: () async {
                    // ignore: unused_result
                    ref.refresh(hashtagTweetsProvider(trend.id));
                  },
                  child: ListView(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(
                          "Nothing to see here -- yet.",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 35,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }

              final List<ProfileTweet> posts = tweets.map((post) {
                return getCorrectTweetType(post, this.pm);
              }).toList();
              return RefreshIndicator(
                onRefresh: () async {
                  // ignore: unused_result
                  ref.refresh(hashtagTweetsProvider(trend.id));
                },
                child: ListView.separated(
                  cacheExtent: 2000,
                  itemBuilder: (context, index) {
                    return posts[index];
                  },
                  itemCount: posts.length,
                  separatorBuilder: (context, index) {
                    return Container(
                      width: double.infinity,
                      height: 0.5,
                      color: Colors.grey,
                    );
                  },
                ),
              );
            },
          );
        },
        error: (err, _) {
          return ListView(
            padding: EdgeInsets.all(20),
            children: [
              Center(child: Text(err.toString())),
              GestureDetector(
                child: Icon(Icons.refresh),
                onTap: () async {
                  // ignore: unused_result
                  await ref.refresh(hashtagTweetsProvider(trend.id));
                },
              ),
            ],
          );
        },
        loading: () {
          return ListView(
            padding: EdgeInsets.all(20),
            children: [Center(child: CircularProgressIndicator())],
          );
        },
      ),
    );
  }
}
