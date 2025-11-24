import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:lite_x/core/providers/current_user_provider.dart';
import 'package:lite_x/features/media/download_media.dart';
import 'package:lite_x/features/profile/models/profile_model.dart';
import 'package:lite_x/features/profile/models/profile_tweet_model.dart';
import 'package:lite_x/features/profile/view/widgets/profile_tweets/profile_normal_tweet_widget.dart';
import 'package:lite_x/features/profile/view/widgets/profile_tweets/profile_quote_widget.dart';
import 'package:lite_x/features/profile/view/widgets/profile_tweets/profile_retweet_widget.dart';
import 'package:lite_x/features/profile/view_model/providers.dart';

abstract class Shared {
  static String formatCount(int count) {
    String formatedCount;
    if (count < 1000)
      formatedCount = "$count";
    else if (count >= 1000 && count < 1000000) {
      if (count % 1000 == 0)
        formatedCount = "${(count / 1000)}K";
      else
        formatedCount = "${(count / 1000).toStringAsFixed(1)}K";
    } else {
      if (count % 1000000 == 0)
        formatedCount = "${count / 1000000}M";
      else
        formatedCount = "${(count / 1000000).toStringAsFixed(1)}M";
    }
    return formatedCount;
  }
}

class Failure {
  final String message;
  Failure(this.message);
}

class FollowingFollowersInitialTab {
  static const int VerifiedFollowers = 0;
  static const int FollowersYouKnow = 1;
  static const int Followers = 2;
  static const int Following = 3;
  static const int Subscribed = 4;
  static const int Subscriptions = 5;
}

Future<bool> showUnFollowDialog(
  BuildContext context,
  String nameOfUnfollowedUser,
) async {
  final result = await showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        backgroundColor: Color(0xFF0f0f0f),
        title: Text(
          'Unfollow ${nameOfUnfollowedUser}?',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'Their posts will no longer show up in your home timeline. You can still view their profile, unless their posts are protected.',
          style: TextStyle(fontSize: 14, color: Colors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              // your unfollow logic
              Navigator.of(context).pop(true);
            },
            child: const Text(
              'Unfollow',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      );
    },
  );

  return result;
}

enum EditProfileStatus { changedSuccessfully, unChanged, failedToChange }

enum DateFormatType { monthAndDayOnly, yearOnly, fullDate }

String mapMonth(int month) {
  const months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];
  return months[month - 1];
}

String formatDate(DateTime? date, DateFormatType type) {
  if (date == null) return "";
  switch (type) {
    case DateFormatType.monthAndDayOnly:
      return "${mapMonth(date.month)} ${date.day}";
    case DateFormatType.yearOnly:
      return "${date.year}";
    case DateFormatType.fullDate:
      return "${mapMonth(date.month)} ${date.day}, ${date.year}";
  }
}

DateTime? parseFormattedDate(String formattedDate) {
  if (formattedDate.isEmpty) return null;
  final months = {
    'January': 1,
    'February': 2,
    'March': 3,
    'April': 4,
    'May': 5,
    'June': 6,
    'July': 7,
    'August': 8,
    'September': 9,
    'October': 10,
    'November': 11,
    'December': 12,
  };

  final regex = RegExp(r'([A-Za-z]+)\s(\d{1,2}),\s(\d{4})');
  final match = regex.firstMatch(formattedDate);
  if (match == null) {
    return null;
  }

  final monthName = match.group(1)!;
  final day = int.parse(match.group(2)!);
  final year = int.parse(match.group(3)!);
  final month = months[monthName]!;

  return DateTime(year, month, day);
}

Future<bool?> showPopupMessage({
  required BuildContext context,
  required Text title,
  required Text message,
  String confirmText = 'Yes',
  String cancelText = 'No',
}) async {
  return showDialog<bool>(
    context: context,
    barrierDismissible: true, // prevent closing by tapping outside
    builder: (BuildContext context) {
      return AlertDialog(
        title: title,
        content: message,
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              cancelText,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              confirmText,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      );
    },
  );
}

class ProfilePhotoScreenArgs {
  final bool isMe;
  final ProfileModel profileModel;

  ProfilePhotoScreenArgs({required this.isMe, required this.profileModel});
}

enum TweetType { Tweet, ReTweet, Quote, Reply }

abstract class ProfileTweet implements Widget {}

ProfileTweet getCorrectTweetType(
  ProfileTweetModel tweetModel,
  ProfileModel pm,
) {
  TweetType type = tweetModel.type;

  if (type == TweetType.ReTweet)
    return ProfileRetweetWidget(profileModel: pm, tweetModel: tweetModel);

  if (type == TweetType.Quote)
    return ProfileQuoteWidget(tweetModel: tweetModel, profileModel: pm);

  return ProfileNormalTweetWidget(
    profileModel: pm,
    profilePostModel: tweetModel,
  );
}

void showSmallPopUpMessage({
  required BuildContext context,
  required String message,
  required Color borderColor,
  required Icon icon,
}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            icon,
            SizedBox(width: 10),
            Flexible(
              child: Text(
                message,
                style: TextStyle(fontSize: 16),
                overflow: TextOverflow.clip,
              ),
            ),
          ],
        ),
      ),
      duration: Duration(seconds: 2),
      behavior: SnackBarBehavior.floating,
      margin: EdgeInsets.all(30),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(width: 0.8, color: borderColor),
      ),
    ),
  );
}

String getTimeAgo(String backendTime) {
  try {
    DateTime postTime = DateTime.parse(backendTime);
    DateTime currentTime = DateTime.now().toUtc();
    Duration difference = currentTime.difference(postTime);

    if (difference.isNegative) {
      return 'now';
    }

    int seconds = difference.inSeconds;

    if (seconds < 60) {
      return '${seconds}s';
    }

    int minutes = difference.inMinutes;
    if (minutes < 60) {
      return '${minutes}m';
    }

    int hours = difference.inHours;
    if (hours < 24) {
      return '${hours}h';
    }

    int days = difference.inDays;
    if (days < 7) {
      return '${days}d';
    }

    if (days < 30) {
      int weeks = (days / 7).floor();
      return '${weeks}w';
    }

    if (days < 365) {
      int months = (days / 30).floor();
      return '${months}mo';
    }

    int years = (days / 365).floor();
    return '${years}y';
  } catch (e) {
    return 'now';
  }
}

enum ProfileTabType { Posts, Media, Likes, Replies, Highlights, Articles }

class BuildSmallProfileImage extends ConsumerStatefulWidget {
  BuildSmallProfileImage({super.key, this.mediaId, this.userId});
  String? mediaId;
  String? userId;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _BuildSmallProfileImageState();
}

class _BuildSmallProfileImageState
    extends ConsumerState<BuildSmallProfileImage> {
  String _media = "";
  void _getMedia() async {
    if (mounted) {
      // TODO: implement initState
      if (widget.mediaId == null && widget.userId == null) {
        if (mounted)
          setState(() {
            _loading = false;
          });
        return;
      } else if (widget.mediaId == null) {
        final currentUser = ref.watch(currentUserProvider);
        final profileData = ref.watch(
          profileDataProvider(currentUser?.username ?? ""),
        );
        profileData.whenData((data) {
          data.fold(
            (l) {
              if (mounted)
                setState(() {
                  _loading = false;
                  _media =
                      "https://t4.ftcdn.net/jpg/09/64/89/19/360_F_964891988_aeRrD7Ee7IhmKQhYkCrkrfE6UHtILfPp.jpg";
                });
            },
            (r) {
              _media = r.avatarUrl;
              if (mounted)
                setState(() {
                  _loading = false;
                });
            },
          );
        });
        return;
      } else if (widget.mediaId!.isEmpty) {}
      getMediaUrls([widget.mediaId!]).then((res) {
        _media = res[0];
        if (mounted)
          setState(() {
            _loading = false;
          });
      });
    } else
      return;
  }

  bool _loading = true;

  @override
  Widget build(BuildContext context) {
    if (_loading == true) {
      _getMedia();
      return CircleAvatar(
        backgroundColor: Colors.grey,
        radius: 20,
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }

    return CircleAvatar(
      backgroundImage: CachedNetworkImageProvider(_media),
      backgroundColor: Colors.grey,
      radius: 20,
      onBackgroundImageError: (exception, stackTrace) => null,
    );
  }
}

const String unkownUserAvatar =
    "https://t4.ftcdn.net/jpg/09/64/89/19/360_F_964891988_aeRrD7Ee7IhmKQhYkCrkrfE6UHtILfPp.jpg";

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
