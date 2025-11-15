import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:lite_x/features/profile/models/profile_model.dart';
import 'package:lite_x/features/profile/models/profile_post_model.dart';
import 'package:lite_x/features/profile/models/shared.dart';
import 'package:readmore/readmore.dart';

class ProfilePostWidget extends StatelessWidget {
  const ProfilePostWidget({
    required this.profileModel,
    required this.profilePostModel,
  });
  final ProfileModel profileModel;
  final ProfilePostModel profilePostModel;
  @override
  Widget build(BuildContext context) {
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
                CircleAvatar(
                  backgroundColor: Colors.grey,
                  backgroundImage: profileModel.avatarUrl.isNotEmpty
                      ? NetworkImage(profileModel.avatarUrl)
                      : null,
                  radius: 20,
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
                        Icon(Icons.more_vert, color: Colors.grey, size: 20),
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
                          trimLines:
                              3, // Number of lines to display before "read more"
                          colorClickableText:
                              Colors.grey, // Color of the "read more/less" text
                          trimMode: TrimMode
                              .Line, // Trim by line count or character count
                          trimCollapsedText:
                              'Show more', // Text for the collapsed state
                          trimExpandedText:
                              ' show less', // Text for the expanded state
                          style: TextStyle(
                            fontSize: 16,
                          ), // Style for the main text// Optional text before the main content// Style for preDataText
                        ),
                      ),
                if (profilePostModel.mediaUrls.isNotEmpty)
                  Container(
                    width: 350,
                    height: 220,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: buildPhotoSection(profilePostModel.mediaUrls),
                    clipBehavior: Clip.hardEdge,
                  ),
                buildInterActionRow(
                  replies: profilePostModel.replies,
                  reposts: profilePostModel.retweets,
                  likes: profilePostModel.likes,
                  activities: profilePostModel.activityNumber,
                  repostedByMe: true,
                  likedByMe: true,
                  savedByMe: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

Widget buildPhotoSection(List<dynamic> photos) {
  if (photos.isEmpty) return const SizedBox.shrink();

  if (photos.length == 1) {
    return Image.network(photos[0], fit: BoxFit.cover);
  }

  if (photos.length == 2) {
    return Row(
      children: [
        Expanded(child: Image.network(photos[0], fit: BoxFit.cover)),
        Expanded(child: Image.network(photos[1], fit: BoxFit.cover)),
      ],
    );
  } else if (photos.length == 3) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(child: Image.network(photos[0], fit: BoxFit.cover)),
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

Widget buildInterActionRow({
  required int replies,
  required int reposts,
  required int activities,
  required int likes,
  required bool repostedByMe,
  required bool likedByMe,
  required bool savedByMe,
}) {
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
              if (replies > 0)
                Text(
                  Shared.formatCount(replies),
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
                  repostedByMe ? Color(0XFF00B87B) : Colors.grey,
                  BlendMode.srcIn,
                ),
              ),
              if (reposts > 0)
                Text(
                  Shared.formatCount(reposts),
                  style: TextStyle(
                    color: repostedByMe ? Color(0XFF00B87B) : Colors.grey,
                    fontSize: 15,
                  ),
                ),
            ],
          ),
        ),
        GestureDetector(
          onTap: () {
            //   TODO: do like action
          },
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SvgPicture.asset(
                likedByMe
                    ? "assets/svg/like_filled.svg"
                    : "assets/svg/like.svg",
                width: 20,
                height: 20,
                colorFilter: ColorFilter.mode(
                  likedByMe ? Color(0XFFF6187E) : Colors.grey,
                  BlendMode.srcIn,
                ),
              ),
              if (likes > 0)
                Text(
                  Shared.formatCount(likes),
                  style: TextStyle(
                    color: likedByMe ? Color(0XFFF6187E) : Colors.grey,
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
              if (activities > 0)
                Text(
                  Shared.formatCount(activities),
                  style: TextStyle(color: Colors.grey, fontSize: 15),
                ),
            ],
          ),
        ),
        Row(
          children: [
            GestureDetector(
              onTap: () {
                //   TODO: do save action
              },
              child: SvgPicture.asset(
                savedByMe
                    ? "assets/svg/save_filled.svg"
                    : "assets/svg/save.svg",
                width: 20,
                height: 20,
                colorFilter: ColorFilter.mode(
                  savedByMe ? Colors.blue : Colors.grey,
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
