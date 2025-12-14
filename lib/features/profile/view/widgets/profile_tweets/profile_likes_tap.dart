import 'package:flutter/material.dart';
import 'package:lite_x/features/profile/models/profile_model.dart';
import 'package:lite_x/features/profile/models/shared.dart';
import 'package:lite_x/features/profile/view/widgets/profile_tweets/profile_posts_list.dart';

class ProfileLikesTap extends StatefulWidget {
  const ProfileLikesTap({super.key, required this.profileModel});
  final ProfileModel profileModel;

  @override
  State<ProfileLikesTap> createState() => _ProfileLikesTapState();
}

class _ProfileLikesTapState extends State<ProfileLikesTap> {
  @override
  Widget build(BuildContext context) {
    return ProfilePostsList(
      profile: this.widget.profileModel,
      tabType: ProfileTabType.Likes,
    );
  }
}
