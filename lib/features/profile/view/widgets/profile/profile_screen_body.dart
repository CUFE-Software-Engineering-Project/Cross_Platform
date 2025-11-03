import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:lite_x/features/profile/models/profile_model.dart';
import 'package:lite_x/features/profile/models/profile_post_model.dart';
import 'package:lite_x/features/profile/models/shared.dart';
import 'package:lite_x/features/profile/view/widgets/profile/follow_following_button.dart';
import 'package:lite_x/features/profile/view/widgets/profile/profile_post_widget.dart';
import 'package:lite_x/features/profile/view/widgets/profile/profile_posts_list.dart';
import 'package:lite_x/features/profile/view_model/providers.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

class ProfileScreenBody extends ConsumerStatefulWidget {
  final ProfileModel profileData;
  final bool isMe;
  const ProfileScreenBody({
    super.key,
    required this.profileData,
    required this.isMe,
  });

  @override
  ConsumerState<ProfileScreenBody> createState() => _ProfileScreenBodyState();
}

class _ProfileScreenBodyState extends ConsumerState<ProfileScreenBody> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final posts = profilePosts
        .map(
          (post) => ProfilePostWidget(
            profilePostModel: post,
            profileModel: widget.profileData,
          ),
        )
        .toList();
    return DefaultTabController(
      length: widget.isMe ? 6 : 3,
      child: RefreshIndicator(
        onRefresh: () async {
          await ref.read(
              profileBasicDataNotifierProvider(
                widget.profileData.username,
              ).notifier,
            )
            ..loadProfileData(widget.profileData.username);
          setState(() {});
        },
        child: NestedScrollView(
          headerSliverBuilder: (context, bool innerBoxIsScrolled) {
            return <Widget>[
              SliverAppBar(
                floating: false,
                pinned: true,
                // snap: true,
                expandedHeight: 450,
                automaticallyImplyLeading: true,
                backgroundColor: Colors.black,
                elevation: 0,
                leading: Padding(
                  padding: const EdgeInsets.all(6.0),
                  child: TopIcon(
                    icon: Icons.arrow_back,
                    actionFunction: () {
                      if (context.canPop()) context.pop();
                    },
                  ),
                ),
                actions: [
                  TopIcon(icon: Icons.search_rounded, actionFunction: () {}),
                  SizedBox(width: 15),
                  TopIcon(icon: Icons.more_vert, actionFunction: () {}),
                  SizedBox(width: 6),
                ],

                flexibleSpace: FlexibleSpaceBar(
                  collapseMode: CollapseMode.pin,
                  title: null,

                  background: Stack(
                    children: [
                      Container(
                        height: 165,
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          image: widget.profileData.bannerUrl.isEmpty
                              ? null
                              : DecorationImage(
                                  image: NetworkImage(
                                    widget.profileData.bannerUrl,
                                  ),
                                ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 120),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    // TODO: add open profile page
                                  },
                                  child: CircleAvatar(
                                    radius: 45,
                                    backgroundColor: Colors.black,
                                    child: CircleAvatar(
                                      radius: 40,
                                      backgroundColor: Colors.black,
                                      backgroundImage: NetworkImage(
                                        widget.profileData.avatarUrl,
                                      ),
                                    ),
                                  ),
                                ),
                                widget.isMe
                                    ? Padding(
                                        padding: const EdgeInsets.only(top: 60),
                                        child: OutlinedButton(
                                          onPressed: () {
                                            context
                                                .push<EditProfileStatus>(
                                                  "/editProfile",
                                                  extra: widget.profileData,
                                                )
                                                .then((status) {
                                                  if (status ==
                                                      EditProfileStatus
                                                          .changedSuccessfully) {
                                                    ref.read(
                                                      profileBasicDataNotifierProvider(
                                                        widget
                                                            .profileData
                                                            .username,
                                                      ).notifier,
                                                    )..loadProfileData(
                                                      widget
                                                          .profileData
                                                          .username,
                                                    );
                                                  } else if (status ==
                                                      EditProfileStatus
                                                          .failedToChange) {
                                                    showTopSnackBar(
                                                      Overlay.of(context),
                                                      CustomSnackBar.error(
                                                        backgroundColor: Color(
                                                          0XFF212121,
                                                        ),
                                                        icon: Icon(
                                                          Icons.error,
                                                          color: Colors.red,
                                                        ),
                                                        message:
                                                            "Profile update failed",
                                                      ),
                                                      displayDuration:
                                                          const Duration(
                                                            seconds: 2,
                                                          ),
                                                    );
                                                  } else {}
                                                });
                                          },
                                          style: OutlinedButton.styleFrom(
                                            foregroundColor: Colors.white,
                                            side: const BorderSide(
                                              color: Color(0xFFADADAD),
                                              width: 1,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                            ),
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 15,
                                            ),
                                          ),
                                          child: Text(
                                            "Edit profile",
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ),
                                      )
                                    : Follow_Following_Button(
                                        profileData: widget.profileData,
                                      ),
                              ],
                            ),
                            const SizedBox(height: 5),
                            InkWell(
                              onTap: () {
                                //   TODO: ADD verifying logic
                              },
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    widget.profileData.displayName,
                                    style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  if (widget.isMe)
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const SizedBox(width: 4),
                                        const Icon(
                                          Icons.verified,
                                          color: Color(0xFF1DA1F2),
                                          size: 18,
                                        ),
                                        const SizedBox(width: 8),
                                        if (!widget.profileData.isVerified)
                                          Text(
                                            'Get Verified',
                                            style: TextStyle(
                                              color: Color(0xFF1DA1F2),
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                      ],
                                    ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 8),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.start,
                              textBaseline: TextBaseline.ideographic,
                              children: [
                                Text(
                                  "@${widget.profileData.username}",
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 15,
                                  ),
                                ),
                                SizedBox(width: 10),
                                if (widget.isMe == false &&
                                    widget.profileData.isFollower)
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 5,
                                    ),

                                    // width: 75,
                                    decoration: BoxDecoration(
                                      color: Color(0XFF1F2225),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          "Follows you",
                                          style: TextStyle(
                                            color: Color(0xFF6D7176),
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 8),

                            Text(
                              widget.profileData.bio,
                              style: const TextStyle(fontSize: 15),
                              maxLines: 3,
                            ),
                            if (widget.profileData.bio.isNotEmpty)
                              const SizedBox(height: 8),

                            Wrap(
                              runSpacing: 8,
                              children: [
                                if (widget.profileData.location.isNotEmpty)
                                  Wrap(
                                    children: [
                                      const Icon(
                                        Icons.location_on_outlined,
                                        color: Colors.grey,
                                        size: 16,
                                      ),
                                      const SizedBox(width: 1),
                                      Text(
                                        widget.profileData.location,
                                        style: const TextStyle(
                                          color: Colors.grey,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                    ],
                                  ),

                                if (widget.profileData.website.isNotEmpty)
                                  Wrap(
                                    children: [
                                      SvgPicture.asset(
                                        "assets/svg/website.svg",
                                        width: 16,
                                        height: 16,
                                        colorFilter: ColorFilter.mode(
                                          Colors.grey,
                                          BlendMode.srcIn,
                                        ),
                                      ),
                                      const SizedBox(width: 2),
                                      GestureDetector(
                                        onTap: () {
                                          // TODO: navigate the website
                                        },
                                        child: Text(
                                          widget.profileData.website,
                                          style: const TextStyle(
                                            color: Colors.blueAccent,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),

                                      const SizedBox(width: 12),
                                    ],
                                  ),

                                if (widget.profileData.birthDate.isNotEmpty)
                                  Wrap(
                                    children: [
                                      SvgPicture.asset(
                                        "assets/svg/born.svg",
                                        width: 16,
                                        height: 16,
                                        colorFilter: const ColorFilter.mode(
                                          Colors.grey,
                                          BlendMode.srcIn,
                                        ),
                                      ),
                                      const SizedBox(width: 1),
                                      Text(
                                        "Born ${widget.profileData.birthDate}",
                                        style: const TextStyle(
                                          color: Colors.grey,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                    ],
                                  ),
                                if (widget.profileData.joinedDate.isNotEmpty)
                                  Wrap(
                                    children: [
                                      const Icon(
                                        Icons.calendar_month_outlined,
                                        color: Colors.grey,
                                        size: 16,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        "Joined ${widget.profileData.joinedDate}",
                                        style: const TextStyle(
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                            const SizedBox(height: 12),

                            Row(
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    context.push(
                                      "/followingfollowersscreen/${FollowingFollowersInitialTab.Following}/${widget.isMe ? "me" : "notme"}",
                                      extra: this.widget.profileData,
                                    );
                                  },
                                  child: _buildFollowCount(
                                    widget.profileData.followingCount,
                                    'Following',
                                  ),
                                ),
                                const SizedBox(width: 16),
                                GestureDetector(
                                  onTap: () {
                                    //   TODO: navigae to followers page
                                    context.push(
                                      "/followingfollowersscreen/${FollowingFollowersInitialTab.Followers}/${widget.isMe ? "me" : "notme"}",
                                      extra: this.widget.profileData,
                                    );
                                  },
                                  child: _buildFollowCount(
                                    widget.profileData.followersCount,
                                    'Follower',
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(48.0),
                  child: Column(
                    children: [
                      TabBar(
                        indicatorColor: Color(0xFF1DA1F2),
                        indicatorSize: TabBarIndicatorSize.label,
                        isScrollable: true,
                        tabAlignment: TabAlignment.start,
                        dividerHeight: 0.25,
                        labelColor: Colors.white,
                        unselectedLabelStyle: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                        labelStyle: TextStyle(fontWeight: FontWeight.bold),
                        unselectedLabelColor: Colors.grey,
                        tabs: [
                          Tab(text: 'Posts'),
                          Tab(text: 'Replies'),
                          if (widget.isMe == true) Tab(text: 'Highlights'),
                          if (widget.isMe) Tab(text: 'Articles'),
                          Tab(text: 'Media'),
                          if (widget.isMe) Tab(text: 'Likes'),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ];
          },

          body: TabBarView(
            children: [
              // ProfilePostsList(profile: widget.profileData), // posts
              RefreshIndicator(
                onRefresh: () async {
                  ref.read(
                    profileBasicDataNotifierProvider(
                      widget.profileData.username,
                    ).notifier,
                  )..loadProfileData(widget.profileData.username);
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
                      color: Colors.grey,
                    );
                  },
                ),
              ),
              const Center(child: Text("Replies Tab Content")), // Replies
              if (widget.isMe) _buildHilightsTab(), // Highlights
              if (widget.isMe) _buildArticlesTab(), // Articles
              const Center(child: Text("Media Tab Content")), // Media
              if (widget.isMe)
                const Center(child: Text("Likes Tab Content")), // Likes
            ],
          ),
        ),
      ),
    );
  }
}

class TopIcon extends StatelessWidget {
  const TopIcon({super.key, required this.icon, required this.actionFunction});
  final IconData icon;
  final Function actionFunction;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        actionFunction();
      },
      child: CircleAvatar(
        child: Icon(icon, color: Colors.white, size: 25),
        backgroundColor: Colors.black.withValues(alpha: 0.5),
        radius: 20,
      ),
    );
  }
}

Widget _buildFollowCount(int count, String label) {
  String formatedCount = Shared.formatCount(count);

  return RichText(
    text: TextSpan(
      children: [
        TextSpan(
          text: formatedCount + " ",
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        TextSpan(
          text: label,
          style: const TextStyle(color: Colors.grey, fontSize: 16),
        ),
      ],
    ),
  );
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

String mapMonth(int month) {
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  if (month < 1 || month > 12) return '';
  return months[month - 1];
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
];

final List<ProfilePostModel> profilePosts = rawPostData
    .map((json) => ProfilePostModel.fromJson(json))
    .toList();
