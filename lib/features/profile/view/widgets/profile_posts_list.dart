import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lite_x/features/profile/view/widgets/profile_post_widget.dart';
import 'package:lite_x/features/profile/view_model/providers.dart';

import '../../models/profile_model.dart';
import '../../models/profile_post_model.dart';

class ProfilePostsList extends ConsumerWidget {
  const ProfilePostsList({super.key, required this.profile});

  final ProfileModel profile;
  

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(profilePostsNotifierProvider);
    if(state.isLoading){
      return const Center(child: CircularProgressIndicator());
    } else if(state.errorMessage != null){
      return Center(child: Text(state.errorMessage!));
    } 
    
    final posts = state.posts.map((post) => ProfilePostWidget(profilePostModel: post, profileModel: profile)).toList();

    return ListView.separated(
      itemBuilder: (context, index) {
        return posts[index];
      },
      itemCount: posts.length,
      separatorBuilder: (context, index) {
        return Container(width: double.infinity,height: 0.5, color: Colors.grey,);
      },
    );
  }
}
