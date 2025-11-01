import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lite_x/features/profile/models/profile_model.dart';
import 'package:lite_x/features/profile/models/shared.dart';
import 'package:lite_x/features/profile/view/widgets/edit_profile/controller/edit_profile_controller.dart';
import 'package:lite_x/features/profile/view/widgets/edit_profile/edit_profile_form.dart';
import 'package:lite_x/features/profile/view/widgets/edit_profile/edit_profile_header.dart';
import 'package:lite_x/features/profile/view_model/providers.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  EditProfileScreen({super.key, required this.profileData}) {}
  final ProfileModel profileData;

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late ProfileModel updatedProfileData;

  bool isNameFieldEmpty = false;

  File? _profileImage;
  File? _bannerImage;

  final controller = EditProfileController();

  // image picking

  @override
  void initState() {
    updatedProfileData = widget.profileData;
    super.initState();
  }

  void changeProfileImage(File profileImage) {
    setState(() {
      _profileImage = profileImage;
    });
  }

  void changeBannerImage(File bannerImage) {
    setState(() {
      _bannerImage = bannerImage;
    });
  }

  void checkNameField(bool isNameFieldEmpty) {
    this.isNameFieldEmpty = isNameFieldEmpty;
    setState(() {});
  }

  void _save() async {
    bool nameChanged =
        widget.profileData.displayName != updatedProfileData.displayName;

    bool bioChanged = widget.profileData.bio != updatedProfileData.bio;

    bool locationChanged =
        widget.profileData.location != updatedProfileData.location;
    bool websiteChanged =
        widget.profileData.website != updatedProfileData.website;

    bool birthdateChanged =
        widget.profileData.birthDate != updatedProfileData.birthDate;

    if (nameChanged ||
        bioChanged ||
        locationChanged ||
        websiteChanged ||
        birthdateChanged) {
      final editProfile = ref.read(editProfileProvider);
      final res = await editProfile(updatedProfileData);
      res.fold(
        (fail) {
          context.pop(EditProfileStatus.failedToChange);
        },
        (success) {
          context.pop(EditProfileStatus.changedSuccessfully);
        },
      );
      // context.pop(EditProfileStatus.failedToChange);
    } else {
      context.pop(EditProfileStatus.unChanged);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            title: Text("Edit profile", style: TextStyle(fontSize: 18)),
            leading: BackButton(
              onPressed: () {
                if (GoRouter.of(context).canPop()) {
                  GoRouter.of(context).pop();
                  print("can pop");
                }
              },
            ),
            actions: [
              GestureDetector(
                onTap: () {
                  //   TODO: save profile data
                  if (this.isNameFieldEmpty) {
                    //   don't do any thing
                  } else {
                    //   TODO: save profile data
                    _save();
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.only(right: 16.0),
                  child: Text(
                    "Save",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isNameFieldEmpty ? Colors.grey : Colors.white,
                    ),
                  ),
                ),
              ),
            ],
            pinned: true,
          ),

          EditProfileHeader(
            controller: controller,
            profileData: widget.profileData,
            profileImageFile: _profileImage,
            bannerImageFile: _bannerImage,
            changeBannerImage: changeBannerImage,
            changeProfileImage: changeProfileImage,
          ),

          EditProfileForm(
            formKey: _formKey,
            controller: controller,
            profileData: widget.profileData,
            checkNameField: this.checkNameField,
            onProfileChanged: (ProfileModel newModel) {
              updatedProfileData = newModel;
            },
          ),
        ],
      ),
    );
  }
}
