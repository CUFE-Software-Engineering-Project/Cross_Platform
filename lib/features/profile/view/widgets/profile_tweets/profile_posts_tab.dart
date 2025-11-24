import 'package:flutter/material.dart';
import 'package:lite_x/features/profile/models/profile_model.dart';
import 'package:lite_x/features/profile/models/shared.dart';
import 'package:lite_x/features/profile/view/widgets/profile_tweets/profile_posts_list.dart';

class ProfilePostsTab extends StatelessWidget {
  const ProfilePostsTab({super.key, required this.profileModel});
  final ProfileModel profileModel;
  @override
  Widget build(BuildContext context) {
    return ProfilePostsList(profile: this.profileModel,tabType: ProfileTabType.Posts,);
  }
}
