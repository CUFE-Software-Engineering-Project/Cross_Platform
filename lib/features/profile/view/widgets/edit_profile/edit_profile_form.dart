import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:lite_x/core/theme/palette.dart';
import 'package:lite_x/features/profile/models/profile_model.dart';
import 'package:lite_x/features/profile/view/screens/birthdate_screen.dart';
import 'package:lite_x/features/profile/view/widgets/edit_profile/controller/edit_profile_controller.dart';

class EditProfileForm extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final EditProfileController controller;
  final ProfileModel profileData;
  final Function checkNameField;
  final Function(ProfileModel) onProfileChanged;
  const EditProfileForm({
    super.key,
    required this.formKey,
    required this.controller,
    required this.profileData,
    required this.checkNameField,
    required this.onProfileChanged,
  });

  @override
  State<EditProfileForm> createState() => _EditProfileFormState();
}

class _EditProfileFormState extends State<EditProfileForm> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _bioCtrl;
  late final TextEditingController _locationCtrl;
  late final TextEditingController _websiteCtrl;
  late final TextEditingController _birthDateCtrl;
  late final FocusNode _locationFocusNode;
  late ProfileModel _newProfileModel;
  bool isNameFieldEmpty = false;

  Future<void> _selectDate(BuildContext context) async {}

  void _setupListeners() {
    _nameCtrl.addListener(() {
      _newProfileModel = _newProfileModel.copyWith(displayName: _nameCtrl.text);
      widget.onProfileChanged(_newProfileModel);
    });
    _bioCtrl.addListener(() {
      _newProfileModel = _newProfileModel.copyWith(bio: _bioCtrl.text);
      widget.onProfileChanged(_newProfileModel);
    });
    _locationCtrl.addListener(() {
      _newProfileModel = _newProfileModel.copyWith(
        location: _locationCtrl.text,
      );
      widget.onProfileChanged(_newProfileModel);
    });
    _websiteCtrl.addListener(() {
      _newProfileModel = _newProfileModel.copyWith(website: _websiteCtrl.text);
      widget.onProfileChanged(_newProfileModel);
    });
    _birthDateCtrl.addListener(() {
      _newProfileModel = _newProfileModel.copyWith(
        birthDate: _birthDateCtrl.text,
      );
      widget.onProfileChanged(_newProfileModel);
    });
  }

  @override
  void initState() {
    _nameCtrl = TextEditingController(text: widget.profileData.displayName);
    _bioCtrl = TextEditingController(text: widget.profileData.bio);
    _locationCtrl = TextEditingController(text: widget.profileData.location);
    _websiteCtrl = TextEditingController(text: widget.profileData.website);
    _birthDateCtrl = TextEditingController(text: widget.profileData.birthDate);
    _locationFocusNode = FocusNode();
    _newProfileModel = widget.profileData;

    _setupListeners();

    super.initState();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _bioCtrl.dispose();
    _locationCtrl.dispose();
    _websiteCtrl.dispose();
    _birthDateCtrl.dispose();
    _locationFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(8.0).copyWith(top: 0),
        child: Form(
          key: widget.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              widget.controller.buildProfileInputField(
                label: "Name",
                controller: _nameCtrl,
                hintText: "Name cannot be blank",
                keyboardType: TextInputType.name,
                onTap: () {},
                onChange: () {
                  if (isNameFieldEmpty != _nameCtrl.text.isEmpty) {
                    setState(() {
                      isNameFieldEmpty = _nameCtrl.text.isEmpty;
                      widget.checkNameField(isNameFieldEmpty);
                    });
                  }
                },
              ),
              widget.controller.buildProfileInputField(
                label: "Bio",
                controller: _bioCtrl,
                hintText: "",
                keyboardType: TextInputType.multiline,
                minLines: 3,
                maxLines: 160,
                bottomPadding: 8,
                topPadding: 5,
                onTap: () {},
              ),
              widget.controller.buildLocationAutocomplete(
                controller: _locationCtrl,
                label: "Location",
                focusNode: _locationFocusNode,
                onLocationSelected: (String loc) {
                  _locationCtrl.text = loc;
                  _locationFocusNode.unfocus();
                },
              ),
              widget.controller.buildProfileInputField(
                label: "Website",
                controller: _websiteCtrl,
                hintText: "",
                keyboardType: TextInputType.twitter,
                onTap: () {},
              ),
              GestureDetector(
                onTap: () {
                  context
                      .push<String>("/birthDateScreen", extra: _newProfileModel)
                      .then((res) {
                        _birthDateCtrl.text = res ?? "";
                        setState(() {});
                      });
                },
                child: widget.controller.buildProfileInputField(
                  enabels: false,
                  label: "Birth date",
                  controller: _birthDateCtrl,
                  hintText: "Add your date of birth",
                  keyboardType: TextInputType.twitter,
                ),
              ),
              Container(
                width: double.infinity,
                color: Colors.grey,
                height: 0.2,
              ),

              Padding(
                padding: const EdgeInsets.fromLTRB(4, 30, 0, 0),
                child: ElevatedButton(
                  onPressed: () {
                    //   TODO: switch to professional page
                  },

                  child: Text(
                    "Switch to Professional",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                      side: const BorderSide(color: Colors.white, width: 1),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 30, 0, 30),
                child: Column(
                  children: [
                    Text(
                      "Tips",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      "Off",
                      style: TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
