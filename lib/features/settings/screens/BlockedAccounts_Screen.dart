import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lite_x/core/providers/current_user_provider.dart';
import 'package:lite_x/core/theme/palette.dart';
import 'package:lite_x/features/profile/models/user_model.dart';
import 'package:lite_x/features/settings/view_model/providers.dart';

class BlockedAccountsScreen extends ConsumerWidget {
  const BlockedAccountsScreen({super.key});

  Widget _description() => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
    child: Text(
      "When you block someone, they won't be able to follow or message you, and you won't see notifications from them.",
      style: const TextStyle(
        color: Palette.textSecondary,
        fontSize: 16,
        height: 1.4,
      ),
    ),
  );

  Widget _blockedTile({
    required UserModel user,
    required VoidCallback onUnblock,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: Colors.grey.shade800,
            backgroundImage: CachedNetworkImageProvider(user.image),
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
          GestureDetector(
            onTap: onUnblock,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.red.shade700,
                borderRadius: BorderRadius.circular(999),
              ),
              child: const Text(
                'Blocked',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _list(WidgetRef ref, BuildContext context) {
    final asyncValue = ref.watch(blockedAccountsProvider);
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
                  ref.refresh(blockedAccountsProvider);
                },
                child: ListView(
                  children: [
                    Text(
                      'No blocked accounts',
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
              ref.refresh(blockedAccountsProvider);
            },
            child: ListView.builder(
              itemCount: users.length,
              itemBuilder: (c, i) => InkWell(
                onTap: () {
                  context.push("/profilescreen/${users[i].userName}");
                },
                child: _blockedTile(
                  user: users[i],
                  onUnblock: () async {
                    final unblock = ref.read(unblockControllerProvider);
                    await unblock(users[i].userName);
                    final _ = ref.refresh(blockedAccountsProvider);
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
                'Blocked accounts',
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
