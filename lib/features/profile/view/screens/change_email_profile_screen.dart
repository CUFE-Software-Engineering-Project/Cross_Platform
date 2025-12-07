import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:lite_x/features/profile/models/profile_model.dart';
import 'package:lite_x/features/profile/view_model/providers.dart';

class ChangeEmailProfileScreen extends ConsumerStatefulWidget {
  final ProfileModel profileData;

  ChangeEmailProfileScreen({Key? key, required this.profileData})
    : super(key: key);

  @override
  ConsumerState<ChangeEmailProfileScreen> createState() =>
      _ChangeEmailScreenProfileState();
}

class _ChangeEmailScreenProfileState
    extends ConsumerState<ChangeEmailProfileScreen> {
  final TextEditingController _emailController = TextEditingController();
  bool _enableForm = true;
  bool isLoading = false;
  final FocusNode _emailFocusNode = FocusNode();
  String? _emailError = null;
  bool _allowDiscoverability = false;
  bool _isNextButtonEnabled = false;

  @override
  void initState() {
    super.initState();
    // _emailController.addListener(_validateEmail);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _emailFocusNode.dispose();
    super.dispose();
  }

  void _onEmailChanged(String value) {
    setState(() {
      _isNextButtonEnabled =
          value.trim().isNotEmpty &&
          value.trim() != widget.profileData.email &&
          _isValidEmail(value);

      if (value.isEmpty) {
        _emailError = null;
      } else if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
        _emailError = 'Please enter a valid email address';
      } else {
        _emailError = null;
      }

      if (value.trim() == widget.profileData.email)
        _emailError = "the new email is the same with the old email";
    });
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  // void _validateEmail() {
  //   setState(() {

  //     print(_emailError);
  //   });
  // }

  void _handleNext() async {
    final newEmail = _emailController.text.trim();
    setState(() {
      isLoading = true;
      _enableForm = false;
    });
    if (newEmail.isEmpty) {
      return;
    }

    if (!_isValidEmail(newEmail)) {
      _showSnackBar('Please enter a valid email address');
      return;
    }

    if (newEmail == widget.profileData.email) {
      _showSnackBar('New email must be different from current email');
      return;
    }

    final changeEmail = ref.read(changeEmailProfileProvider);
    final res = await changeEmail(newEmail);
    res.fold(
      (l) {
        _emailError = l.message;
      },
      (r) async {
        // TODO:go to verify email

        context.push(
          "/verifyChangeEmailProfileScreen",
          extra: [widget.profileData, newEmail],
        );
      },
    );
    setState(() {
      isLoading = false;
      _enableForm = true;
    });
  }

  void _handleCancel() {
    if (context.canPop()) Navigator.pop(context);
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: _handleCancel,
        ),
        title: SvgPicture.asset(
          "assets/svg/xlogo.svg",
          width: 40,
          height: 40,
          colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Change email',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 15),
                  RichText(
                    text: TextSpan(
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 15,
                        height: 1.5,
                      ),
                      children: [
                        const TextSpan(text: 'Your current email is '),
                        TextSpan(text: widget.profileData.email),
                        const TextSpan(
                          text:
                              '. What would you like to update it to? Your email is not displayed in your public profile on X.',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  RichText(
                    text: TextSpan(
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 15,
                        height: 1.5,
                      ),
                      children: [
                        const TextSpan(
                          text:
                              'If you change your email address, any existing Google SSO connections will be removed. Review Connected accounts ',
                        ),
                        WidgetSpan(
                          child: GestureDetector(
                            onTap: () {
                              // Handle navigation to connected accounts
                              _showSnackBar('Navigate to Connected accounts');
                            },
                            child: const Text(
                              'here',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 15,
                                decoration: TextDecoration.none,
                              ),
                            ),
                          ),
                        ),
                        const TextSpan(text: '.'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  TextFormField(
                    controller: _emailController,
                    onChanged: (value) {
                      _onEmailChanged(value);
                    },
                    enabled: _enableForm,
                    keyboardType: TextInputType.emailAddress,
                    focusNode: _emailFocusNode,
                    decoration: InputDecoration(
                      fillColor: Colors.black,
                      hintText: "Email address",
                      hintStyle: TextStyle(color: Colors.grey),
                      labelText: "Email address",
                      labelStyle: TextStyle(
                        color: _emailError == null
                            ? _emailFocusNode.hasFocus
                                  ? Colors.blue
                                  : Colors.grey
                            : Colors.red,
                      ),
                      errorText: _emailError,
                      errorStyle: TextStyle(color: Colors.red),
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(4),
                        borderSide: BorderSide(width: 2, color: Colors.grey),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(4),
                        borderSide: BorderSide(width: 2, color: Colors.blue),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(4),
                        borderSide: BorderSide(width: 2, color: Colors.red),
                      ),
                      disabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(4),
                        borderSide: BorderSide(width: 2, color: Colors.grey),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _allowDiscoverability = !_allowDiscoverability;
                      });
                    },
                    child: Row(
                      children: [
                        Expanded(
                          child: RichText(
                            text: TextSpan(
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                height: 1.5,
                              ),
                              children: [
                                const TextSpan(
                                  text:
                                      'Let people who have your email address find and connect with you on X. ',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                WidgetSpan(
                                  child: GestureDetector(
                                    onTap: () {},
                                    child: const Text(
                                      'Learn more',
                                      style: TextStyle(
                                        color: Color(0xFF1D9BF0),
                                        fontSize: 15,
                                        decoration: TextDecoration.none,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: _allowDiscoverability
                                  ? const Color(0xFF1D9BF0)
                                  : Colors.grey[700]!,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(4),
                            color: _allowDiscoverability
                                ? const Color(0xFF1D9BF0)
                                : Colors.transparent,
                          ),
                          child: _allowDiscoverability
                              ? const Icon(
                                  Icons.check,
                                  size: 18,
                                  color: Colors.white,
                                )
                              : null,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.black,
              border: Border(top: BorderSide(color: Colors.grey[900]!)),
            ),
            child: SafeArea(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  OutlinedButton(
                    onPressed: () {
                      _emailFocusNode.unfocus();
                      _handleCancel();
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        vertical: 5,
                        horizontal: 20,
                      ),
                      side: BorderSide(color: Colors.grey[800]!),
                      shape: StadiumBorder(),
                    ),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _isNextButtonEnabled ? _handleNext : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isNextButtonEnabled
                          ? Colors.white
                          : Colors.grey[800],
                      padding: const EdgeInsets.symmetric(
                        vertical: 5,
                        horizontal: 25,
                      ),
                      shape: StadiumBorder(),
                      elevation: 0,
                    ),
                    child: isLoading
                        ? CircularProgressIndicator(color: Colors.black)
                        : Text(
                            'Next',
                            style: TextStyle(
                              color: _isNextButtonEnabled
                                  ? Colors.black
                                  : Colors.grey[600],
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
