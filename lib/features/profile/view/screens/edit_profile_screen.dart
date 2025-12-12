import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lite_x/features/media/upload_media.dart';
import 'package:lite_x/features/profile/models/profile_model.dart';
import 'package:lite_x/features/profile/models/shared.dart';
import 'package:lite_x/features/profile/view/widgets/edit_profile/controller/edit_profile_controller.dart';
import 'package:lite_x/features/profile/view/widgets/edit_profile/edit_profile_form.dart';
import 'package:lite_x/features/profile/view/widgets/edit_profile/edit_profile_header.dart';
import 'package:lite_x/features/profile/view_model/providers.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  EditProfileScreen({super.key, required this.profileData});
  final ProfileModel profileData;

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late ProfileModel updatedProfileData;

  bool isNameFieldEmpty = false;
  late bool isLoading;

  File? _profileImage;
  File? _bannerImage;

  bool _bannerRemoved = false;

  final controller = EditProfileController();

  // image picking

  @override
  void initState() {
    updatedProfileData = widget.profileData;
    isLoading = false;
    super.initState();
  }

  void changeProfileImage(File profileImage) {
    setState(() {
      _profileImage = profileImage;
      _bannerRemoved = true;
    });
  }

  void _removeBannerImage() {
    setState(() {
      _bannerImage = null;
      _bannerRemoved = true;
    });
  }

  void changeBannerImage(File bannerImage) {
    setState(() {
      _bannerImage = bannerImage;
      _bannerRemoved = false;
    });
  }

  void checkNameField(bool isNameFieldEmpty) {
    this.isNameFieldEmpty = isNameFieldEmpty;
    setState(() {});
  }

  void _save() async {
    setState(() {
      isLoading = true;
    });
    if (mounted) {
      bool imageUpdated = false;
      if (_profileImage != null) {
        final ids = await upload_media([_profileImage!]);
        final updatePhoto = ref.watch(updateProfilePhotoProvider);
        final res = await updatePhoto(widget.profileData.id, ids[0]);
        res.fold(
          (l) {
            if (mounted)
              showSmallPopUpMessage(
                context: context,
                message: l.message,
                borderColor: Colors.red,
                icon: Icon(Icons.error),
              );
          },
          (r) {
            imageUpdated = true;
          },
        );
      }

      if (_bannerImage != null) {
        final ids = await upload_media([_bannerImage!]);
        final updateBanner = ref.watch(
          updateProfileBannerProvider,
        ); // exception
        final res = await updateBanner(widget.profileData.id, ids[0]);
        res.fold(
          (l) {
            if (mounted)
              showSmallPopUpMessage(
                context: context,
                message: l.message,
                borderColor: Colors.red,
                icon: Icon(Icons.error),
              );
          },
          (r) {
            imageUpdated = true;
          },
        );
      }

      if (_bannerRemoved) {
        final removeBanner = ref.watch(removeBannerProvider);
        final res = await removeBanner(widget.profileData.id);
        res.fold(
          (l) {
            if (mounted)
              showSmallPopUpMessage(
                context: context,
                message: l.message,
                borderColor: Colors.red,
                icon: Icon(Icons.error),
              );
          },
          (r) {
            imageUpdated = true;
          },
        );
      }

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
        if (!mounted) return;
        final editProfile = ref.read(editProfileProvider);
        final res = await editProfile(updatedProfileData);
        if (!mounted) return;
        res.fold(
          (fail) {
            if (mounted && context.canPop())
              context.pop(EditProfileStatus.failedToChange);
            return;
          },
          (success) {
            if (mounted && context.canPop())
              context.pop(EditProfileStatus.changedSuccessfully);
            return;
          },
        );
      } else {
        if (mounted && context.canPop())
          context.pop(
            imageUpdated
                ? EditProfileStatus.changedSuccessfully
                : EditProfileStatus.unChanged,
          );
        return;
      }
    }
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverAppBar(
                title: Text("Edit profile", style: TextStyle(fontSize: 18)),
                leading: BackButton(
                  onPressed: () {
                    if (GoRouter.of(context).canPop()) {
                      GoRouter.of(context).pop();
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
                deleteBannerImage: _removeBannerImage,
                changeProfileImage: changeProfileImage,
                bannerRemoved: _bannerRemoved,
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
          if (isLoading)
            Stack(
              children: [
                Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Container(
                        color: Colors.black.withValues(alpha: 0.5),
                        child: SizedBox(),
                        width: double.infinity,
                      ),
                    ),
                  ],
                ),
                _buildLoadingDialog("Update Profile..."),
              ],
            ),
        ],
      ),
    );
  }
}

Widget _buildLoadingDialog(String text) {
  return Dialog(
    backgroundColor: const Color.fromARGB(255, 45, 45, 46),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    semanticsRole: SemanticsRole.loadingSpinner,
    child: Padding(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: Colors.white),
          SizedBox(width: 16),
          Text(
            text,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ],
      ),
    ),
  );
}
