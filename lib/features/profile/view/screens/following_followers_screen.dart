import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lite_x/features/profile/models/profile_model.dart';
import 'package:lite_x/features/profile/view/widgets/following_followers/followers_tab.dart';
import 'package:lite_x/features/profile/view/widgets/following_followers/followers_you_know_tab.dart';
import 'package:lite_x/features/profile/view/widgets/following_followers/following_tab.dart';
import 'package:lite_x/features/profile/view/widgets/following_followers/subscribed_tab.dart';
import 'package:lite_x/features/profile/view/widgets/following_followers/verified_followers.dart';

class FollowingFollowersScreen extends StatefulWidget {
  final int initialIndex;
  late final bool isMeBool;
  final ProfileModel profileModel;
  FollowingFollowersScreen({
    Key? key,
    required String isMe,
    required this.profileModel,
    this.initialIndex = 0,
  }) : super(key: key) {
    isMeBool = isMe == 'me' ? true : false;
    print(isMe);
  }
  @override
  State<FollowingFollowersScreen> createState() =>
      _FollowingFollowersScreenState();
}

class _FollowingFollowersScreenState extends State<FollowingFollowersScreen>
    with SingleTickerProviderStateMixin {
  late final String displayName;

  late final String username;

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    username = widget.profileModel.username;
    displayName = widget.profileModel.displayName;
    _tabController = TabController(
      length: widget.isMeBool ? 6 : 4,
      vsync: this,
      initialIndex: widget.initialIndex,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 6,
      child: Scaffold(
        appBar: AppBar(
          centerTitle: false,
          title: Text(
            displayName,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              }
            },
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.person_add_alt_1_outlined),
              onPressed: () {
                // TODO: Implement action
              },
            ),
            SizedBox(width: 10),
          ],
          bottom: TabBar(
            controller: _tabController,
            indicatorColor: Color(0xFF1DA1F2),
            indicatorSize: TabBarIndicatorSize.label,
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            dividerHeight: 0.1,
            labelColor: Colors.white,
            unselectedLabelStyle: TextStyle(fontSize: 16),
            labelStyle: TextStyle(fontWeight: FontWeight.bold),
            unselectedLabelColor: Colors.grey,
            tabs: widget.isMeBool
                ? _tapBarTitlesList_myProfile
                : _tapBarTitlesList_otherProfile,
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            VerifiedFollowersTab(
              isMe: widget.isMeBool,
              username: widget.profileModel.username,
            ),
            FollowersYouKnowTab(
              isMe: widget.isMeBool,
              username: widget.profileModel.username,
            ),
            FollowersTab(
              isMe: widget.isMeBool,
              username: widget.profileModel.username,
            ),
            FollowingTab(
              isMe: widget.isMeBool,
              username: widget.profileModel.username,
            ),
            if (widget.isMeBool) const SubscribedTab(),
            if (widget.isMeBool) const SubscribedTab(),
          ],
        ),
      ),
    );
  }
}

List<Tab> _tapBarTitlesList_myProfile = [
  Tab(text: 'Verified Followers'),
  Tab(text: 'Followers you know'),
  Tab(text: 'Followers'),
  Tab(text: 'Following'),
  Tab(text: 'Subscribed'),
  Tab(text: 'Subscriptions'),
];

List<Tab> _tapBarTitlesList_otherProfile = [
  Tab(text: 'Verified Followers'),
  Tab(text: 'Followers you know'),
  Tab(text: 'Followers'),
  Tab(text: 'Following'),
];
