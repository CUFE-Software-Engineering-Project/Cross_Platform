import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:lite_x/features/profile/models/profile_model.dart';
import 'package:lite_x/features/profile/models/shared.dart';
import 'package:lite_x/features/profile/view/widgets/profile/block_button.dart';
import 'package:lite_x/features/profile/view/widgets/profile/follow_following_button.dart';
import 'package:lite_x/features/profile/view/widgets/profile/top_icon.dart';
import 'package:lite_x/features/profile/view_model/providers.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfileHeader extends ConsumerStatefulWidget {
  const ProfileHeader({
    super.key,
    required this.profileData,
    required this.isMe,
    required this.showData,
    required this.showDataFunc,
  });

  final ProfileModel profileData;
  final bool isMe;
  final bool showData;
  final Function showDataFunc;

  @override
  ConsumerState<ProfileHeader> createState() => _ProfileHeaderState();
}

class _ProfileHeaderState extends ConsumerState<ProfileHeader> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        _ProfileBanner(profileData: widget.profileData, isMe: widget.isMe),
        _ProfileAppBar(
          profileData: widget.profileData,
          isMe: widget.isMe,
          ref: ref,
          showDataFunc: widget.showDataFunc,
        ),
        _buildProfileContent(),
      ],
    );
  }

  Widget _buildProfileContent() {
    return Column(
      children: [
        const SizedBox(height: 120),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ProfileAvatarRow(
                profileData: widget.profileData,
                isMe: widget.isMe,
                showDataFunc: widget.showDataFunc,
              ),
              SizedBox(height: widget.showData ? 0 : 5),
              _ProfileIdentitySection(
                profileData: widget.profileData,
                isMe: widget.isMe,
              ),
              if (widget.showData)
                _ProfileDetailsSection(
                  profileData: widget.profileData,
                  isMe: widget.isMe,
                ),
            ],
          ),
        ),
      ],
    );
  }
}

// Common banner widget
class _ProfileBanner extends StatelessWidget {
  final ProfileModel profileData;
  final bool isMe;

  const _ProfileBanner({required this.profileData, required this.isMe});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (profileData.bannerId.isEmpty) {
          if (isMe) context.push("/editProfile", extra: profileData);
        } else {
          context.push(
            "/profileCoverScreen",
            extra: ProfilePhotoScreenArgs(
              isMe: isMe,
              profileModel: profileData,
            ),
          );
        }
      },
      child: BuildProfileBanner(bannerId: profileData.bannerId),
    );
  }
}

// Common app bar widget
class _ProfileAppBar extends StatelessWidget {
  final ProfileModel profileData;
  final bool isMe;
  final WidgetRef ref;
  final Function showDataFunc;

  const _ProfileAppBar({
    required this.profileData,
    required this.isMe,
    required this.ref,
    required this.showDataFunc,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      leading: Padding(
        padding: const EdgeInsets.all(6.0),
        child: TopIcon(
          icon: Icons.arrow_back,
          actionFunction: () {
            if (context.canPop()) context.pop();
          },
        ),
      ),
      actions: [
        TopIcon(
          icon: Icons.search_rounded,
          actionFunction: () {
            context.push("/profileSearchScreen");
          },
        ),
        const SizedBox(width: 15),
        isMe
            ? _build_more_options_profile()
            : _build_more_options_other_profile(
                context,
                profileData,
                ref,
                showDataFunc,
              ),
        const SizedBox(width: 6),
      ],
    );
  }
}

// Common avatar and action button row
class _ProfileAvatarRow extends ConsumerWidget {
  final ProfileModel profileData;
  final bool isMe;
  final Function showDataFunc;

  const _ProfileAvatarRow({
    required this.profileData,
    required this.isMe,
    required this.showDataFunc,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () {
            context.push(
              '/profilePhotoScreen',
              extra: ProfilePhotoScreenArgs(
                isMe: isMe,
                profileModel: profileData,
              ),
            );
          },
          child: BuildProfileImage(avatarId: profileData.avatarId),
        ),
        _buildActionButton(context, ref),
      ],
    );
  }

  Widget _buildActionButton(BuildContext context, WidgetRef ref) {
    if (isMe) {
      return Padding(
        padding: const EdgeInsets.only(top: 60),
        child: _buildEditProfileButton(context, ref),
      );
    } else if (profileData.isBlockedByMe) {
      return BlockButton(profileData: profileData, showDataFunc: showDataFunc);
    } else {
      return Follow_Following_Button(profileData: profileData);
    }
  }

  Widget _buildEditProfileButton(BuildContext context, WidgetRef ref) {
    return OutlinedButton(
      onPressed: () => _handleEditProfile(context, ref),
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.white,
        side: const BorderSide(color: Color(0xFFADADAD), width: 1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        padding: const EdgeInsets.symmetric(horizontal: 15),
      ),
      child: const Text(
        "Edit profile",
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
    );
  }

  void _handleEditProfile(BuildContext context, WidgetRef ref) {
    context.push<EditProfileStatus>("/editProfile", extra: profileData).then((
      status,
    ) {
      if (status == EditProfileStatus.changedSuccessfully) {
        print("success");
        // ignore: unused_result
        ref.refresh(profileDataProvider(profileData.username));
      } else if (status == EditProfileStatus.failedToChange) {
        showTopSnackBar(
          Overlay.of(context),
          CustomSnackBar.error(
            backgroundColor: const Color(0XFF212121),
            icon: const Icon(Icons.error, color: Colors.red),
            message: "Profile update failed",
          ),
          displayDuration: const Duration(seconds: 2),
        );
      }
    });
  }
}

// Common name and username section
class _ProfileIdentitySection extends StatelessWidget {
  final ProfileModel profileData;
  final bool isMe;

  const _ProfileIdentitySection({
    required this.profileData,
    required this.isMe,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDisplayName(),
        const SizedBox(height: 8),
        _buildUsername(),
      ],
    );
  }

  Widget _buildDisplayName() {
    return InkWell(
      onTap: () {
        // TODO: ADD verifying logic
      },
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Flexible(
            child: Text(
              profileData.displayName,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          if (isMe) _buildVerificationBadge(),
        ],
      ),
    );
  }

  Widget _buildVerificationBadge() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(width: 4),
        const Icon(Icons.verified, color: Color(0xFF1DA1F2), size: 18),
        const SizedBox(width: 8),
        if (!profileData.isVerified)
          Text(
            'Get Verified',
            style: TextStyle(
              color: const Color(0xFF1DA1F2),
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
      ],
    );
  }

  Widget _buildUsername() {
    return Wrap(
      children: [
        Text(
          "@${profileData.username}",
          style: const TextStyle(color: Colors.grey, fontSize: 15),
        ),
        const SizedBox(width: 10),
        if (!isMe && profileData.isFollower) _buildFollowsYouBadge(),
      ],
    );
  }

  Widget _buildFollowsYouBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      decoration: BoxDecoration(
        color: const Color(0XFF1F2225),
        borderRadius: BorderRadius.circular(6),
      ),
      child: const Text(
        "Follows you",
        style: TextStyle(color: Color(0xFF6D7176), fontSize: 12),
      ),
    );
  }
}

class _ProfileDetailsSection extends StatelessWidget {
  final ProfileModel profileData;
  final bool isMe;

  const _ProfileDetailsSection({required this.profileData, required this.isMe});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (profileData.bio.isNotEmpty) ...[
          Text(
            profileData.bio,
            style: const TextStyle(fontSize: 15),
            maxLines: 3,
          ),
          const SizedBox(height: 5),
        ],
        const SizedBox(height: 8),
        _buildProfileMetadata(),
        const SizedBox(height: 12),
        _buildFollowCounts(context),
        const SizedBox(height: 0),
      ],
    );
  }

  Widget _buildProfileMetadata() {
    return Wrap(
      runSpacing: 8,
      children: [
        if (profileData.location.isNotEmpty)
          _buildMetadataItem(
            icon: const Icon(
              Icons.location_on_outlined,
              color: Colors.grey,
              size: 16,
            ),
            text: profileData.location,
          ),
        if (profileData.website.isNotEmpty) _buildWebsiteItem(),
        if (profileData.birthDate.isNotEmpty)
          _buildMetadataItem(
            icon: SvgPicture.asset(
              "assets/svg/born.svg",
              width: 16,
              height: 16,
              colorFilter: const ColorFilter.mode(Colors.grey, BlendMode.srcIn),
            ),
            text: "Born ${profileData.birthDate}",
          ),
        if (profileData.joinedDate.isNotEmpty)
          _buildMetadataItem(
            icon: const Icon(
              Icons.calendar_month_outlined,
              color: Colors.grey,
              size: 16,
            ),
            text: "Joined ${profileData.joinedDate}",
          ),
      ],
    );
  }

  Widget _buildMetadataItem({required Widget icon, required String text}) {
    return Wrap(
      children: [
        icon,
        const SizedBox(width: 4),
        Text(text, style: const TextStyle(color: Colors.grey)),
        const SizedBox(width: 12),
      ],
    );
  }

  Widget _buildWebsiteItem() {
    return Wrap(
      children: [
        SvgPicture.asset(
          "assets/svg/website.svg",
          width: 16,
          height: 16,
          colorFilter: const ColorFilter.mode(Colors.grey, BlendMode.srcIn),
        ),
        const SizedBox(width: 2),
        GestureDetector(
          onTap: () => _launchWebsite(profileData.website),
          child: Text(
            profileData.website,
            style: const TextStyle(color: Colors.blueAccent),
            maxLines: 1,
            overflow: TextOverflow.clip,
          ),
        ),
        const SizedBox(width: 12),
      ],
    );
  }

  Future<void> _launchWebsite(String url) async {
    final uri = Uri.parse(url.startsWith('http') ? url : 'https://$url');

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.inAppBrowserView);
    } else {
      // Error handling would be done in the calling context
    }
  }

  Widget _buildFollowCounts(BuildContext context) {
    return Row(
      children: [
        _buildFollowCountItem(
          context,
          profileData.followingCount,
          'Following',
          FollowingFollowersInitialTab.Following,
        ),
        const SizedBox(width: 16),
        _buildFollowCountItem(
          context,
          profileData.followersCount,
          'Follower',
          FollowingFollowersInitialTab.Followers,
        ),
      ],
    );
  }

  Widget _buildFollowCountItem(
    BuildContext context,
    int count,
    String label,
    int tab,
  ) {
    return GestureDetector(
      onTap: () {
        context.push(
          "/followingfollowersscreen/$tab/${isMe ? "me" : "notme"}",
          extra: profileData,
        );
      },
      child: _buildFollowCount(count, label),
    );
  }
}

Widget _buildFollowCount(int count, String label) {
  String formatedCount = Shared.formatCount(count);

  return RichText(
    text: TextSpan(
      children: [
        TextSpan(
          text: formatedCount + " ",
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        TextSpan(
          text: label,
          style: const TextStyle(color: Colors.grey, fontSize: 16),
        ),
      ],
    ),
  );
}

Widget _build_more_options_profile() {
  return CircleAvatar(
    child: PopupMenuButton<String>(
      icon: Icon(Icons.more_vert, color: Colors.white),
      color: Color(0xFF212121),
      onSelected: (value) async {
        switch (value) {
          case 'Share':
            break;
          case 'Drafts':
            break;
          case "Lists you're on":
            // Handle block
            break;
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'Share',
          child: Row(
            children: [
              SizedBox(width: 12),
              Text(
                'Share',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'Drafts',
          child: Row(
            children: [
              SizedBox(width: 12),
              Text(
                'Drafts',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            ],
          ),
        ),
        PopupMenuItem(
          value: "Lists you're on",
          child: Row(
            children: [
              SizedBox(width: 12),
              Text(
                "Lists you're on",
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            ],
          ),
        ),
      ],
    ),
    backgroundColor: Colors.black.withValues(alpha: 0.5),
    radius: 20,
  );
}

Widget _build_more_options_other_profile(
  BuildContext context,
  ProfileModel profileData,
  WidgetRef ref,
  Function showDataFunc,
) {
  return CircleAvatar(
    child: PopupMenuButton<String>(
      icon: Icon(Icons.more_vert, color: Colors.white),
      color: Color(0xFF212121),
      onSelected: (value) async {
        switch (value) {
          case 'Share':
            break;
          case 'Add/remove from lists':
            // print("add /remove");
            break;
          case "view lists":
            // print("veiew lists");
            // Handle block
            break;
          case "Lists they're on":
            // print("list they are on");
            // Handle block
            break;
          case "Mute":
            final mute = ref.watch(muteUserProvider);
            mute(profileData.username).then((either) {
              either.fold(
                (l) {
                  showSmallPopUpMessage(
                    context: context,
                    message: l.message,
                    borderColor: Colors.red,
                    icon: Icon(Icons.error, color: Colors.red),
                  );
                },
                (r) {
                  showSmallPopUpMessage(
                    context: context,
                    message: "You Muted @${profileData.username}",
                    borderColor: Colors.blue,
                    icon: Icon(Icons.volume_off, color: Colors.blue),
                  );
                  // ignore: unused_result
                  ref.refresh(profileDataProvider(profileData.username));
                },
              );
            });
            break;

          case "Unmute":
            final unMute = ref.watch(unMuteUserProvider);
            unMute(profileData.username).then((either) {
              either.fold(
                (l) {
                  showSmallPopUpMessage(
                    context: context,
                    message: l.message,
                    borderColor: Colors.red,
                    icon: Icon(Icons.error, color: Colors.red),
                  );
                },
                (r) {
                  showSmallPopUpMessage(
                    context: context,
                    message: "You Unmuted @${profileData.username}",
                    borderColor: Colors.blue,
                    icon: Icon(Icons.volume_up, color: Colors.blue),
                  );
                  // ignore: unused_result
                  ref.refresh(profileDataProvider(profileData.username));
                },
              );
            });
            break;
          case "Block":
            final res = await showPopupMessage(
              context: context,
              title: Text(
                "Block @${profileData.username}?",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 22,
                ),
              ),
              message: Text(
                "They will be able to see your public posts, but will no longer be able to engage with them. @${profileData.username} will also not be able to follow or message you, and you will not see notifications from them",
                style: TextStyle(color: Colors.white),
              ),
              confirmText: "Block",
              cancelText: "Cancel",
            );
            if (res == null || res == false) return;
            final block = ref.read(blockUserProvider);
            final blockRes = await block(profileData.username);
            blockRes.fold(
              (fail) {
                showSmallPopUpMessage(
                  context: context,
                  message: fail.message,
                  borderColor: Colors.red,
                  icon: Icon(Icons.error, color: Colors.red),
                );
              },
              (right) {
                // ignore: unused_result
                ref.refresh(profileDataProvider(profileData.username));
                showDataFunc();
              },
            );
            break;
          case "Unblock":
            final res = await showPopupMessage(
              context: context,
              title: Text(
                "Unblock @${profileData.username}?",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 22,
                ),
              ),
              message: Text(
                "They will be able to follow you and engage with your posts. (if the account is protected they'll have to request to follow)",
                style: TextStyle(color: Colors.white),
              ),
              confirmText: "UnBlock",
              cancelText: "Cancel",
            );
            if (res == null || res == false) return;
            final unblock = ref.read(unBlockUserProvider);
            final blockRes = await unblock(profileData.username);
            blockRes.fold(
              (fail) {
                showSmallPopUpMessage(
                  context: context,
                  message: fail.message,
                  borderColor: Colors.red,
                  icon: Icon(Icons.error, color: Colors.red),
                );
              },
              (right) {
                // ignore: unused_result
                ref.refresh(profileDataProvider(profileData.username));
                showDataFunc();
              },
            );
            break;
          case "Report":
            // print("Report");
            // handle report
            break;
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'Share',
          child: Row(
            children: [
              SizedBox(width: 12),
              Text(
                'Share',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        if (!profileData.isBlockedByMe)
          PopupMenuItem(
            value: 'Add/remove from lists',
            child: Row(
              children: [
                SizedBox(width: 12),
                Text(
                  'Add/remove from lists',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        PopupMenuItem(
          value: 'view lists',
          child: Row(
            children: [
              SizedBox(width: 12),
              Text(
                'view Lists',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        PopupMenuItem(
          value: "Lists they're on",
          child: Row(
            children: [
              SizedBox(width: 12),
              Text(
                "Lists they're on",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        if (!profileData.isBlockedByMe)
          PopupMenuItem(
            value: profileData.isMutedByMe ? 'Unmute' : 'Mute',
            child: Row(
              children: [
                SizedBox(width: 12),
                Text(
                  profileData.isMutedByMe ? 'Unmute' : 'Mute',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              ],
            ),
          ),
        PopupMenuItem(
          value: profileData.isBlockedByMe ? "Unblock" : "Block",
          child: Row(
            children: [
              SizedBox(width: 12),
              Text(
                profileData.isBlockedByMe ? "Unblock" : "Block",
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            ],
          ),
        ),
        PopupMenuItem(
          value: "Report",
          child: Row(
            children: [
              SizedBox(width: 12),
              Text(
                "Report",
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            ],
          ),
        ),
      ],
    ),
    backgroundColor: Colors.black.withValues(alpha: 0.5),
    radius: 20,
  );
}


