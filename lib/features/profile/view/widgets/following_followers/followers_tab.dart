import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lite_x/features/profile/models/user_model.dart';
import 'package:lite_x/features/profile/view/widgets/following_followers/followers_List.dart';
import 'package:lite_x/features/profile/view_model/providers.dart';

class FollowersTab extends ConsumerWidget {
  final bool isMe;
  final String username;

  const FollowersTab({super.key, required this.isMe, required this.username});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncFollowers = ref.watch(followersProvider(username));

    return asyncFollowers.when(
      data: (either) => either.fold(
        (fail) => Center(child: Text(fail.message)),
        (followers) => RefreshIndicator(
          onRefresh: () async {
            // ignore: unused_result
            await ref.refresh(followersProvider(username));
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

final List<UserModel> users = [
  UserModel(
    displayName: 'Hazem Emam',
    userName: 'hazememam',
    image: 'https://images.pexels.com/photos/1462980/pexels-photo-1462980.jpeg',
    bio:
        'Software engineer and web developer. Software engineer and web developer. Software engineer and web developer.',
    isFollowing: true,
    isFollower: false,
    isVerified: true,
  ),
  UserModel(
    displayName: 'Sara Ali',
    userName: 'sara_ali',
    image: 'https://example.com/images/sara.jpg',
    bio: 'UI/UX designer and artist.',
    isFollowing: true,
    isFollower: true,
    isVerified: false,
  ),
  UserModel(
    displayName: 'Omar Hassan',
    userName: 'omar_hassan',
    image: 'https://example.com/images/omar.jpg',
    bio: 'Data scientist and AI enthusiast.',
    isFollowing: true,
    isFollower: true,
    isVerified: true,
  ),
  UserModel(
    displayName: 'Laila Mohamed',
    userName: 'laila_m',
    image: 'https://example.com/images/laila.jpg',
    bio: 'Mobile app developer.',
    isFollowing: false,
    isFollower: false,
    isVerified: true,
  ),
];
