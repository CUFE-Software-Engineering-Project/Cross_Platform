import 'dart:io';
import 'package:go_router/go_router.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lite_x/core/classes/PickedImage.dart';
import 'package:lite_x/core/routes/Route_Constants.dart';
import 'package:lite_x/core/theme/palette.dart';
import 'package:lite_x/core/view/widgets/Loader.dart';
import 'package:lite_x/features/auth/view/widgets/buildXLogo.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:lite_x/features/auth/view_model/auth_state.dart';
import 'package:lite_x/features/auth/view_model/auth_view_model.dart';

class UploadProfilePhotoScreen extends ConsumerStatefulWidget {
  const UploadProfilePhotoScreen({super.key});

  @override
  ConsumerState<UploadProfilePhotoScreen> createState() =>
      _UploadProfilePhotoScreenState();
}

class _UploadProfilePhotoScreenState
    extends ConsumerState<UploadProfilePhotoScreen> {
  PickedImage? selectedImage;
  final _isFormValid = ValueNotifier<bool>(false);

  @override
  void dispose() {
    _isFormValid.dispose();
    super.dispose();
  }

  Future<void> selectImage() async {
    final picked = await pickImage();
    if (picked == null) return;

    CroppedFile? croppedFile;

    try {
      if (picked.file != null) {
        croppedFile = await ImageCropper().cropImage(
          sourcePath: picked.file!.path,
          aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
          uiSettings: [
            AndroidUiSettings(
              toolbarTitle: 'Move and Scale',
              toolbarColor: Palette.background,
              toolbarWidgetColor: Colors.white,
              lockAspectRatio: true,
              cropStyle: CropStyle.circle,
              cropFrameColor: Colors.transparent,
              cropGridColor: Colors.transparent,
            ),
          ],
        );

        if (croppedFile != null && mounted) {
          setState(() {
            selectedImage = PickedImage(
              file: File(croppedFile!.path),
              bytes: null,
              name: picked.name,
              path: croppedFile.path,
            );
            _isFormValid.value = true;
          });
        }
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: const Duration(seconds: 2),
          content: Text(
            'Error cropping image: $e',
            style: TextStyle(color: Palette.background),
          ),
          backgroundColor: Palette.textWhite,
        ),
      );
    }
  }

  void _handleNext() {
    if (selectedImage != null) {
      ref
          .read(authViewModelProvider.notifier)
          .uploadProfilePhoto(selectedImage!);
    }
  }

  void _handleSkip() {
    print('Skipped profile photo upload');
    context.goNamed(RouteConstants.UserNameScreen);
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(authViewModelProvider, (previous, next) {
      if (next.type == AuthStateType.success) {
        context.goNamed(RouteConstants.UserNameScreen);
        ref.read(authViewModelProvider.notifier).setAuthenticated();
      } else if (next.type == AuthStateType.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.message ?? 'An error occurred'),
            backgroundColor: Palette.error,
          ),
        );
      }
    });

    final authState = ref.watch(authViewModelProvider);
    final isLoading = authState.isLoading;
    return Scaffold(
      backgroundColor: Palette.background,
      appBar: AppBar(
        title: buildXLogo(size: 36),
        centerTitle: true,
        backgroundColor: Palette.background,
        elevation: 0,
      ),
      body: AbsorbPointer(
        absorbing: isLoading,
        child: Stack(
          children: [
            Center(
              child: Container(
                width: double.infinity,
                height: double.infinity,
                decoration: BoxDecoration(color: Palette.background),
                child: Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Pick a profile picture',
                              style: TextStyle(
                                fontSize: 31,
                                fontWeight: FontWeight.w800,
                                color: Palette.textWhite,
                              ),
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'Have a favourite selfie? Upload it now.',
                              style: TextStyle(
                                fontSize: 15,
                                color: Palette.greycolor,
                              ),
                            ),
                            const SizedBox(height: 48),
                            Center(child: _buildUploadArea()),
                          ],
                        ),
                      ),
                    ),
                    _buildBottomButtons(),
                  ],
                ),
              ),
            ),
            if (isLoading)
              Container(
                color: Colors.black,
                child: const Center(child: Loader()),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildUploadArea() {
    if (selectedImage != null) {
      return Column(
        children: [
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Palette.primary, width: 3),
              image: DecorationImage(
                image: _getImageProvider(),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 24),
          TextButton(
            onPressed: selectImage,
            child: const Text(
              'Change photo',
              style: TextStyle(
                color: Palette.primary,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      );
    }

    return GestureDetector(
      onTap: selectImage,
      child: DottedBorder(
        options: RoundedRectDottedBorderOptions(
          radius: const Radius.circular(12),
          color: Palette.primary,
          strokeWidth: 2,
          dashPattern: const [10, 8],
        ),
        child: Container(
          width: 185,
          height: 185,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(13)),
          child: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.photo_camera, size: 80, color: Palette.primary),
                SizedBox(height: 16),
                Text(
                  'Upload',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Palette.primary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  ImageProvider _getImageProvider() {
    if (selectedImage!.file != null) {
      return FileImage(selectedImage!.file!);
    }
    throw Exception('No image available');
  }

  Widget _buildBottomButtons() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          OutlinedButton(
            onPressed: _handleSkip,
            style: OutlinedButton.styleFrom(
              foregroundColor: Palette.textWhite,
              side: const BorderSide(color: Palette.textWhite, width: 1),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
            child: const Text(
              'Skip for now',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
          ValueListenableBuilder<bool>(
            valueListenable: _isFormValid,
            builder: (context, isValid, child) {
              return SizedBox(
                width: 90,
                child: ElevatedButton(
                  onPressed: isValid ? _handleNext : null,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    backgroundColor: Palette.textWhite,
                    disabledBackgroundColor: Palette.textWhite.withOpacity(0.6),
                    foregroundColor: Palette.background,
                    disabledForegroundColor: Palette.border,
                    minimumSize: const Size(0, 38),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: const Text(
                    'Next',
                    style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
