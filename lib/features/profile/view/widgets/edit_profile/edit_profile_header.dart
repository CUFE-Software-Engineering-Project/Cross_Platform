import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lite_x/features/media/download_media.dart';
import 'package:lite_x/features/media/upload_media.dart';
import 'package:lite_x/features/profile/models/profile_model.dart';
import 'package:lite_x/features/profile/view/widgets/edit_profile/controller/edit_profile_controller.dart';

class EditProfileHeader extends StatelessWidget {
  final EditProfileController controller;
  final ProfileModel profileData;
  final File? profileImageFile;
  final File? bannerImageFile;
  final Function changeProfileImage;
  final Function changeBannerImage;
  const EditProfileHeader({
    super.key,
    required this.controller,
    required this.profileData,
    required this.profileImageFile,
    required this.bannerImageFile,
    required this.changeBannerImage,
    required this.changeProfileImage,
  });

  void pickProfileImage(BuildContext context) async {
    ImageSource source = ImageSource.camera;
    int? x = await controller.showImageSourceDialog(context, 2);
    if (x == null) return;
    if (x == 1) source = ImageSource.gallery;
    final imageFile = await controller.pickImage(source);
    if (imageFile != null) {
      final croppedImage = await controller.cropImageCircle(
        File(imageFile.path),
      );
      if (croppedImage != null) {
        changeProfileImage(File(croppedImage.path));
      }
    }
  }

  void pickBannerImage(BuildContext context) async {
    ImageSource source = ImageSource.camera;
    int? x = await controller.showImageSourceDialog(context, 3);
    if (x == null) return;
    if (x == 2) {
      // TODO: remove banner photo
      return;
    }
    if (x == 1) source = ImageSource.gallery;
    final imageFile = await controller.pickImage(source);
    if (imageFile != null) {
      final croppedImage = await controller.cropImageRect(File(imageFile.path));
      if (croppedImage != null) {
        changeBannerImage(File(croppedImage.path));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    DecorationImage? bannerImg = bannerImageFile != null
        ? DecorationImage(image: FileImage(bannerImageFile!))
        : profileData.bannerUrl.isNotEmpty
        ? DecorationImage(image: NetworkImage(profileData.bannerUrl))
        : null;

    ImageProvider? profileImg = profileImageFile != null
        ? FileImage(profileImageFile!)
        : profileData.avatarUrl.isNotEmpty
        ? NetworkImage(profileData.avatarUrl)
        : null;

    return SliverToBoxAdapter(
      child: Column(
        children: [
          Container(width: double.infinity, height: 1, color: Colors.grey),
          Stack(
            children: [
              Column(
                children: [
                  GestureDetector(
                    onTap: () {
                      //   TODO: edit profile banner
                      pickBannerImage(context);
                    },
                    child: Container(
                      height: 120,
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        image: bannerImg,
                      ),
                      child: Stack(
                        children: [
                          Container(color: Colors.black.withOpacity(0.4)),
                          Center(
                            child: SvgPicture.asset(
                              "assets/svg/camera.svg",
                              width: 40,
                              height: 40,
                              colorFilter: const ColorFilter.mode(
                                Colors.white,
                                BlendMode.srcIn,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    color: Colors.black,
                    width: double.infinity,
                    height: 55,
                  ),
                ],
              ),
              Positioned(
                left: 8,
                bottom: 10,
                child: GestureDetector(
                  onTap: () {
                    //   TODO: change profile photo
                    pickProfileImage(context);
                  },
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 45,
                        backgroundColor: Colors.black,
                        child: CircleAvatar(
                          radius: 40,
                          backgroundColor: Colors.black,
                          backgroundImage: profileImg,
                        ),
                      ),
                      CircleAvatar(
                        radius: 45,
                        backgroundColor: Colors.black.withOpacity(0.4),
                        child: Center(
                          child: SvgPicture.asset(
                            "assets/svg/camera.svg",
                            width: 40,
                            height: 40,
                            colorFilter: const ColorFilter.mode(
                              Colors.white,
                              BlendMode.srcIn,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
