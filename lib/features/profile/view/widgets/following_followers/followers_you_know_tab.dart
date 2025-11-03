import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lite_x/features/profile/view/widgets/following_followers/followers_List.dart';
import 'package:lite_x/features/profile/view_model/providers.dart';

class FollowersYouKnowTab extends ConsumerWidget {
  final bool isMe;
  final String username;

  const FollowersYouKnowTab({
    super.key,
    required this.isMe,
    required this.username,
  });
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncFollower = ref.watch(followersYouKnowProvider(username));
    return asyncFollower.when(
      data: (either) => either.fold(
        (l) => RefreshIndicator(
          onRefresh: () async {
            // ignore: unused_result
            await ref.refresh(followersYouKnowProvider(username));
          },
          child: ListView(
            children: [
              SizedBox(height: 200),
              Center(child: Text(l.message)),
            ],
          ),
        ),
        (followers) => RefreshIndicator(
          onRefresh: () async {
            // ignore: unused_result
            await ref.refresh(followersYouKnowProvider(username));
          },
          child: Column(
            children: [
              Expanded(
                child: FollowerList(users: followers, isMe: isMe),
              ),
            ],
          ),
        ),
      ),
      error: (err, _) => Center(child: Text(err.toString())),
      loading: () => Center(child: CircularProgressIndicator()),
    );
  }
}
