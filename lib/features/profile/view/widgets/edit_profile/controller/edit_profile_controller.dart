import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

class EditProfileController {
  final ImagePicker _picker = ImagePicker();

  Future<XFile?> pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 100,
      );

      return pickedFile;
    } catch (e) {
      return null;
    }
  }

  Future<CroppedFile?> cropImageCircle(File imageFile) async {
    try {
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: imageFile.path,

        compressQuality: 100,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Move and scale',
            cropStyle: CropStyle.circle,
            backgroundColor: Colors.black,
            cropFrameColor: Colors.black,

            lockAspectRatio: false,
            aspectRatioPresets: [CropAspectRatioPreset.square],
            hideBottomControls: true,
            cropFrameStrokeWidth: 0,
            showCropGrid: false,
            initAspectRatio: CropAspectRatioPreset.ratio3x2,
          ),
          IOSUiSettings(
            title: "Move and scale",
            cropStyle: CropStyle.circle,
            aspectRatioLockEnabled: false,
            cancelButtonTitle: "Cancel",
            doneButtonTitle: "Apply",
          ),
        ],
      );

      return croppedFile;
    } catch (e) {
      return null;
    }
  }

  Future<CroppedFile?> cropImageRect(File imageFile) async {
    try {
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: imageFile.path,
        aspectRatio: CropAspectRatio(ratioX: 16, ratioY: 5),
        compressQuality: 100,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Move and scale',
            backgroundColor: Colors.black,
            cropFrameColor: Colors.black,
            lockAspectRatio: false,
            hideBottomControls: true,
            cropFrameStrokeWidth: 0,
            showCropGrid: false,
          ),
          IOSUiSettings(
            title: "",
            cropStyle: CropStyle.circle,
            aspectRatioLockEnabled: false,
            cancelButtonTitle: "Cancel",
            doneButtonTitle: "Apply",
          ),
        ],
      );

      return croppedFile;
    } catch (e) {
      return null;
    }
  }

  // void _showErrorSnackBar(String message) {
  //   ScaffoldMessenger.of(
  //     context,
  //   ).showSnackBar(SnackBar(content: Text(message)));
  // }

  // void _showImageSourceDialog() {
  //   showModalBottomSheet(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return SafeArea(
  //         child: Wrap(
  //           children: [
  //             ListTile(
  //               leading: const Icon(Icons.photo_camera),
  //               title: const Text('Camera'),
  //               onTap: () {
  //                 Navigator.pop(context);
  //                 _pickImage(ImageSource.camera);
  //               },
  //             ),
  //             ListTile(
  //               leading: const Icon(Icons.photo_library),
  //               title: const Text('Gallery'),
  //               onTap: () {
  //                 Navigator.pop(context);
  //                 _pickImage(ImageSource.gallery);
  //               },
  //             ),
  //           ],
  //         ),
  //       );
  //     },
  //   );
  // }

  Future<int?> showImageSourceDialog(
    BuildContext context,
    int num_of_choices,
  ) async {
    // This dialog provides 3 choices and returns an integer value for each.
    return showDialog<int>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          actionsPadding: EdgeInsets.all(0),
          contentPadding: EdgeInsets.all(0),

          content: Container(
            color: Color(0XFF212121),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  title: Text("Take photo"),
                  onTap: () {
                    Navigator.of(context).pop(0);
                  },
                ),
                ListTile(
                  title: Text("choose existing photo"),
                  onTap: () {
                    Navigator.of(context).pop(1);
                  },
                ),
                if (num_of_choices == 3)
                  ListTile(
                    title: Text("Remove Header"),
                    onTap: () {
                      Navigator.of(context).pop(2);
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget buildProfileInputField({
    required String label,
    required TextEditingController controller,
    String? hintText,
    String? Function(String?)? validator,
    Function()? onChange,
    TextInputType keyboardType = TextInputType.text,
    bool readOnly = false,
    VoidCallback? onTap,
    double bottomPadding = 0,
    double topPadding = 0,
    minLines = 1,
    maxLines = null,
    int maxLength = 50,
    Widget? trailingWidget,
    bool? enabels, // For things like birth date selection
  }) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4.0, bottom: 0),
            child: Text(
              label,
              style: const TextStyle(color: Colors.grey, fontSize: 16),
            ),
          ),
          TextFormField(
            enabled: enabels,
            onChanged: (value) {
              if (onChange != null) onChange();
            },
            onTapUpOutside: (x) {
              if (onTap != null) onTap();
            },
            maxLength: maxLength,
            minLines: minLines,
            maxLines: maxLines,
            controller: controller,
            validator: validator,
            keyboardType: keyboardType,
            readOnly: readOnly,
            onTap: onTap,
            style: const TextStyle(color: Colors.white, fontSize: 18),
            decoration: InputDecoration(
              hintText: hintText,
              counterText: "",
              hintStyle: const TextStyle(color: Colors.grey),
              fillColor: Colors.black,
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Color(0XFF1D99ED), width: 2.0),
              ),

              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.grey, width: 0.5),
              ),
              errorBorder: InputBorder.none,
              disabledBorder: InputBorder.none,
              contentPadding: EdgeInsets.only(
                bottom: bottomPadding,
                top: topPadding,
              ),
              suffixIcon: trailingWidget,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildLocationAutocomplete({
    required TextEditingController controller,
    required String label,
    required FocusNode focusNode,
    required Function(String) onLocationSelected,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 16.0, bottom: 0),
          child: Padding(
            padding: const EdgeInsets.only(left: 4.0),
            child: Text(
              label,
              style: const TextStyle(color: Colors.grey, fontSize: 16),
            ),
          ),
        ),
        Autocomplete<String>(
          optionsBuilder: (TextEditingValue textEditingValue) {
            if (textEditingValue.text == '') {
              // Return full list when user taps/has empty input
              return kAvailableLocations;
            }
            // Filter the list based on user input
            return kAvailableLocations.where((String option) {
              return option.toLowerCase().contains(
                textEditingValue.text.toLowerCase(),
              );
            });
          },
          onSelected: (String selection) {
            onLocationSelected(selection);
          },
          fieldViewBuilder:
              (
                BuildContext context,
                TextEditingController textEditingController,
                FocusNode fieldFocusNode,
                VoidCallback onFieldSubmitted,
              ) {
                textEditingController.text = controller.text;

                return TextFormField(
                  controller: textEditingController,

                  focusNode: fieldFocusNode,
                  onFieldSubmitted: (value) => onFieldSubmitted(),
                  maxLines: 1,
                  maxLength: 50,
                  onChanged: (value) {
                    controller.text = value;
                  },
                  style: const TextStyle(color: Colors.white, fontSize: 18),
                  decoration: const InputDecoration(
                    hintText: '',
                    hintStyle: TextStyle(color: Colors.grey),
                    border: InputBorder.none,
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: Color(0XFF1D99ED),
                        width: 2,
                      ),
                    ),
                    counterText: "",
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey, width: 0.5),
                    ),
                    fillColor: Colors.black,
                    // Use asymmetric padding to fix the divider alignment issue
                    contentPadding: EdgeInsets.fromLTRB(0, 0, 0, 0.0),
                  ),
                );
              },
          optionsViewBuilder:
              (
                BuildContext context,
                AutocompleteOnSelected<String> onSelected,
                Iterable<String> options,
              ) {
                // Define how the dropdown list looks
                return Align(
                  alignment: Alignment.topLeft,
                  child: Material(
                    color: const Color(
                      0XFF000000,
                    ), // Dark background for the dropdown
                    elevation: 4.0,
                    child: SizedBox(
                      width:
                          MediaQuery.of(context).size.width -
                          32, // Match screen width minus padding
                      child: ListView.builder(
                        padding: EdgeInsets.zero,
                        itemCount: options.length,
                        itemBuilder: (BuildContext context, int index) {
                          final String option = options.elementAt(index);
                          return ListTile(
                            title: Text(
                              option,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            onTap: () {
                              onSelected(option);
                            },
                          );
                        },
                      ),
                    ),
                  ),
                );
              },
        ),
      ],
    );
  }
}

const List<String> kAvailableLocations = <String>[
  'New York',
  'Los Angeles',
  'London',
  'Paris',
  'Tokyo',
  'Cairo',
  'Dubai',
  'Berlin',
  'Sydney',
  'Mumbai',
  'Beijing',
  'Toronto',
  'Moscow',
  'Rome',
  'Madrid',
  'Chicago',
  'Seoul',
  'Mexico City',
  'Istanbul',
  'Bangkok',
  'Singapore',
  'Hong Kong',
  'São Paulo',
  'Buenos Aires',
  'Johannesburg',
  'Nairobi',
  'Stockholm',
  'Vienna',
  'Zurich',
  'Amsterdam',
  'Prague',
  'Warsaw',
  'Budapest',
  'Lisbon',
  'Dublin',
  'Helsinki',
  'Copenhagen',
  'Oslo',
  'Brussels',
  'Athens',
  'Kuala Lumpur',
  'Manila',
  'Jakarta',
  'Lagos',
  'Casablanca',
  'Doha',
  'Riyadh',
  'Kuwait City',
  'Abu Dhabi',
  'Muscat',
  'Tehran',
  'Karachi',
  'Lahore',
  'Islamabad',
  'Bangalore',
  'Chennai',
  'Hyderabad',
  'Colombo',
  'Kathmandu',
  'Dhaka',
  'Hanoi',
  'Ho Chi Minh City',
  'Taipei',
  'Melbourne',
  'Auckland',
  'Vancouver',
  'Montreal',
  'San Francisco',
  'Seattle',
  'Boston',
  'Washington, D.C.',
  'Miami',
  'Houston',
  'Dallas',
  'Atlanta',
  'Philadelphia',
  'Detroit',
  'Phoenix',
  'Denver',
  'Cape Town',
  'Durban',
  'Addis Ababa',
  'Accra',
  'Lusaka',
  'Harare',
  'Kigali',
  'Tunis',
  'Algiers',
  'Tripoli',
  'Doha, Qatar',
  'Riyadh, Saudi Arabia',
  'Cairo, Egypt',
  'Paris, France',
  'Berlin, Germany',
  'London, UK',
  'Tokyo, Japan',
  'Sydney, Australia',
  'New York, USA',
  'Toronto, Canada',
];
