import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:lite_x/core/providers/current_user_provider.dart';
import 'package:lite_x/features/media/view_model/providers.dart';
import 'package:lite_x/features/profile/models/profile_model.dart';
import 'package:lite_x/features/profile/models/profile_tweet_model.dart';
import 'package:lite_x/features/profile/models/shared.dart';
import 'package:lite_x/features/profile/view_model/providers.dart';
import 'package:readmore/readmore.dart';

class ProfileNormalTweetWidget extends ConsumerWidget implements ProfileTweet {
  const ProfileNormalTweetWidget({
    required this.profileModel,
    required this.profilePostModel,
  });
  final ProfileModel profileModel;
  final ProfileTweetModel profilePostModel;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(8.0).copyWith(right: 16),
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
                    radius: 20,
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
                              this.profilePostModel.userDisplayName,
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
                              "@${this.profilePostModel.userUserName}",
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
                InkWell(
                  onTap: () {
                    context.push(
                      "/tweetDetailsScreen/${this.profilePostModel.id}",
                    );
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
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
                          child: TweetMediaGrid(
                            mediaIds: profilePostModel.mediaIds,
                          ),
                          clipBehavior: Clip.hardEdge,
                        ),
                    ],
                  ),
                ),
                InterActionsRowOfTweet(tweet: this.profilePostModel),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Widget buildPhotoSection(List<dynamic> photos) {
//   // if (photos.isEmpty) return const SizedBox.shrink();

//   // if (photos.length == 1) {
//   //   return Image.network(photos[0], fit: BoxFit.cover);
//   // }

//   // if (photos.length == 2) {
//   //   return Row(
//   //     // crossAxisAlignment: CrossAxisAlignment.end,
//   //     children: [
//   //       Expanded(child: Image.network(photos[0], fit: BoxFit.fill)),
//   //       Expanded(child: Image.network(photos[1], fit: BoxFit.fill)),
//   //     ],
//   //   );
//   // } else if (photos.length == 3) {
//   //   return Row(
//   //     crossAxisAlignment: CrossAxisAlignment.stretch,
//   //     children: [
//   //       Expanded(child: Image.network(photos[0], fit: BoxFit.cover)),
//   //       const SizedBox(width: 4),
//   //       Expanded(
//   //         child: Column(
//   //           crossAxisAlignment: CrossAxisAlignment.stretch,
//   //           children: [
//   //             Expanded(child: Image.network(photos[1], fit: BoxFit.cover)),
//   //             const SizedBox(height: 4),
//   //             Expanded(child: Image.network(photos[2], fit: BoxFit.cover)),
//   //           ],
//   //         ),
//   //       ),
//   //     ],
//   //   );
//   // } else if (photos.length == 4) {
//   //   return Row(
//   //     crossAxisAlignment: CrossAxisAlignment.stretch,
//   //     children: [
//   //       Expanded(
//   //         child: Column(
//   //           crossAxisAlignment: CrossAxisAlignment.stretch,
//   //           children: [
//   //             Expanded(child: Image.network(photos[0], fit: BoxFit.cover)),
//   //             const SizedBox(height: 4),
//   //             Expanded(child: Image.network(photos[3], fit: BoxFit.cover)),
//   //           ],
//   //         ),
//   //       ),
//   //       const SizedBox(width: 4),
//   //       Expanded(
//   //         child: Column(
//   //           crossAxisAlignment: CrossAxisAlignment.stretch,
//   //           children: [
//   //             Expanded(child: Image.network(photos[1], fit: BoxFit.cover)),
//   //             const SizedBox(height: 4),
//   //             Expanded(child: Image.network(photos[2], fit: BoxFit.cover)),
//   //           ],
//   //         ),
//   //       ),
//   //     ],
//   //   );
//   // }

//   return const SizedBox.shrink();
// }

void _openProfileTweetOptions(
  BuildContext context,
  WidgetRef ref,
  ProfileTweetModel tweet,
) async {
  final currentUser = ref.watch(currentUserProvider);
  final currneusername = currentUser?.username ?? "";

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
          if (currneusername == tweet.userUserName)
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
                    if (currentUser != null)
                      // ignore: unused_result
                      ref.refresh(profilePostsProvider(currentUser.username));
                  },
                );
                // TODO: make delete post logic
                context.pop();
              },
            ),
          if (currneusername == tweet.userUserName)
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
    return _buildMediaGrid(mediaIds, ref);
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

  Widget _errorContainer(double height) {
    return Container(
      color: Colors.grey,
      height: height,
      child: Center(child: Text("can't load image")),
    );
  }

  Widget _loadingContainer(double height, {double? value}) {
    return Container(
      color: Colors.grey,
      height: 300,
      child: Center(
        child: CircularProgressIndicator(color: Colors.white, value: value),
      ),
    );
  }

  Widget _buildMediaGrid(List<String> photos, WidgetRef ref) {
    if (photos.isEmpty) return const SizedBox.shrink();

    if (photos.length == 1) {
      final mediaUrl = ref.watch(mediaUrlProvider(photos[0]));
      return mediaUrl.when(
        data: (url) {
          return CachedNetworkImage(
            imageUrl: url,
            fit: BoxFit.cover,
            errorWidget: (context, url, error) => _errorContainer(300),
            progressIndicatorBuilder: (context, url, progress) =>
                _loadingContainer(300, value: progress.progress),
          );
        },
        error: (err, _) {
          return _errorContainer(300);
        },
        loading: () {
          return _loadingContainer(300);
        },
      );
    }

    if (photos.length == 2) {
      final mediaUrl0 = ref.watch(mediaUrlProvider(photos[0]));
      final mediaUrl1 = ref.watch(mediaUrlProvider(photos[1]));
      return Row(
        children: [
          Expanded(
            child: mediaUrl0.when(
              data: (url) {
                return CachedNetworkImage(
                  imageUrl: url,
                  fit: BoxFit.cover,
                  errorWidget: (context, url, error) => _errorContainer(150),
                  progressIndicatorBuilder: (context, url, progress) =>
                      _loadingContainer(150, value: progress.progress),
                );
              },
              error: (err, _) {
                return _errorContainer(150);
              },
              loading: () {
                return _loadingContainer(150);
              },
            ),
          ),
          Expanded(
            child: mediaUrl1.when(
              data: (url) {
                return CachedNetworkImage(
                  imageUrl: url,
                  fit: BoxFit.cover,
                  errorWidget: (context, url, error) => _errorContainer(150),
                  progressIndicatorBuilder: (context, url, progress) =>
                      _loadingContainer(150, value: progress.progress),
                );
              },
              error: (err, _) {
                return _errorContainer(150);
              },
              loading: () {
                return _loadingContainer(150);
              },
            ),
          ),
        ],
      );
    } else if (photos.length == 3) {
      final mediaUrl0 = ref.watch(mediaUrlProvider(photos[0]));
      final mediaUrl1 = ref.watch(mediaUrlProvider(photos[1]));
      final mediaUrl2 = ref.watch(mediaUrlProvider(photos[2]));
      return Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: mediaUrl0.when(
              data: (url) {
                return CachedNetworkImage(
                  imageUrl: url,
                  fit: BoxFit.cover,
                  errorWidget: (context, url, error) => _errorContainer(300),
                  progressIndicatorBuilder: (context, url, progress) =>
                      _loadingContainer(300, value: progress.progress),
                );
              },
              error: (err, _) {
                return _errorContainer(300);
              },
              loading: () {
                return _loadingContainer(300);
              },
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: mediaUrl1.when(
                    data: (url) {
                      return CachedNetworkImage(
                        imageUrl: url,
                        fit: BoxFit.cover,
                        errorWidget: (context, url, error) =>
                            _errorContainer(148),
                        progressIndicatorBuilder: (context, url, progress) =>
                            _loadingContainer(148, value: progress.progress),
                      );
                    },
                    error: (err, _) {
                      return _errorContainer(148);
                    },
                    loading: () {
                      return _loadingContainer(148);
                    },
                  ),
                ),
                const SizedBox(height: 4),
                Expanded(
                  child: mediaUrl2.when(
                    data: (url) {
                      return CachedNetworkImage(
                        imageUrl: url,
                        fit: BoxFit.cover,
                        errorWidget: (context, url, error) =>
                            _errorContainer(148),
                        progressIndicatorBuilder: (context, url, progress) =>
                            _loadingContainer(148, value: progress.progress),
                      );
                    },
                    error: (err, _) {
                      return _errorContainer(148);
                    },
                    loading: () {
                      return _loadingContainer(148);
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    } else if (photos.length == 4) {
      final mediaUrl0 = ref.watch(mediaUrlProvider(photos[0]));
      final mediaUrl1 = ref.watch(mediaUrlProvider(photos[1]));
      final mediaUrl2 = ref.watch(mediaUrlProvider(photos[2]));
      final mediaUrl3 = ref.watch(mediaUrlProvider(photos[3]));
      return Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: mediaUrl0.when(
                    data: (url) {
                      return CachedNetworkImage(
                        imageUrl: url,
                        fit: BoxFit.cover,
                        errorWidget: (context, url, error) =>
                            _errorContainer(148),
                        progressIndicatorBuilder: (context, url, progress) =>
                            _loadingContainer(148, value: progress.progress),
                      );
                    },
                    error: (err, _) {
                      return _errorContainer(148);
                    },
                    loading: () {
                      return _loadingContainer(148);
                    },
                  ),
                ),
                const SizedBox(height: 4),
                Expanded(
                  child: mediaUrl3.when(
                    data: (url) {
                      return CachedNetworkImage(
                        imageUrl: url,
                        fit: BoxFit.cover,
                        errorWidget: (context, url, error) =>
                            _errorContainer(148),
                        progressIndicatorBuilder: (context, url, progress) =>
                            _loadingContainer(148, value: progress.progress),
                      );
                    },
                    error: (err, _) {
                      return _errorContainer(148);
                    },
                    loading: () {
                      return _loadingContainer(148);
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: mediaUrl1.when(
                    data: (url) {
                      return CachedNetworkImage(
                        imageUrl: url,
                        fit: BoxFit.cover,
                        errorWidget: (context, url, error) =>
                            _errorContainer(148),
                        progressIndicatorBuilder: (context, url, progress) =>
                            _loadingContainer(148, value: progress.progress),
                      );
                    },
                    error: (err, _) {
                      return _errorContainer(148);
                    },
                    loading: () {
                      return _loadingContainer(148);
                    },
                  ),
                ),
                const SizedBox(height: 4),
                Expanded(
                  child: mediaUrl2.when(
                    data: (url) {
                      return CachedNetworkImage(
                        imageUrl: url,
                        fit: BoxFit.cover,
                        errorWidget: (context, url, error) =>
                            _errorContainer(148),
                        progressIndicatorBuilder: (context, url, progress) =>
                            _loadingContainer(148, value: progress.progress),
                      );
                    },
                    error: (err, _) {
                      return _errorContainer(148);
                    },
                    loading: () {
                      return _loadingContainer(148);
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    return const SizedBox.shrink();
  }
}
