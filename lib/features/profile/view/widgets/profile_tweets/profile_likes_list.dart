import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lite_x/features/profile/models/shared.dart';
import 'package:lite_x/features/profile/view_model/providers.dart';

import '../../../models/profile_model.dart';

class ProfileLikesList extends ConsumerWidget {
  const ProfileLikesList({super.key, required this.profile});

  final ProfileModel profile;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncLikes = ref.watch(profileLikesProvider(this.profile.username));

    return asyncLikes.when(
      data: (either) {
        return either.fold( 
          (l) {
            return Center(child: Text(l.message));
          },
          (data) {
            final List<ProfileTweet> posts = data.map((post) {
              return getCorrectTweetType(post, profile);
            }).toList();

            return RefreshIndicator(
              onRefresh: () async {
                // ignore: unused_result
                await ref.refresh(profileLikesProvider(this.profile.username));
                // ignore: unused_result
                ref.refresh(profileDataProvider(this.profile.username));
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
            );
          },
        );
      },
      error: (err, _) {
        return Center(child: Text("Failed to load post data"));
      },
      loading: () {
        return const Center(child: CircularProgressIndicator());
      },
    );
  }
}
