import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lite_x/core/theme/palette.dart';
import 'package:lite_x/features/profile/models/user_model.dart';
import 'package:lite_x/features/settings/view_model/providers.dart';

class MutedAccountsScreen extends ConsumerWidget {
  const MutedAccountsScreen({super.key});

  Widget _description() => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Text(
          "Posts from muted accounts won't show up in your Home timeline. Mute accounts directly from their profile or posts.",
          style: const TextStyle(color: Palette.textSecondary, fontSize: 16, height: 1.4),
        ),
      );

  Widget _mutedTile({
    required UserModel user,
    required VoidCallback onUnmute,
    required VoidCallback onFollow,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(radius: 24, backgroundColor: Colors.grey.shade800),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
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
                      child: Icon(Icons.verified, color: Colors.blue, size: 18),
                    ),
                  const Padding(
                    padding: EdgeInsets.only(left: 4.0),
                    child: Icon(Icons.volume_off, color: Palette.textSecondary, size: 18),
                  ),
                ]),
                const SizedBox(height: 2),
                Text('@${user.userName}', style: const TextStyle(color: Palette.textSecondary, fontSize: 13)),
                const SizedBox(height: 4),
                Text(
                  user.bio,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Palette.textWhite, fontSize: 14, height: 1.2),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                ),
                onPressed: onFollow,
                child: const Text('Follow', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
              ),
              const SizedBox(height: 6),
              GestureDetector(
                onTap: onUnmute,
                child: const Icon(Icons.close, color: Palette.textSecondary, size: 18),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _list(WidgetRef ref) {
    final asyncValue = ref.watch(mutedAccountsProvider);
    return asyncValue.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e', style: const TextStyle(color: Palette.textSecondary))),
      data: (either) => either.fold(
        (failure) => Center(child: Text(failure.message, style: const TextStyle(color: Palette.textSecondary))),
        (users) {
          if (users.isEmpty) {
            return const Padding(
              padding: EdgeInsets.all(24.0),
              child: Text('No muted accounts', style: TextStyle(color: Palette.textWhite)),
            );
          }
          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (c, i) => _mutedTile(
              user: users[i],
              onUnmute: () async {
                final unMute = ref.read(unMuteControllerProvider);
                await unMute(users[i].userName);
                final _ = ref.refresh(mutedAccountsProvider);
              },
              onFollow: () async {
                final follow = ref.read(followMutedAccountControllerProvider);
                await follow(users[i].userName);
              },
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
        Expanded(child: _list(ref)),
      ],
    );

    return LayoutBuilder(builder: (context, constraints) {
      final appBar = AppBar(
        backgroundColor: Palette.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Palette.textWhite, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text('Muted accounts', style: TextStyle(color: Palette.textWhite, fontSize: 18, fontWeight: FontWeight.w700)),
            SizedBox(height: 2),
            Text('@profilename', style: TextStyle(color: Palette.textSecondary, fontSize: 12)),
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
              child: Builder(builder: (context) {
                return Column(children: [
                  SizedBox(height: appBar.preferredSize.height, child: appBar),
                  Expanded(child: scaffoldBody),
                ]);
              }),
            ),
          ),
        );
      }
      return Scaffold(backgroundColor: Palette.background, appBar: appBar, body: scaffoldBody);
    });
  }
}
