import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:lite_x/core/providers/current_user_provider.dart';
import 'package:lite_x/core/routes/Route_Constants.dart';
import 'package:lite_x/features/auth/view_model/auth_view_model.dart';
import 'package:lite_x/features/profile/models/profile_model.dart';
import 'package:lite_x/features/profile/models/shared.dart';
import 'package:lite_x/features/profile/view_model/providers.dart';

class VerifyChangeEmailProfileScreen extends ConsumerStatefulWidget {
  late final ProfileModel profileData;
  late final String newEmail;

  VerifyChangeEmailProfileScreen({Key? key, required List<dynamic> extra})
    : super(key: key) {
    profileData = extra[0];
    newEmail = extra[1];
  }

  @override
  ConsumerState<VerifyChangeEmailProfileScreen> createState() =>
      _VerifyChangeEmailScreenProfileState();
}

class _VerifyChangeEmailScreenProfileState
    extends ConsumerState<VerifyChangeEmailProfileScreen> {
  final TextEditingController _codeController = TextEditingController();
  bool _enableForm = true;
  bool isLoading = false;
  final FocusNode _codeFocusNode = FocusNode();
  String? _codeError;
  bool _isNextButtonEnabled = false;

  @override
  void initState() {
    super.initState();
    _codeError = null;
    // _emailController.addListener(_validateEmail);
  }

  @override
  void dispose() {
    _codeController.dispose();
    _codeFocusNode.dispose();
    super.dispose();
  }

  void _onCodeChanged(String value) {
    setState(() {
      _isNextButtonEnabled = value.trim().isNotEmpty && _isValidCode(value);

      if (value.isEmpty) {
        _codeError = null;
      } else if (!_isValidCode(value)) {
        _codeError = 'Please enter a valid code';
      } else {
        _codeError = null;
      }
    });
  }

  bool _isValidCode(String code) {
    return _containsOnlyDigits(code);
  }

  bool _containsOnlyDigits(String str) {
    final RegExp digitRegExp = RegExp(r'^[0-9]+$');
    return digitRegExp.hasMatch(str);
  }

  void _handleNext() async {
    final code = _codeController.text.trim();
    setState(() {
      isLoading = true;
      _enableForm = false;
    });
    if (code.isEmpty) {
      return;
    }

    if (!_isValidCode(code)) {
      _showSnackBar('Please enter a valid code');
      return;
    }

    final verifyChangeEmail = ref.read(verifyChangeEmailProfileProvider);
    final res = await verifyChangeEmail(widget.newEmail, code);
    res.fold(
      (l) {
        _codeError = l.message;
      },
      (r) async {
        showSmallPopUpMessage(
          context: context,
          message: "Email Changed Successfully",
          borderColor: Colors.blue,
          icon: Icon(Icons.mark_email_read_rounded, color: Colors.blue),
        );
        final authViewModel = ref.read(authViewModelProvider.notifier);
        await authViewModel.logout();
        context.goNamed(RouteConstants.introscreen);
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
              padding: const EdgeInsets.only(
                left: 24.0,
                right: 24,
                bottom: 24,
                top: 15,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'We sent you a code',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "Enter it below to verify your email.",
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                  const SizedBox(height: 30),
                  TextFormField(
                    controller: _codeController,
                    onChanged: (value) {
                      _onCodeChanged(value);
                    },
                    keyboardType: TextInputType.number,
                    enabled: _enableForm,
                    focusNode: _codeFocusNode,
                    decoration: InputDecoration(
                      fillColor: Colors.black,
                      hintText: "Email address",
                      hintStyle: TextStyle(color: Colors.grey),
                      labelText: "Verification code",
                      labelStyle: TextStyle(
                        color: _codeError == null
                            ? _codeFocusNode.hasFocus
                                  ? Colors.blue
                                  : Colors.grey
                            : Colors.red,
                      ),
                      errorText: _codeError,
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
                  SizedBox(height: 5),
                  GestureDetector(
                    onTap: () {
                      // TODO: handle didn't recieve code
                    },
                    child: Text(
                      "Didn't recieve code?",
                      style: TextStyle(color: Colors.blue, fontSize: 12),
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
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
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
                            'Verify',
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
