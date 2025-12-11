import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lite_x/features/profile/models/profile_model.dart';
import 'package:lite_x/features/profile/models/profile_tweet_model.dart';
import 'package:lite_x/features/profile/models/shared.dart';
import 'package:lite_x/features/profile/models/user_model.dart';
import 'package:lite_x/features/profile/view/widgets/following_followers/follower_card.dart';
import 'package:lite_x/features/profile/view/widgets/profile_tweets/profile_normal_tweet_widget.dart'
    hide Padding;
import 'package:lite_x/features/profile/view/widgets/profile_tweets/profile_quote_widget.dart';
import 'package:lite_x/features/profile/view/widgets/profile_tweets/profile_retweet_widget.dart';
import 'package:lite_x/features/profile/view_model/providers.dart';
import 'package:lite_x/features/trends/models/trend_category.dart';
import 'package:lite_x/features/trends/models/trend_model.dart';
import 'package:lite_x/features/trends/view/widgets/trend_tile.dart';

class CategoryProfileTrendTab extends ConsumerWidget {
  const CategoryProfileTrendTab({
    Key? key,
    required this.pm,
    required this.categoryName,
  }) : super(key: key);
  final ProfileModel pm;
  final String categoryName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncData = ref.watch(trendCategoryProvider(this.categoryName));
    return asyncData.when(
      data: (res) {
        return res.fold(
          (l) {
            return ListView(
              padding: EdgeInsets.only(top: 50),
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              children: [
                Center(child: Text(l.message)),
                Center(
                  child: IconButton(
                    onPressed: () async {
                      // ignore: unused_result
                      ref.refresh(trendCategoryProvider(this.categoryName));
                    },
                    icon: Icon(Icons.refresh),
                  ),
                ),
              ],
            );
          },
          (data) {
            return RefreshIndicator(
              onRefresh: () async {
                // ignore: unused_result
                await ref.refresh(trendCategoryProvider(this.categoryName));
              },
              child: ListView(
                children: data.trends.isEmpty && data.viralTweets.isEmpty
                    ? [
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
                      ]
                    : [
                        if (data.viralTweets.length > 0) SizedBox(height: 20),
                        if (data.viralTweets.length > 0)
                          _buildTweetsSection(data.viralTweets, pm),
                        if (data.viralTweets.length > 0)
                          Container(
                            width: double.infinity,
                            height: 0.5,
                            color: Colors.grey,
                          ),
                        if (data.viralTweets.length > 0) SizedBox(height: 20),
                        _buildTredsSection(data, 30),
                      ],
              ),
            );
          },
        );
      },
      error: (err, _) {
        return ListView(
          padding: EdgeInsets.only(top: 50),
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          children: [
            Center(
              child: Text("Can't get Trends at this time, Try again Later..."),
            ),
            Center(
              child: IconButton(
                onPressed: () async {
                  // ignore: unused_result
                  ref.refresh(trendCategoryProvider(this.categoryName));
                },
                icon: Icon(Icons.refresh),
              ),
            ),
          ],
        );
      },
      loading: () {
        return SingleChildScrollView(
          padding: EdgeInsets.all(20),
          child: Center(child: CircularProgressIndicator()),
        );
      },
    );
  }

  Widget _buildTredsSection(TrendCategory category, int limit) {
    return ListView.builder(
      padding: EdgeInsets.only(left: 16),
      physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemBuilder: (context, index) {
        return TrendTile(
          trend: category.trends[index],
          trendCategory: category.categoryName.length >= 2
              ? "${category.categoryName[0].toUpperCase()}${category.categoryName.substring(1)}"
              : "",
          showRank: false,
        );
      },
      itemCount: category.trends.length <= limit
          ? category.trends.length
          : limit,
    );
  }

  Widget _buildTweetsSection(List<ProfileTweetModel> tweets, ProfileModel pm) {
    if (tweets.isEmpty) {
      return SizedBox.shrink();
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListView.separated(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            TweetType type = tweets[index].type;
            if (type == TweetType.ReTweet)
              return ProfileRetweetWidget(
                profileModel: pm,
                tweetModel: tweets[index],
              );

            if (type == TweetType.Quote)
              return ProfileQuoteWidget(
                tweetModel: tweets[index],
                profileModel: pm,
              );

            return ProfileNormalTweetWidget(
              profileModel: pm,
              profilePostModel: tweets[index],
            );
          },
          itemCount: tweets.length <= 5 ? tweets.length : 5,
          separatorBuilder: (context, index) {
            return Container(
              width: double.infinity,
              height: 0.5,
              color: Colors.grey,
            );
          },
        ),
      ],
    );
  }
}
