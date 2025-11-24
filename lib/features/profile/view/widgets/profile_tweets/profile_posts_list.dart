import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:lite_x/features/profile/models/profile_tweet_model.dart';
import 'package:lite_x/features/profile/models/shared.dart';
import 'package:lite_x/features/profile/view/widgets/profile_tweets/profile_normal_tweet_widget.dart';
import 'package:lite_x/features/profile/view_model/providers.dart';

import '../../../models/profile_model.dart';

class ProfilePostsList extends ConsumerWidget {
  const ProfilePostsList({
    super.key,
    required this.profile,
    required this.tabType,
  });

  final ProfileModel profile;
  final ProfileTabType tabType;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncPosts = tabType == ProfileTabType.Posts? ref.watch(profilePostsProvider(this.profile.username)): tabType == ProfileTabType.Likes? ref.watch(profileLikesProvider(this.profile.username)): ref.watch(profileMediaProvider(this.profile.username));
    ;

    return asyncPosts.when(
      data: (either) {
        return either.fold(
          (l) {
            return RefreshIndicator(
              child: ListView(
                children: [
                  SizedBox(height: 30),
                  Center(child: Text(l.message)),
                ],
              ),
              onRefresh: () async {
                // ignore: unused_result
                ref.refresh(profileLikesProvider(this.profile.username));
              },
            );
          },
          (data) {
            List<ProfileTweetModel> filteredData;
            if (tabType == ProfileTabType.Media)
              filteredData = data
                  .where((element) => element.mediaIds.isNotEmpty)
                  .toList();
            else if (tabType == ProfileTabType.Likes) {
              filteredData = data
                  .where((element) => element.isLikedByMe == true)
                  .toList();
            } else
              filteredData = data;

            if (filteredData.isEmpty) {
              return RefreshIndicator(
                onRefresh: () async {
                  // ignore: unused_result
                  ref.refresh(profilePostsProvider(profile.username));
                },
                child: ListView(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        "Nothing to see here -- yet.",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 35,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }

            final List<ProfileTweet> posts = filteredData.map((post) {
              return getCorrectTweetType(post, profile);
            }).toList();
            return RefreshIndicator(
              onRefresh: () async {
                // ignore: unused_result
                ref.refresh(profilePostsProvider(this.profile.username));
                // ignore: unused_result
                ref.refresh(profileLikesProvider(this.profile.username));
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
        return RefreshIndicator(
          child: ListView(
            children: [
              SizedBox(height: 30),
              Center(child: Text('Failed to load post data')),
            ],
          ),
          onRefresh: () async {
            // ignore: unused_result
            ref.refresh(profilePostsProvider(this.profile.username));
          },
        );
      },
      loading: () {
        return const Center(child: CircularProgressIndicator());
      },
    );
  }
}
