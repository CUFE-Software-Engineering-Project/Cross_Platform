import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:lite_x/features/profile/models/profile_model.dart';

class EditProfileScreen extends StatefulWidget {
  EditProfileScreen({super.key, required this.profileData}) {}
  final ProfileModel profileData;

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _bioCtrl;
  late final TextEditingController _locationCtrl;
  late final TextEditingController _websiteCtrl;
  late final TextEditingController _birthDateCtrl;
  late final FocusNode _locationFocusNode;
  bool isNameFieldEmpty = false;

  static const double _fontSize = 16;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _nameCtrl = TextEditingController(text: widget.profileData.displayName);
    _bioCtrl = TextEditingController(text: widget.profileData.bio);
    _locationCtrl = TextEditingController(text: widget.profileData.location);
    _websiteCtrl = TextEditingController(text: widget.profileData.website);
    _birthDateCtrl = TextEditingController(text: widget.profileData.birthDate);
    _locationFocusNode = FocusNode();
  }

  @override
  void dispose() {
    // TODO: implement dispose
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
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            title: Text("Edit profile", style: TextStyle(fontSize: 18)),
            leading: IconButton(
              onPressed: () {
                //   TODO: return to profile screen
                context.go('/profilescreen');
              },
              icon: Icon(Icons.arrow_back_sharp, size: 22),
            ),
            actions: [
              GestureDetector(
                onTap: () {
                  //   TODO: save profile data
                  if (_nameCtrl.text.isEmpty) {
                    //   don't do any thing
                  } else {
                    //   TODO: save profile data
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.only(right: 16.0),
                  child: Text(
                    "Save",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: _nameCtrl.text.isEmpty
                          ? Colors.grey
                          : Colors.white,
                    ),
                  ),
                ),
              ),
            ],
            pinned: true,
          ),
          SliverToBoxAdapter(
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  height: 1,
                  color: Colors.grey,
                ),
                Stack(
                  children: [
                    Column(
                      children: [
                        GestureDetector(
                          onTap: () {
                            //   TODO: edit profile banner
                          },
                          child: Container(
                            height: 120,
                            decoration: BoxDecoration(
                              color: Colors.blue,
                              image: widget.profileData.bannerUrl.isEmpty
                                  ? null
                                  : DecorationImage(
                                      image: NetworkImage(
                                        widget.profileData.bannerUrl,
                                      ),
                                      fit: BoxFit.cover,
                                    ),
                            ),
                            child: Stack(
                              children: [
                                Container(
                                  color: Colors.black.withValues(alpha: 0.4),
                                ),
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
                          //   TODO: change profile photo
                        },
                        child: Stack(
                          children: [
                            CircleAvatar(
                              radius: 45,
                              backgroundColor: Colors.black,
                              child: CircleAvatar(
                                radius: 40,
                                backgroundColor: Colors.black,
                                backgroundImage: NetworkImage(
                                  widget.profileData.avatarUrl,
                                ),
                              ),
                            ),
                            CircleAvatar(
                              radius: 45,
                              backgroundColor: Colors.black.withValues(
                                alpha: 0.4,
                              ),
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
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(8.0).copyWith(top: 0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildProfileInputField(
                      label: "Name",
                      controller: _nameCtrl,
                      hintText: "Name cannot be blank",
                      keyboardType: TextInputType.twitter,
                      onTap: () {},
                      onChange: () {
                        if (isNameFieldEmpty != _nameCtrl.text.isEmpty) {
                          setState(() {
                            isNameFieldEmpty = _nameCtrl.text.isEmpty;
                          });
                        }
                      },
                    ),
                    _buildProfileInputField(
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
                    _buildLocationAutocomplete(
                      controller: _locationCtrl,
                      label: "Location",
                      focusNode: _locationFocusNode,
                      onLocationSelected: (String loc) {
                        _locationCtrl.text = loc;
                        _locationFocusNode.unfocus();
                      },
                    ),
                    _buildProfileInputField(
                      label: "Website",
                      controller: _websiteCtrl,
                      hintText: "",
                      keyboardType: TextInputType.twitter,
                      onTap: () {},
                    ),
                    _buildProfileInputField(
                      label: "Birth date",
                      controller: _birthDateCtrl,
                      hintText: "Add your birth date",
                      keyboardType: TextInputType.twitter,
                      onTap: () {
                        //   TODO: open birth date page
                      },
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
                          padding: EdgeInsets.symmetric(vertical: 10,horizontal: 10),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                              side: const BorderSide(
                                color: Colors.white,
                                width: 1,
                              )
                          ),
                        )
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(8, 30, 0, 30),
                      child: Column(
                        children: [
                          Text("Tips", style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),),
                          Text("Off",style: TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),)
                        ]
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Widget _buildProfileInputField({
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
  Widget? trailingWidget, // For things like birth date selection
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

Widget _buildLocationAutocomplete({
  required TextEditingController controller,
  required String label,
  required FocusNode focusNode,
  required Function(String) onLocationSelected,
}) {
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
  ];
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
              controller.text = textEditingController.text;

              return TextFormField(
                controller: textEditingController,
                focusNode: fieldFocusNode,
                onFieldSubmitted: (value) => onFieldSubmitted(),
                maxLines: 1,
                maxLength: 50,
                style: const TextStyle(color: Colors.white, fontSize: 18),
                decoration: const InputDecoration(
                  hintText: '',
                  hintStyle: TextStyle(color: Colors.grey),
                  border: InputBorder.none,
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0XFF1D99ED), width: 2),
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
