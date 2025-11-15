import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lite_x/features/profile/models/profile_model.dart';
import 'package:lite_x/features/profile/models/profile_post_model.dart';
import 'package:lite_x/features/profile/view/widgets/profile/profile_post_widget.dart';
import 'package:lite_x/features/profile/view_model/providers.dart';

class ProfileTabs extends ConsumerWidget {
  const ProfileTabs({super.key, required this.isMe, required this.profileData});
  final bool isMe;
  final ProfileModel profileData;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final posts = profilePosts
        .map(
          (post) => ProfilePostWidget(
            profilePostModel: post,
            profileModel: profileData,
          ),
        )
        .toList();
    return DefaultTabController(
      length: isMe ? 6 : 3,
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(48.0),
          child: TabBar(
            indicatorColor: Color(0xFF1DA1F2),
            indicatorSize: TabBarIndicatorSize.label,
            isScrollable: true,
            tabAlignment: TabAlignment.start,
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
        body: TabBarView(
          children: [
            // ProfilePostsList(profile: widget.profileData), // posts
            RefreshIndicator(
              onRefresh: () async {
                ref.read(
                  profileBasicDataNotifierProvider(
                    profileData.username,
                  ).notifier,
                )..loadProfileData(profileData.username);
              },
              child: ListView.separated(
                itemBuilder: (context, index) {
                  return posts[index];
                },
                itemCount: posts.length,
                separatorBuilder: (context, index) {
                  return Container(
                    width: double.infinity,
                    height: 0.5,
                    color: const Color.fromARGB(255, 110, 79, 79),
                  );
                },
              ),
            ),
            const Center(child: Text("Replies Tab Content")), // Replies
            if (isMe) _buildHilightsTab(), // Highlights
            if (isMe) _buildArticlesTab(), // Articles
            const Center(child: Text("Media Tab Content")), // Media
            if (isMe) const Center(child: Text("Likes Tab Content")), // Likes
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

final List<Map<String, dynamic>> rawPostData = [
  {
    "id": "post_001",
    "text": "Excited to share my latest project! Flutter makes UI development",
    "timeAgo": "5m",
    "likes": 25,
    "retweets": 8,
    "repost": 50,
    "replies": 3,
    "isLiked": false,
    "activityNumber": 36,
    "mediaUrls": [
      "https://images.pexels.com/photos/34188568/pexels-photo-34188568.jpeg",
      "https://images.pexels.com/photos/34182536/pexels-photo-34182536.jpeg",
      "https://images.pexels.com/photos/34182536/pexels-photo-34182536.jpeg",
      "https://media.istockphoto.com/id/158002966/photo/painted-x-mark.jpg?b=1&s=612x612&w=0&k=20&c=W-XB39kzx5Y1U5eHU7gBZzgd4k2oqo0G3bRrch3jUZk=",
    ],
  },
  {
    "id": "post_002",
    "text":
        "A quick update on the server migration: everything went smoothly! Downtime was minimal. Thanks to the team!",
    "timeAgo": "2h",
    "likes": 120,
    "retweets": 8,
    "replies": 10,
    "isLiked": true,
    "activityNumber": 20,
    "mediaUrls": [
      "https://media.istockphoto.com/id/158002966/photo/painted-x-mark.jpg?b=1&s=612x612&w=0&k=20&c=W-XB39kzx5Y1U5eHU7gBZzgd4k2oqo0G3bRrch3jUZk=",
    ],
  },
  {
    "id": "post_002",
    "text":
        "A quick update on the server migration: everything went smoothly! Downtime was minimal. Thanks to the team!",
    "timeAgo": "2h",
    "likes": 120,
    "retweets": 8,
    "replies": 10,
    "isLiked": true,
    "activityNumber": 20,
    "mediaUrls": [
      "https://media.istockphoto.com/id/158002966/photo/painted-x-mark.jpg?b=1&s=612x612&w=0&k=20&c=W-XB39kzx5Y1U5eHU7gBZzgd4k2oqo0G3bRrch3jUZk=",
    ],
  },
];

final List<ProfilePostModel> profilePosts = rawPostData
    .map((json) => ProfilePostModel.fromJson(json))
    .toList();
