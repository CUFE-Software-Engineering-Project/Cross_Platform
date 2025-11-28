import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lite_x/features/profile/view/widgets/following_followers/followers_List.dart';
import 'package:lite_x/features/profile/view_model/providers.dart';

class FollowingTab extends ConsumerWidget {
  final bool isMe;
  final String username;

  const FollowingTab({super.key, required this.isMe, required this.username});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncFollowings = ref.watch(followingsProvider(username));
    return asyncFollowings.when(
      data: (either) => either.fold(
        (l) => RefreshIndicator(
          onRefresh: () async {
            // ignore: unused_result
            await ref.refresh(followingsProvider(username));
          },
          child: ListView(
            children: [
              SizedBox(height: 200),
              Center(child: Text(l.message)),
            ],
          ),
        ),
        (followings) => RefreshIndicator(
          onRefresh: () async {
            // ignore: unused_result
            await ref.refresh(followingsProvider(username));
          },
          child: Column(
            children: [
              Expanded(
                child: FollowerList(users: followings, isMe: isMe),
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
