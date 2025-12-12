import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lite_x/features/profile/models/profile_model.dart';
import 'package:lite_x/features/profile/models/shared.dart';
import 'package:lite_x/features/profile/view_model/providers.dart';

class ExploreCategoryTab extends ConsumerWidget {
  const ExploreCategoryTab({
    super.key,
    required this.categoryName,
    required this.pm,
  });
  final String categoryName;
  final ProfileModel pm;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncTweets = ref.watch(
      exploreCategoryTweetsProvider(this.categoryName),
    );
    return asyncTweets.when(
      data: (res) {
        return res.fold(
          (l) {
            return ListView(
              padding: EdgeInsets.only(top: 50),
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              children: [
                Center(child: Text(l.message)),
                Center(
                  child: IconButton(
                    onPressed: () async {
                      // ignore: unused_result
                      ref.refresh(
                        exploreCategoryTweetsProvider(this.categoryName),
                      );
                    },
                    icon: Icon(Icons.refresh),
                  ),
                ),
              ],
            );
          },
          (tweets) {
            if (tweets.isEmpty) {
              return RefreshIndicator(
                onRefresh: () async {
                  // ignore: unused_result
                  ref.refresh(exploreCategoryTweetsProvider(this.categoryName));
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

            final List<ProfileTweet> posts = tweets.map((post) {
              return getCorrectTweetType(post, pm);
            }).toList();
            return RefreshIndicator(
              onRefresh: () async {
                // ignore: unused_result
                ref.refresh(exploreCategoryTweetsProvider(this.categoryName));
              },
              child: ListView.separated(
                cacheExtent: 2000,
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
        return ListView(
          padding: EdgeInsets.only(top: 50),
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          children: [
            Center(child: Text("cannot get explore at this time...")),
            Center(
              child: IconButton(
                onPressed: () async {
                  // ignore: unused_result
                  ref.refresh(exploreCategoryTweetsProvider(this.categoryName));
                },
                icon: Icon(Icons.refresh),
              ),
            ),
          ],
        );
      },
      loading: () {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Center(child: CircularProgressIndicator()),
          ),
        );
      },
    );
  }
}
