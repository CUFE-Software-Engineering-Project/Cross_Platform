import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lite_x/features/profile/models/profile_model.dart';
import 'package:lite_x/features/profile/models/profile_post_model.dart';
import 'package:lite_x/features/profile/models/shared.dart';
import 'package:lite_x/features/profile/view/widgets/profile/profile_header.dart';
import 'package:lite_x/features/profile/view/widgets/profile/profile_tabs.dart';

class ProfileScreenBody2 extends ConsumerStatefulWidget {
  final ProfileModel profileData;
  final bool isMe;
  const ProfileScreenBody2({
    super.key,
    required this.profileData,
    required this.isMe,
  });

  @override
  ConsumerState<ProfileScreenBody2> createState() => _ProfileScreenBody2State();
}

class _ProfileScreenBody2State extends ConsumerState<ProfileScreenBody2> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: ProfileHeader(
            profileData: widget.profileData,
            isMe: widget.isMe,
          ),
        ),
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
