import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:lite_x/core/providers/current_user_provider.dart';
import 'package:lite_x/features/profile/models/profile_model.dart';
import 'package:lite_x/features/profile/models/profile_tweet_model.dart';
import 'package:lite_x/features/profile/models/shared.dart';
import 'package:lite_x/features/profile/view_model/providers.dart';
import 'package:readmore/readmore.dart';

class ProfileNormarTweetQuot extends ConsumerWidget implements ProfileTweet {
  const ProfileNormarTweetQuot({
    required this.profileModel,
    required this.profilePostModel,
  });
  final ProfileModel profileModel;
  final ProfileTweetModel profilePostModel;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(8.0).copyWith(left: 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Padding(
            padding: EdgeInsets.only(left: 8, right: 10, top: 2),
            child: Column(
              children: [
                GestureDetector(
                  onTap: () {
                    final currentUser = ref.watch(currentUserProvider);
                    final currentUserName = currentUser?.username ?? "";
                    if (currentUserName == this.profileModel.username) {
                      context.pushReplacement(
                        "/profilescreen/${this.profileModel.username}",
                      );
                      return;
                    }
                    context.push(
                      "/profilescreen/${this.profileModel.username}",
                    );
                  },
                  child: BuildSmallProfileImage(
                    mediaId: profilePostModel.profileMediaId,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            constraints: BoxConstraints(maxWidth: 120),
                            child: Text(
                              profileModel.displayName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              "@${profileModel.username}",
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 14,
                              ),
                              overflow: TextOverflow.ellipsis,
                              softWrap: false,
                            ),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            "· ${profilePostModel.timeAgo}",
                            style: TextStyle(color: Colors.grey, fontSize: 16),
                            textAlign: TextAlign.start,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 4),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SvgPicture.asset(
                          "assets/svg/grok.svg",
                          width: 20,
                          height: 20,
                          colorFilter: const ColorFilter.mode(
                            Colors.grey,
                            BlendMode.srcIn,
                          ),
                        ),
                        SizedBox(width: 8),
                        GestureDetector(
                          onTap: () {
                            _openProfileTweetOptions(
                              context,
                              ref,
                              this.profilePostModel,
                            );
                          },
                          child: Icon(
                            Icons.more_vert,
                            color: Colors.grey,
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                profilePostModel.text.isEmpty
                    ? const SizedBox(height: 15)
                    : Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: ReadMoreText(
                          profilePostModel.text,
                          trimLines: 3,
                          colorClickableText: Colors.grey,
                          trimMode: TrimMode.Line,
                          trimCollapsedText: 'Show more',
                          trimExpandedText: ' show less',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                if (profilePostModel.mediaIds.isNotEmpty)
                  Container(
                    width: 350,
                    // height: 350,
                    constraints: BoxConstraints(maxHeight: 400),

                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    // child: buildPhotoSection(profilePostModel.mediaIds),
                    child: TweetMediaGrid(mediaIds: profilePostModel.mediaIds),
                    clipBehavior: Clip.hardEdge,
                  ),
                // InterActionsRowOfTweet(tweet: this.profilePostModel),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

Widget buildPhotoSection(List<dynamic> photos) {
  // if (photos.isEmpty) return const SizedBox.shrink();

  // if (photos.length == 1) {
  //   return Image.network(photos[0], fit: BoxFit.cover);
  // }

  // if (photos.length == 2) {
  //   return Row(
  //     // crossAxisAlignment: CrossAxisAlignment.end,
  //     children: [
  //       Expanded(child: Image.network(photos[0], fit: BoxFit.fill)),
  //       Expanded(child: Image.network(photos[1], fit: BoxFit.fill)),
  //     ],
  //   );
  // } else if (photos.length == 3) {
  //   return Row(
  //     crossAxisAlignment: CrossAxisAlignment.stretch,
  //     children: [
  //       Expanded(child: Image.network(photos[0], fit: BoxFit.cover)),
  //       const SizedBox(width: 4),
  //       Expanded(
  //         child: Column(
  //           crossAxisAlignment: CrossAxisAlignment.stretch,
  //           children: [
  //             Expanded(child: Image.network(photos[1], fit: BoxFit.cover)),
  //             const SizedBox(height: 4),
  //             Expanded(child: Image.network(photos[2], fit: BoxFit.cover)),
  //           ],
  //         ),
  //       ),
  //     ],
  //   );
  // } else if (photos.length == 4) {
  //   return Row(
  //     crossAxisAlignment: CrossAxisAlignment.stretch,
  //     children: [
  //       Expanded(
  //         child: Column(
  //           crossAxisAlignment: CrossAxisAlignment.stretch,
  //           children: [
  //             Expanded(child: Image.network(photos[0], fit: BoxFit.cover)),
  //             const SizedBox(height: 4),
  //             Expanded(child: Image.network(photos[3], fit: BoxFit.cover)),
  //           ],
  //         ),
  //       ),
  //       const SizedBox(width: 4),
  //       Expanded(
  //         child: Column(
  //           crossAxisAlignment: CrossAxisAlignment.stretch,
  //           children: [
  //             Expanded(child: Image.network(photos[1], fit: BoxFit.cover)),
  //             const SizedBox(height: 4),
  //             Expanded(child: Image.network(photos[2], fit: BoxFit.cover)),
  //           ],
  //         ),
  //       ),
  //     ],
  //   );
  // }

  return const SizedBox.shrink();
}

class InterActionsRowOfTweet extends ConsumerStatefulWidget {
  const InterActionsRowOfTweet({super.key, required this.tweet});
  final ProfileTweetModel tweet;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _InterActionsRowOfTweetState();
}

class _InterActionsRowOfTweetState
    extends ConsumerState<InterActionsRowOfTweet> {
  late bool isLikedByMeLocal;
  late int likesCount;
  late bool isSavedByMeLocal;
  @override
  void initState() {
    isLikedByMeLocal = widget.tweet.isLikedByMe;
    likesCount = widget.tweet.likes;
    isSavedByMeLocal = widget.tweet.isSavedByMe;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () {
              //   TODO: open replying page
            },
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                SvgPicture.asset(
                  "assets/svg/reply.svg",
                  width: 20,
                  height: 20,
                  colorFilter: const ColorFilter.mode(
                    Colors.grey,
                    BlendMode.srcIn,
                  ),
                ),
                if (widget.tweet.replies > 0)
                  Text(
                    Shared.formatCount(widget.tweet.replies),
                    style: TextStyle(color: Colors.grey, fontSize: 15),
                  ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              //   TODO: do repost action
            },
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SvgPicture.asset(
                  "assets/svg/repost.svg",
                  width: 20,
                  height: 20,
                  colorFilter: ColorFilter.mode(
                    widget.tweet.isRepostedWithMe
                        ? Color(0XFF00B87B)
                        : Colors.grey,
                    BlendMode.srcIn,
                  ),
                ),
                if (widget.tweet.retweets > 0)
                  Text(
                    Shared.formatCount(widget.tweet.retweets),
                    style: TextStyle(
                      color: widget.tweet.isRepostedWithMe
                          ? Color(0XFF00B87B)
                          : Colors.grey,
                      fontSize: 15,
                    ),
                  ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              //   TODO: do like action
              if (isLikedByMeLocal) {
                final unlike = ref.watch(unlikeTweetProvider);
                unlike(widget.tweet.id).then((res) {
                  res.fold((l) {
                    isLikedByMeLocal = true;
                    likesCount += 1;
                    showSmallPopUpMessage(
                      context: context,
                      message: l.message,
                      borderColor: Colors.red,
                      icon: Icon(Icons.error, color: Colors.red),
                    );
                    if (mounted) setState(() {});
                  }, (r) {});
                });
              } else {
                final like = ref.watch(likeTweetProvider);
                like(widget.tweet.id).then((res) {
                  res.fold((l) {
                    isLikedByMeLocal = false;
                    likesCount -= 1;
                    showSmallPopUpMessage(
                      context: context,
                      message: l.message,
                      borderColor: Colors.red,
                      icon: Icon(Icons.error, color: Colors.red),
                    );
                    if (mounted) setState(() {});
                  }, (r) {});
                });
              }
              if (mounted)
                setState(() {
                  if (isLikedByMeLocal)
                    likesCount -= 1;
                  else
                    likesCount += 1;
                  isLikedByMeLocal = !isLikedByMeLocal;
                });
            },
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SvgPicture.asset(
                  isLikedByMeLocal
                      ? "assets/svg/like_filled.svg"
                      : "assets/svg/like.svg",
                  width: 20,
                  height: 20,
                  colorFilter: ColorFilter.mode(
                    isLikedByMeLocal ? Color(0XFFF6187E) : Colors.grey,
                    BlendMode.srcIn,
                  ),
                ),
                if (likesCount > 0)
                  Text(
                    Shared.formatCount(likesCount),
                    style: TextStyle(
                      color: isLikedByMeLocal ? Color(0XFFF6187E) : Colors.grey,
                      fontSize: 15,
                    ),
                  ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              //   TODO: do activity action
            },
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SvgPicture.asset(
                  "assets/svg/activity.svg",
                  width: 20,
                  height: 20,
                  colorFilter: ColorFilter.mode(Colors.grey, BlendMode.srcIn),
                ),
                if (widget.tweet.activityNumber > 0)
                  Text(
                    Shared.formatCount(widget.tweet.activityNumber),
                    style: TextStyle(color: Colors.grey, fontSize: 15),
                  ),
              ],
            ),
          ),
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  //   TODO: do like action
                  if (isSavedByMeLocal) {
                    final unSave = ref.watch(unSaveTweetProvider);
                    unSave(widget.tweet.id).then((res) {
                      res.fold(
                        (l) {
                          isSavedByMeLocal = true;
                          showSmallPopUpMessage(
                            context: context,
                            message: l.message,
                            borderColor: Colors.red,
                            icon: Icon(Icons.error, color: Colors.red),
                          );
                          if (mounted) setState(() {});
                        },
                        (r) {
                          showSmallPopUpMessage(
                            context: context,
                            message: "Post removed from your Bookmarks",
                            borderColor: Colors.blue,
                            icon: Icon(
                              Icons.bookmark_remove,
                              color: Colors.blue,
                            ),
                          );
                        },
                      );
                    });
                  } else {
                    final save = ref.watch(saveTweetProvider);
                    save(widget.tweet.id).then((res) {
                      res.fold(
                        (l) {
                          isSavedByMeLocal = false;
                          showSmallPopUpMessage(
                            context: context,
                            message: l.message,
                            borderColor: Colors.red,
                            icon: Icon(Icons.error, color: Colors.red),
                          );
                          if (mounted) setState(() {});
                        },
                        (r) {
                          showSmallPopUpMessage(
                            context: context,
                            message: "Post added to your Bookmarks",
                            borderColor: Colors.blue,
                            icon: Icon(Icons.bookmark_add, color: Colors.blue),
                          );
                        },
                      );
                    });
                  }
                  if (mounted)
                    setState(() {
                      isSavedByMeLocal = !isSavedByMeLocal;
                    });
                },
                child: SvgPicture.asset(
                  isSavedByMeLocal
                      ? "assets/svg/save_filled.svg"
                      : "assets/svg/save.svg",
                  width: 20,
                  height: 20,
                  colorFilter: ColorFilter.mode(
                    isSavedByMeLocal ? Colors.blue : Colors.grey,
                    BlendMode.srcIn,
                  ),
                ),
              ),
              SizedBox(width: 8),
              GestureDetector(
                onTap: () {
                  //   TODO: do share action
                },
                child: Icon(Icons.share_outlined, color: Colors.grey, size: 20),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

void _openProfileTweetOptions(
  BuildContext context,
  WidgetRef ref,
  ProfileTweetModel tweet,
) async {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.black,

    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (_) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ProfileTweetOptin(
            text: "Pin to profile",
            icon: Icons.push_pin_outlined,
            onPress: () async {
              await Future.delayed(Duration(milliseconds: 100));
              // TODO: make pin logic
              context.pop();
            },
          ),
          ProfileTweetOptin(
            text: "Delete post",
            icon: Icons.delete,
            onPress: () async {
              final delete = await ref.watch(deleteTweetProvider);
              final res = await delete(tweet.id);
              res.fold(
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
                    message: "Tweet deleted successfully",
                    borderColor: Colors.blue,
                    icon: Icon(Icons.check, color: Colors.blue),
                  );
                  final currentUser = ref.watch(currentUserProvider);
                  if (currentUser != null)
                    // ignore: unused_result
                    ref.refresh(profilePostsProvider(currentUser.id));
                },
              );
              // TODO: make delete post logic
              context.pop();
            },
          ),
          ProfileTweetOptin(
            text: "Change who can reply",
            icon: Icons.mode_comment_outlined,
            onPress: () async {
              await Future.delayed(Duration(milliseconds: 100));

              // TODO: make who can reply logic logic
              context.pop();
            },
          ),
          ProfileTweetOptin(
            text: "Request Community Note",
            icon: Icons.public,
            onPress: () async {
              await Future.delayed(Duration(milliseconds: 100));

              // TODO: make who can reply logic logic
              context.pop();
            },
          ),
        ],
      );
    },
  );
}

class ProfileTweetOptin extends StatelessWidget {
  const ProfileTweetOptin({
    super.key,
    required this.text,
    required this.icon,
    required this.onPress,
  });
  final String text;
  final IconData icon;
  final Function onPress;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 10, left: 10),
      child: ListTile(
        title: Text(text, style: TextStyle(fontSize: 18)),
        leading: Icon(icon, color: Colors.grey, size: 25),
        onTap: () {
          onPress();
        },
      ),
    );
  }
}

class TweetMediaGrid extends ConsumerWidget {
  const TweetMediaGrid({super.key, required this.mediaIds});
  final List<String> mediaIds;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mediaUrlsAsync = ref.watch(mediaUrlsProvider(mediaIds));

    return mediaUrlsAsync.when(
      loading: () => _buildMediaSkeleton(),
      error: (error, stack) => _buildErrorWidget(),
      data: (mediaUrls) => _buildMediaGrid(mediaUrls),
    );
  }

  Widget _buildMediaSkeleton() {
    return Container(
      width: 350,
      constraints: const BoxConstraints(maxHeight: 400),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey[300],
      ),
      child: const Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildErrorWidget() {
    return Container(
      width: 350,
      constraints: const BoxConstraints(maxHeight: 400),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey[300],
      ),
      child: const Center(child: Icon(Icons.error_outline, color: Colors.grey)),
    );
  }

  Widget _buildMediaGrid(List<String> photos) {
    if (photos.isEmpty) return const SizedBox.shrink();

    if (photos.length == 1) {
      return CachedNetworkImage(
        imageUrl: photos[0] + "",
        fit: BoxFit.cover,
        errorWidget: (context, url, error) => Container(
          color: Colors.grey,
          height: 300,
          child: Center(child: Text("can't load image")),
        ),
      );
    }

    if (photos.length == 2) {
      return Row(
        children: [
          Expanded(
            child: CachedNetworkImage(
              imageUrl: photos[0] + "",
              fit: BoxFit.cover,
              errorWidget: (context, url, error) => Container(
                color: Colors.grey,
                height: 150,
                child: Center(child: Text("can't load image")),
                margin: EdgeInsets.only(right: 3),
              ),
            ),
          ),
          Expanded(
            child: CachedNetworkImage(
              imageUrl: photos[1] + "",
              fit: BoxFit.cover,
              errorWidget: (context, url, error) => Container(
                color: Colors.grey,
                height: 150,
                child: Center(child: Text("can't load image")),
                margin: EdgeInsets.only(left: 3),
              ),
            ),
          ),
        ],
      );
    } else if (photos.length == 3) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: CachedNetworkImage(
              imageUrl: photos[0] + "",
              fit: BoxFit.cover,
              errorWidget: (context, url, error) => Container(
                color: Colors.grey,
                height: 300,
                child: Center(child: Text("can't load image")),
                margin: EdgeInsets.only(left: 3),
              ),
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: CachedNetworkImage(
                    imageUrl: photos[1] + "",
                    fit: BoxFit.cover,
                    errorWidget: (context, url, error) => Container(
                      color: Colors.grey,
                      height: 148,
                      child: Center(child: Text("can't load image")),
                      margin: EdgeInsets.only(left: 3),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Expanded(
                  child: CachedNetworkImage(
                    imageUrl: photos[2] + "",
                    fit: BoxFit.cover,
                    errorWidget: (context, url, error) => Container(
                      color: Colors.grey,
                      height: 148,
                      child: Center(child: Text("can't load image")),
                      margin: EdgeInsets.only(left: 3),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    } else if (photos.length == 4) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: Image.network(photos[0], fit: BoxFit.cover)),
                const SizedBox(height: 4),
                Expanded(child: Image.network(photos[3], fit: BoxFit.cover)),
              ],
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: Image.network(photos[1], fit: BoxFit.cover)),
                const SizedBox(height: 4),
                Expanded(child: Image.network(photos[2], fit: BoxFit.cover)),
              ],
            ),
          ),
        ],
      );
    }

    return const SizedBox.shrink();
  }
}
