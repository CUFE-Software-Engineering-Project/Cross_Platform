import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lite_x/features/profile/models/profile_model.dart';
import 'package:lite_x/features/profile/models/shared.dart';
import 'package:lite_x/features/profile/view_model/providers.dart';

class BlockButton extends ConsumerStatefulWidget {
  final ProfileModel profileData;
  final Function showDataFunc;

  BlockButton({
    super.key,
    required this.profileData,
    required this.showDataFunc,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => __BlockedButtonState();
}

class __BlockedButtonState extends ConsumerState<BlockButton> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 60),
      child: OutlinedButton(
        onPressed: () async {
          final res = await showPopupMessage(
            context: context,
            title: Text(
              "Unblock @${widget.profileData.username}?",
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
          final blockRes = await unblock(widget.profileData.username);
          blockRes.fold(
            (fail) {
              showSmallPopUpMessage(
                context: context,
                message: fail.message,
                borderColor: Colors.red,
                icon: Icon(Icons.error, color: Colors.red),
              );
            },
            (right)async {
              // ignore: unused_result
              await ref.refresh(profileDataProvider(widget.profileData.username));
              widget.showDataFunc();
            },
          );
        },

        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.red,
          backgroundColor: Colors.transparent,
          side: BorderSide(color: Colors.red, width: 1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 0),
        ),
        child: Text(
          "Blocked",
          style: TextStyle(
            color: Colors.red,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
