import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lite_x/features/profile/models/profile_model.dart';
import 'package:lite_x/features/profile/view/widgets/profile/profile_header.dart';
import 'package:lite_x/features/profile/view/widgets/profile/profile_tabs.dart';

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
  late bool showData;

  @override
  void initState() {
    if (widget.profileData.isBlockedByMe && !widget.isMe)
      showData = false;
    else
      showData = true;
    super.initState();
  }

  void showDataFunc() {
    setState(() {
      if (showData == false)
        showData = true;
      else {
        showData = widget.profileData.isBlockedByMe;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: ProfileHeader(
            profileData: widget.profileData,
            isMe: widget.isMe,
            showData: showData,
            showDataFunc: showDataFunc,
          ),
        ),
        if (!showData)
          SliverFillRemaining(
            child: ShowProfileDataBlockedUser(
              showDataFunc: showDataFunc,
              profileData: widget.profileData,
            ),
          ),
        if (showData)
          SliverFillRemaining(
            child: ProfileTabs(
              isMe: widget.isMe,
              profileData: widget.profileData,
            ),
          ),
      ],
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

class ShowProfileDataBlockedUser extends StatelessWidget {
  const ShowProfileDataBlockedUser({
    super.key,
    required this.showDataFunc,
    required this.profileData,
  });
  final Function showDataFunc;
  final ProfileModel profileData;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(toolbarHeight: 0),
      backgroundColor: Color.fromARGB(255, 19, 20, 21),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(width: double.infinity, height: 40),
            Flexible(
              child: Text(
                "@${profileData.username} is blocked",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
              ),
            ),
            SizedBox(height: 15),
            Flexible(
              child: Text(
                "Are you sure you want to view these posts?",
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ),
            Flexible(
              child: Text(
                "Viewing posts won't unblock @${profileData.username}",
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ),
            SizedBox(height: 20),
            OutlinedButton(
              onPressed: () {
                showDataFunc();
              },
              style: OutlinedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                shape: StadiumBorder(side: BorderSide(width: 0)),
                side: BorderSide(width: 0),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 0,
                ),
              ),
              child: Text(
                "View posts",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
