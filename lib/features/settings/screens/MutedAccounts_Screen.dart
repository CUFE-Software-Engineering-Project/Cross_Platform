import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lite_x/core/providers/current_user_provider.dart';
import 'package:lite_x/core/theme/Palette.dart';
import 'package:lite_x/features/profile/models/shared.dart';
import 'package:lite_x/features/profile/models/user_model.dart';
import 'package:lite_x/features/settings/view_model/providers.dart';

class MutedAccountsScreen extends ConsumerWidget {
  const MutedAccountsScreen({super.key});

  Widget _description() => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
    child: Text(
      "Posts from muted accounts won't show up in your Home timeline. Mute accounts directly from their profile or posts.",
      style: const TextStyle(
        color: Palette.textSecondary,
        fontSize: 16,
        height: 1.4,
      ),
    ),
  );

  Widget _mutedTile({
    required UserModel user,
    required VoidCallback onUnmute,
    required VoidCallback onFollow,
    required VoidCallback onUnFollow,
  }) {
    print(user.isFollowing);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: Colors.grey.shade800,
            backgroundImage: CachedNetworkImageProvider(
              user.image.isNotEmpty ? user.image : unkownUserAvatar,
            ),
            onBackgroundImageError: (exception, stackTrace) => null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        user.displayName,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Palette.textWhite,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    if (user.isVerified)
                      const Padding(
                        padding: EdgeInsets.only(left: 4.0),
                        child: Icon(
                          Icons.verified,
                          color: Colors.blue,
                          size: 18,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '@${user.userName}',
                  style: const TextStyle(
                    color: Palette.textSecondary,
                    fontSize: 13,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  user.bio,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Palette.textWhite,
                    fontSize: 14,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: onUnmute,
                child: const Icon(
                  Icons.volume_off,
                  color: Colors.red,
                  size: 25,
                ),
              ),
              SizedBox(width: 10),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: user.isFollowing
                      ? Colors.black
                      : Colors.white,
                  foregroundColor: user.isFollowing
                      ? Colors.white
                      : Colors.black,

                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  shape: StadiumBorder(
                    side: user.isFollowing
                        ? BorderSide(color: Colors.white)
                        : BorderSide(),
                  ),
                ),
                onPressed: user.isFollowing ? onUnFollow : onFollow,
                child: Text(
                  user.isFollowing ? "UnFollow" : "Follow",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _list(WidgetRef ref, BuildContext context) {
    final asyncValue = ref.watch(mutedAccountsProvider);
    return asyncValue.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(
        child: Text(
          'Error: $e',
          style: const TextStyle(color: Palette.textSecondary),
        ),
      ),
      data: (either) => either.fold(
        (failure) => Center(
          child: Text(
            failure.message,
            style: const TextStyle(color: Palette.textSecondary),
          ),
        ),
        (users) {
          if (users.isEmpty) {
            return Padding(
              padding: EdgeInsets.all(24.0),
              child: RefreshIndicator(
                onRefresh: () async {
                  // ignore: unused_result
                  ref.refresh(mutedAccountsProvider);
                },
                child: ListView(
                  children: [
                    Text(
                      'No muted accounts',
                      style: TextStyle(color: Palette.textWhite),
                    ),
                  ],
                ),
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () async {
              // ignore: unused_result
              ref.refresh(mutedAccountsProvider);
            },
            child: ListView.builder(
              itemCount: users.length,
              itemBuilder: (c, i) => InkWell(
                onTap: () {
                  context.push("/profilescreen/${users[i].userName}");
                },
                child: _mutedTile(
                  user: users[i],
                  onUnmute: () async {
                    final unMute = ref.read(unMuteControllerProvider);
                    await unMute(users[i].userName);
                    final _ = ref.refresh(mutedAccountsProvider);
                  },
                  onFollow: () async {
                    final follow = ref.read(
                      followMutedAccountControllerProvider,
                    );
                    await follow(users[i].userName);
                    // ignore: unused_result
                    ref.refresh(mutedAccountsProvider);
                  },
                  onUnFollow: () async {
                    final unFollow = ref.read(
                      unFollowMutedAccountControllerProvider,
                    );
                    await unFollow(users[i].userName);
                    // ignore: unused_result
                    ref.refresh(mutedAccountsProvider);
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scaffoldBody = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _description(),
        Expanded(child: _list(ref, context)),
      ],
    );
    final user = ref.watch(currentUserProvider);
    return LayoutBuilder(
      builder: (context, constraints) {
        final appBar = AppBar(
          backgroundColor: Palette.background,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back,
              color: Palette.textWhite,
              size: 20,
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Muted accounts',
                style: TextStyle(
                  color: Palette.textWhite,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 2),
              Text(
                '@${user?.username ?? "username"}',
                style: TextStyle(color: Palette.textSecondary, fontSize: 12),
              ),
            ],
          ),
          centerTitle: false,
        );

        if (constraints.maxWidth > 600) {
          return Scaffold(
            backgroundColor: Colors.black.withOpacity(0.4),
            body: Center(
              child: Container(
                width: 800,
                height: 700,
                decoration: BoxDecoration(
                  color: Palette.background,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Builder(
                  builder: (context) {
                    return Column(
                      children: [
                        SizedBox(
                          height: appBar.preferredSize.height,
                          child: appBar,
                        ),
                        Expanded(child: scaffoldBody),
                      ],
                    );
                  },
                ),
              ),
            ),
          );
        }
        return Scaffold(
          backgroundColor: Palette.background,
          appBar: appBar,
          body: scaffoldBody,
        );
      },
    );
  }
}
