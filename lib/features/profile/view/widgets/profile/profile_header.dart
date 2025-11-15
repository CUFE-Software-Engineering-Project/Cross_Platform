import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:lite_x/features/profile/models/profile_model.dart';
import 'package:lite_x/features/profile/models/shared.dart';
import 'package:lite_x/features/profile/view/screens/profilephoto_screen.dart';
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
  });
  final ProfileModel profileData;
  final bool isMe;

  @override
  ConsumerState<ProfileHeader> createState() => _ProfileHeaderState();
}

class _ProfileHeaderState extends ConsumerState<ProfileHeader> {
  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        ref.read(
          profileBasicDataNotifierProvider(
            widget.profileData.username,
          ).notifier,
        )..loadProfileData(widget.profileData.username);
      },
      child: Stack(
        children: [
          GestureDetector(
            onTap: () {
              if (widget.profileData.bannerUrl.isEmpty) {
                context.push("/editProfile", extra: widget.profileData);
              } else {
                context.push(
                  "/profileCoverScreen",
                  extra: ProfilePhotoScreenArgs(
                    isMe: widget.isMe,
                    profileModel: widget.profileData,
                  ),
                );
              }
            },
            child: Container(
              height: 165,
              decoration: BoxDecoration(
                color: Colors.blue,
                image: widget.profileData.bannerUrl.isEmpty
                    ? null
                    : DecorationImage(
                        image: NetworkImage(widget.profileData.bannerUrl),
                        fit: BoxFit.cover,
                      ),
              ),
            ),
          ),
          AppBar(
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
              TopIcon(icon: Icons.search_rounded, actionFunction: () {}),
              SizedBox(width: 15),
              TopIcon(icon: Icons.more_vert, actionFunction: () {}),
              SizedBox(width: 6),
            ],
          ),
          Column(
            // shrinkWrap: true,
            // physics: NeverScrollableScrollPhysics(),
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const SizedBox(height: 120),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GestureDetector(
                          onTap: () {
                            // TODO: add open profile page
                            context.push(
                              '/profilePhotoScreen',
                              extra: ProfilePhotoScreenArgs(
                                isMe: widget.isMe,
                                profileModel: widget.profileData,
                              ),
                            );
                          },
                          child: CircleAvatar(
                            radius: 45,
                            backgroundColor: Colors.black,
                            child: CircleAvatar(
                              radius: 40,
                              backgroundColor: Colors.black,
                              backgroundImage: NetworkImage(
                                widget.profileData.avatarUrl,
                              ),
                            ),
                          ),
                        ),
                        widget.isMe
                            ? Padding(
                                padding: const EdgeInsets.only(top: 60),
                                child: OutlinedButton(
                                  onPressed: () {
                                    context
                                        .push<EditProfileStatus>(
                                          "/editProfile",
                                          extra: widget.profileData,
                                        )
                                        .then((status) {
                                          if (status ==
                                              EditProfileStatus
                                                  .changedSuccessfully) {
                                            ref.read(
                                              profileBasicDataNotifierProvider(
                                                widget.profileData.username,
                                              ).notifier,
                                            )..loadProfileData(
                                              widget.profileData.username,
                                            );
                                          } else if (status ==
                                              EditProfileStatus
                                                  .failedToChange) {
                                            showTopSnackBar(
                                              Overlay.of(context),
                                              CustomSnackBar.error(
                                                backgroundColor: Color(
                                                  0XFF212121,
                                                ),
                                                icon: Icon(
                                                  Icons.error,
                                                  color: Colors.red,
                                                ),
                                                message:
                                                    "Profile update failed",
                                              ),
                                              displayDuration: const Duration(
                                                seconds: 2,
                                              ),
                                            );
                                          } else {}
                                        });
                                  },
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.white,
                                    side: const BorderSide(
                                      color: Color(0xFFADADAD),
                                      width: 1,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 15,
                                    ),
                                  ),
                                  child: Text(
                                    "Edit profile",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              )
                            : Follow_Following_Button(
                                profileData: widget.profileData,
                              ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    InkWell(
                      onTap: () {
                        //   TODO: ADD verifying logic
                      },
                      child: Wrap(
                        children: [
                          Text(
                            widget.profileData.displayName,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          if (widget.isMe)
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const SizedBox(width: 4),
                                const Icon(
                                  Icons.verified,
                                  color: Color(0xFF1DA1F2),
                                  size: 18,
                                ),
                                const SizedBox(width: 8),
                                if (!widget.profileData.isVerified)
                                  Text(
                                    'Get Verified',
                                    style: TextStyle(
                                      color: Color(0xFF1DA1F2),
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                              ],
                            ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 8),
                    Wrap(
                      children: [
                        Text(
                          "@${widget.profileData.username}",
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 15,
                          ),
                        ),
                        SizedBox(width: 10),
                        if (widget.isMe == false &&
                            widget.profileData.isFollower)
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 5),

                            // width: 75,
                            decoration: BoxDecoration(
                              color: Color(0XFF1F2225),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Follows you",
                                  style: TextStyle(
                                    color: Color(0xFF6D7176),
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (widget.profileData.bio.isNotEmpty)
                      Text(
                        widget.profileData.bio,
                        style: const TextStyle(fontSize: 15),
                        maxLines: 3,
                      ),
                    if (widget.profileData.bio.isNotEmpty)
                      const SizedBox(height: 5),
                    const SizedBox(height: 8),

                    Wrap(
                      runSpacing: 8,
                      children: [
                        if (widget.profileData.location.isNotEmpty)
                          Wrap(
                            children: [
                              const Icon(
                                Icons.location_on_outlined,
                                color: Colors.grey,
                                size: 16,
                              ),
                              const SizedBox(width: 1),
                              Text(
                                widget.profileData.location,
                                style: const TextStyle(color: Colors.grey),
                                maxLines: 1,
                                overflow: TextOverflow.clip,
                              ),
                              const SizedBox(width: 12),
                            ],
                          ),

                        if (widget.profileData.website.isNotEmpty)
                          Wrap(
                            children: [
                              SvgPicture.asset(
                                "assets/svg/website.svg",
                                width: 16,
                                height: 16,
                                colorFilter: ColorFilter.mode(
                                  Colors.grey,
                                  BlendMode.srcIn,
                                ),
                              ),
                              const SizedBox(width: 2),
                              GestureDetector(
                                onTap: () async {
                                  final url = widget.profileData.website;
                                  final uri = Uri.parse(
                                    url.startsWith('http')
                                        ? url
                                        : 'https://$url',
                                  );

                                  if (await canLaunchUrl(uri)) {
                                    await launchUrl(
                                      uri,
                                      mode: LaunchMode.inAppBrowserView,
                                    );
                                  } else {
                                    // Show error message
                                    if (mounted) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'Could not open website',
                                          ),
                                        ),
                                      );
                                    }
                                  }
                                },
                                child: Text(
                                  widget.profileData.website,
                                  style: const TextStyle(
                                    color: Colors.blueAccent,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.clip,
                                ),
                              ),

                              const SizedBox(width: 12),
                            ],
                          ),

                        if (widget.profileData.birthDate.isNotEmpty)
                          Wrap(
                            children: [
                              SvgPicture.asset(
                                "assets/svg/born.svg",
                                width: 16,
                                height: 16,
                                colorFilter: const ColorFilter.mode(
                                  Colors.grey,
                                  BlendMode.srcIn,
                                ),
                              ),
                              const SizedBox(width: 1),
                              Text(
                                "Born ${widget.profileData.birthDate}",
                                style: const TextStyle(color: Colors.grey),
                              ),
                              const SizedBox(width: 12),
                            ],
                          ),
                        if (widget.profileData.joinedDate.isNotEmpty)
                          Wrap(
                            children: [
                              const Icon(
                                Icons.calendar_month_outlined,
                                color: Colors.grey,
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                "Joined ${widget.profileData.joinedDate}",
                                style: const TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            context.push(
                              "/followingfollowersscreen/${FollowingFollowersInitialTab.Following}/${widget.isMe ? "me" : "notme"}",
                              extra: this.widget.profileData,
                            );
                          },
                          child: _buildFollowCount(
                            widget.profileData.followingCount,
                            'Following',
                          ),
                        ),
                        const SizedBox(width: 16),
                        GestureDetector(
                          onTap: () {
                            //   TODO: navigae to followers page
                            context.push(
                              "/followingfollowersscreen/${FollowingFollowersInitialTab.Followers}/${widget.isMe ? "me" : "notme"}",
                              extra: this.widget.profileData,
                            );
                          },
                          child: _buildFollowCount(
                            widget.profileData.followersCount,
                            'Follower',
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
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
