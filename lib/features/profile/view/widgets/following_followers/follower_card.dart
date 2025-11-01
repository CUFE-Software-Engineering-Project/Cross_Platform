import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lite_x/features/profile/models/shared.dart';
import 'package:lite_x/features/profile/models/user_model.dart';
import 'package:lite_x/features/profile/view_model/providers.dart';

class FollowerCard extends ConsumerStatefulWidget {
  final UserModel user;
  final bool isMe;

  FollowerCard({Key? key, required this.user, required this.isMe})
    : super(key: key);

  @override
  ConsumerState<FollowerCard> createState() => _FollowerCardState();
}

class _FollowerCardState extends ConsumerState<FollowerCard> {
  late bool isFollowing;
  late bool isFollower;
  @override
  void initState() {
    isFollower = widget.user.isFollower;
    isFollowing = widget.user.isFollowing;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.push("/profilescreen/${widget.user.userName}");
      },
      child: Column(
        children: [
          SizedBox(height: 10),
          if (widget.user.isFollower)
            Row(
              children: [
                SizedBox(width: 40),
                Icon(Icons.person, color: Colors.grey),
                SizedBox(width: 5),
                Text("Follows you", style: TextStyle(color: Colors.grey)),
              ],
            ),
          SizedBox(height: 10),
          Column(
            children: [
              Container(
                padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),

                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: Colors.grey[300],
                      backgroundImage: null,
                      child: widget.user.image.isEmpty
                          ? Icon(Icons.person, size: 24, color: Colors.grey)
                          : ClipOval(
                              child: Image.network(
                                widget.user.image,
                                fit: BoxFit.cover,
                                height: 48,
                                width: 48,
                                errorBuilder: (context, error, stackTrace) {
                                  return SizedBox();
                                },
                              ),
                            ),
                    ),

                    const SizedBox(width: 12),

                    // User info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          widget.user.displayName,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        SizedBox(width: 4),
                                        if (widget.user.isVerified)
                                          Icon(
                                            Icons.verified,
                                            color: Colors.blue,
                                            size: 16,
                                          ),
                                      ],
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      "@${widget.user.userName}",
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.grey[600],
                                        textBaseline: TextBaseline.alphabetic,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(width: 8),

                              // Follow button
                              Container(
                                // width: 90,
                                height: 32,
                                child: ElevatedButton(
                                  onPressed: () async {
                                    // Handle follow/unfollow logic
                                    if (isFollowing) {
                                      final bool res = await showUnFollowDialog(
                                        context,
                                        widget.user.displayName,
                                      );
                                      if (res == true) {
                                        final unfollow = ref.read(
                                          unFollowControllerProvider,
                                        );
                                        unfollow(widget.user.userName).then((
                                          res,
                                        ) {
                                          res.fold((l) {
                                            isFollowing = true;
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  "error: can't unfollow user",
                                                ),
                                                behavior:
                                                    SnackBarBehavior.floating,
                                                duration: Duration(seconds: 2),
                                              ),
                                            );
                                            setState(() {});
                                          }, (r) {});
                                        });

                                        isFollowing = false;
                                      }
                                    } else {
                                      final follow = ref.read(
                                        followControllerProvider,
                                      );
                                      follow(widget.user.userName).then((res) {
                                        res.fold((l) {
                                          isFollowing = false;
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                "error: can't follow user",
                                              ),
                                              behavior:
                                                  SnackBarBehavior.floating,
                                              duration: Duration(seconds: 2),
                                            ),
                                          );
                                          setState(() {});
                                        }, (r) {});
                                      });

                                      isFollowing = true;
                                    }
                                    setState(() {});
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: isFollowing
                                        ? Colors.black
                                        : Colors.white,
                                    foregroundColor: isFollowing
                                        ? Colors.white
                                        : Colors.black,
                                    side: isFollowing
                                        ? BorderSide(
                                            color: Colors.grey.shade300,
                                          )
                                        : null,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    elevation: 0,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                    ),
                                  ),

                                  child: Text(
                                    isFollowing
                                        ? 'Following'
                                        : (isFollower
                                              ? 'Follow Back'
                                              : 'Follow'),
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 8),

                          // Bio
                          if (widget.user.bio.isNotEmpty)
                            Text(
                              widget.user.bio,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white,
                                // height: 1.3,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Container(height: 0.2, color: Colors.grey),
            ],
          ),
        ],
      ),
    );
  }
}
