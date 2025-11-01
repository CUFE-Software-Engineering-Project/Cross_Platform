import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lite_x/features/profile/models/profile_model.dart';
import 'package:lite_x/features/profile/view_model/providers.dart';

class Follow_Following_Button extends ConsumerStatefulWidget {
  final ProfileModel profileData;

  Follow_Following_Button({super.key, required this.profileData});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      __Follow_Following_ButtonState();
}

class __Follow_Following_ButtonState
    extends ConsumerState<Follow_Following_Button> {
  late bool isFollowing;
  late bool isFollower;
  @override
  void initState() {
    isFollowing = widget.profileData.isFollowing;
    isFollower = widget.profileData.isFollower;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 60),
      child: OutlinedButton(
        onPressed: () {
          if (isFollowing) {
            final unfollow = ref.read(unFollowControllerProvider);
            unfollow(widget.profileData.username).then((res) {
              res.fold((l) {
                isFollowing = true;
                setState(() {});
              }, (r) {});
            });
            isFollowing = false;
          } else {
            final follow = ref.read(followControllerProvider);
            follow(widget.profileData.username).then((res) {
              res.fold((l) {
                isFollowing = false;
                setState(() {});
              }, (r) {});
            });
            isFollowing = true;
          }
          setState(() {});
        },
        style: OutlinedButton.styleFrom(
          foregroundColor: isFollowing ? Colors.black : Colors.white,
          backgroundColor: isFollowing ? Colors.black : Colors.white,
          side: BorderSide(
            color: isFollowing ? Color(0xFFADADAD) : Colors.white,
            width: 1,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 0),
        ),
        child: Text(
          isFollowing
              ? "Following"
              : isFollower
              ? "Follow Back"
              : "Follow",
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 16,
            color: isFollowing ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }
}
