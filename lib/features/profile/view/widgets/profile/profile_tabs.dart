import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lite_x/features/profile/models/profile_model.dart';
import 'package:lite_x/features/profile/models/profile_tweet_model.dart';
import 'package:lite_x/features/profile/view/widgets/profile_tweets/profile_likes_tap.dart';
import 'package:lite_x/features/profile/view/widgets/profile_tweets/profile_media_tap.dart';
import 'package:lite_x/features/profile/view/widgets/profile_tweets/profile_normal_tweet_widget.dart';
import 'package:lite_x/features/profile/view/widgets/profile_tweets/profile_posts_tab.dart';
import 'package:lite_x/features/profile/view_model/providers.dart';

class ProfileTabs extends ConsumerWidget {
  const ProfileTabs({super.key, required this.isMe, required this.profileData});
  final bool isMe;
  final ProfileModel profileData;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: isMe ? 6 : 3,
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 0,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(48.0),
            child: TabBar(
              indicatorColor: Color(0xFF1DA1F2),
              indicatorSize: TabBarIndicatorSize.label,
              isScrollable: isMe ? true : false,
              tabAlignment: isMe ? TabAlignment.start : TabAlignment.fill,
              dividerHeight: 0.25,
              labelColor: Colors.white,
              unselectedLabelStyle: TextStyle(fontWeight: FontWeight.bold),
              labelStyle: TextStyle(fontWeight: FontWeight.bold),
              unselectedLabelColor: Colors.grey,
              tabs: [
                Tab(text: 'Posts'),
                Tab(text: 'Replies'),
                if (isMe == true) Tab(text: 'Highlights'),
                if (isMe) Tab(text: 'Articles'),
                Tab(text: 'Media'),
                if (isMe) Tab(text: 'Likes'),
              ],
            ),
          ),
        ),
        body: TabBarView(
          children: [
            ProfilePostsTab(profileModel: this.profileData),
            _buildRepliesTab(), // Replies
            if (isMe) _buildHilightsTab(), // Highlights
            if (isMe) _buildArticlesTab(), // Articles
            ProfileMediaTap(profileModel: this.profileData), // Media
            if (isMe) ProfileLikesTap(profileModel: this.profileData), // Likes
          ],
        ),
      ),
    );
  }
}

Widget _buildHilightsTab() {
  return Container(
    padding: EdgeInsets.only(top: 40, left: 40, right: 60),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Verified only",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 28),
        ),
        SizedBox(height: 10),
        Text(
          "You must be verified to highlight posts on your profile.",
          style: TextStyle(color: Colors.grey),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 25),
          child: ElevatedButton(
            onPressed: () {
              //   TODO: open verifying screen
            },
            child: Text(
              "Get verified",
              style: TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              padding: EdgeInsets.all(15),
            ),
          ),
        ),
      ],
    ),
  );
}

Widget _buildArticlesTab() {
  return Container(
    padding: EdgeInsets.only(top: 40, left: 40, right: 60),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Write Articles on X",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 28),
        ),
        SizedBox(height: 10),
        Text(
          "When you publish an Article on x.com it will show up here. Only Premium+ subscribers can publish Articles.",
          style: TextStyle(color: Colors.grey),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 25),
          child: ElevatedButton(
            onPressed: () {
              //   TODO: open Premium subscribing screen
            },
            child: Text(
              "Subscribe to premium+",
              style: TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              padding: EdgeInsets.all(15),
            ),
          ),
        ),
      ],
    ),
  );
}

Widget _buildRepliesTab() {
  return ListView(
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
  );
}
