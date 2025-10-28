import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:lite_x/core/routes/Route_Constants.dart';
import 'package:lite_x/features/profile/models/profile_model.dart';
import 'package:lite_x/features/profile/models/shared.dart';
import 'package:lite_x/features/profile/view/screens/edit_profile_screen.dart';
import 'package:lite_x/features/profile/view/widgets/profile_posts_list.dart';

class ProfileScreenBody extends StatelessWidget {
  final ProfileModel profileData;
  const ProfileScreenBody({super.key, required this.profileData});

  @override
  Widget build(BuildContext context) {
    return NestedScrollView(
      headerSliverBuilder: (context, bool innerBoxIsScrolled) {
        return <Widget>[
          SliverAppBar(
            floating: true,
            pinned: true,
            snap: false,
            expandedHeight: 450,
            backgroundColor: Colors.black,
            elevation: 0,
            leading: Padding(
              padding: const EdgeInsets.all(6.0),
              child: TopIcon(icon: Icons.arrow_back, actionFunction: () {}),
            ),
            actions: [
              TopIcon(icon: Icons.search_rounded, actionFunction: () {}),
              SizedBox(width: 15),
              TopIcon(icon: Icons.more_vert, actionFunction: () {}),
              SizedBox(width: 6),
            ],

            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.pin,
              title: innerBoxIsScrolled
                  ? Text(
                      profileData.displayName,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    )
                  : null,

              background: Stack(
                children: [
                  Container(
                    height: 165,
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      image: profileData.bannerUrl.isEmpty
                          ? null
                          : DecorationImage(
                              image: NetworkImage(profileData.bannerUrl),
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
                                    profileData.avatarUrl,
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 60),
                              child: OutlinedButton(
                                onPressed: () {
                                  context.go(
                                    "/editProfile",
                                    extra: profileData,
                                  );
                                },
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  side: const BorderSide(
                                    color: Color(0xFFADADAD),
                                    width: 1,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
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
                                profileData.displayName,
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(
                                Icons.verified,
                                color: Color(0xFF1DA1F2),
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              if (!profileData.isVerified)
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
                        ),

                        const SizedBox(height: 8),
                        Text(
                          profileData.username,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 8),

                        Text(
                          profileData.bio,
                          style: const TextStyle(fontSize: 16),
                          maxLines: 3,
                        ),
                        if (profileData.bio.isNotEmpty)
                          const SizedBox(height: 8),

                        Wrap(
                          runSpacing: 8,
                          children: [
                            if (profileData.location.isNotEmpty)
                              Wrap(
                                children: [
                                  const Icon(
                                    Icons.location_on_outlined,
                                    color: Colors.grey,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 1),
                                  Text(
                                    profileData.location,
                                    style: const TextStyle(color: Colors.grey),
                                  ),
                                  const SizedBox(width: 12),
                                ],
                              ),

                            if (profileData.website.isNotEmpty)
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
                                      profileData.website,
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

                            if (profileData.birthDate.isNotEmpty)
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
                                    "Born ${profileData.birthDate}",
                                    style: const TextStyle(color: Colors.grey),
                                  ),
                                  const SizedBox(width: 12),
                                ],
                              ),
                            if (profileData.joinedDate.isNotEmpty)
                              Wrap(
                                children: [
                                  const Icon(
                                    Icons.calendar_month_outlined,
                                    color: Colors.grey,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    "Joined ${profileData.joinedDate}",
                                    style: const TextStyle(color: Colors.grey),
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
                                // TODO: navigate to following page
                              },
                              child: _buildFollowCount(
                                profileData.followingCount,
                                'Following',
                              ),
                            ),
                            const SizedBox(width: 16),
                            GestureDetector(
                              onTap: () {
                                //   TODO: navigae to followers page
                              },
                              child: _buildFollowCount(
                                profileData.followersCount,
                                'Follower',
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 10,
                        ), // المسافة قبل بداية الـ TabBar
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
                  const TabBar(
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
                      Tab(text: 'Highlights'),
                      Tab(text: 'Articles'),
                      Tab(text: 'Media'),
                      Tab(text: 'Likes'),
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
          ProfilePostsList(profile: profileData), // posts
          const Center(child: Text("Replies Tab Content")), // Replies
          _buildHilightsTab(), // Highlights
          _buildArticlesTab(), // Articles
          const Center(child: Text("Media Tab Content")), // Media
          const Center(child: Text("Likes Tab Content")), // Likes
        ],
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
