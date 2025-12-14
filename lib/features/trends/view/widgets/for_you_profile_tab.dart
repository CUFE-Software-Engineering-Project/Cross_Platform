import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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

class ForYouProfileTab extends ConsumerWidget {
  const ForYouProfileTab({Key? key, required this.pm}) : super(key: key);
  final ProfileModel pm;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncData = ref.watch(forYouTrendsProvider);
    final asyncTrends = ref.watch(profileTrendsProvider);
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
                      ref.refresh(forYouTrendsProvider);
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
                ref.invalidate(forYouTrendsProvider);
                // Optionally wait for the new data
                await ref.read(forYouTrendsProvider.future);
              },
              child: ListView(
                children: [
                  asyncTrends.when(
                    data: (res) => res.fold(
                      (l) => SizedBox.shrink(),
                      (r) => _buildTredsSection(r),
                    ),
                    error: (err, _) => SizedBox.shrink(),
                    loading: () => SizedBox.shrink(),
                  ),
                  _buildWhoToFollowSection(data.suggestedUsers, context),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) =>
                        _buildCategorySection(data.categories[index], pm),
                    itemCount: data.categories.length,
                  ),
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
                  ref.refresh(forYouTrendsProvider);
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

  Widget _buildTredsSection(List<TrendModel> trends) {
    return ListView.builder(
      padding: EdgeInsets.only(left: 16),
      physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () {
            context.push(
              "/hashtagTweetsScreen",
              extra: [trends[index].id, trends[index].title],
            );
          },
          child: TrendTile(
            trend: trends[index],
            trendCategory: "ُEgypt",
            showRank: false,
          ),
        );
      },
      itemCount: trends.length <= 6 ? trends.length : 6,
    );
  }

  Widget _buildWhoToFollowSection(List<UserModel> users, BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(height: 0.2, color: Colors.grey),
        Padding(
          padding: EdgeInsets.only(left: 16, top: 5),
          child: Text(
            "Who to Follow",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) =>
                  FollowerCard(user: users[index], isMe: true),
              itemCount: users.length <= 5 ? users.length : 5,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 16, bottom: 16),
              child: GestureDetector(
                onTap: () {
                  // TODO: go to who to follow screen
                  // context.push();
                  context.push("/whoToFollowScreen");
                },
                child: Text("Show more", style: TextStyle(color: Colors.blue)),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCategorySection(TrendCategory category, ProfileModel pm) {
    List<ProfileTweetModel> filteredData = category.viralTweets;

    if (filteredData.isEmpty) {
      return SizedBox.shrink();
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(width: double.infinity, height: 0.25, color: Colors.grey),
        Padding(
          padding: const EdgeInsets.only(left: 16, top: 10, bottom: 10),
          child: Text(
            category.categoryName.length >= 2
                ? "${category.categoryName[0].toUpperCase()}${category.categoryName.substring(1)} Trends"
                : "",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
          ),
        ),
        ListView.separated(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            TweetType type = filteredData[index].type;
            if (type == TweetType.ReTweet)
              return ProfileRetweetWidget(
                profileModel: pm,
                tweetModel: filteredData[index],
              );

            if (type == TweetType.Quote)
              return ProfileQuoteWidget(
                tweetModel: filteredData[index],
                profileModel: pm,
              );

            return ProfileNormalTweetWidget(
              profileModel: pm,
              profilePostModel: filteredData[index],
            );
          },
          itemCount: filteredData.length <= 5 ? filteredData.length : 5,
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
