import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import 'package:lite_x/core/providers/current_user_provider.dart';
import 'package:lite_x/core/routes/Route_Constants.dart';
import 'package:lite_x/core/theme/palette.dart';
import 'package:lite_x/features/auth/view_model/auth_state.dart';
import 'package:lite_x/features/auth/view_model/auth_view_model.dart';

class UsernameSettings extends ConsumerStatefulWidget {
  const UsernameSettings({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _UsernameSettingsState();
}

class _UsernameSettingsState extends ConsumerState<UsernameSettings> {
  late String currentUserName;
  final TextEditingController _usernameController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    currentUserName = ref.read(currentUserProvider)!.username;
    _usernameController.text = currentUserName;
  }

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  String? _validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return 'Username cannot be empty';
    }

    String username = value.startsWith('@') ? value.substring(1) : value;

    if (username.length < 15) {
      return 'Username must be 15 characters or less ';
    }

    final RegExp usernameRegex = RegExp(r'^[a-zA-Z0-9_]+$');
    if (!usernameRegex.hasMatch(username)) {
      return 'Username can only contain letters, numbers, and underscores';
    }

    if (username.contains(' ')) {
      return 'Username cannot contain spaces';
    }

    return null;
  }

  Future<void> _handleDone() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    String newUsername = _usernameController.text.trim();
    if (newUsername.startsWith('@')) {
      newUsername = newUsername.substring(1);
    }

    await ref
        .read(authViewModelProvider.notifier)
        .updateUsername(username: newUsername);

    final authState = ref.read(authViewModelProvider);

    setState(() {
      _isLoading = false;
    });

    if (authState.type == AuthStateType.success) {
      Fluttertoast.showToast(
        msg: authState.message ?? 'Username updated successfully',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Palette.border,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      context.pushReplacementNamed(RouteConstants.homescreen);
    } else if (authState.type == AuthStateType.error) {
      Fluttertoast.showToast(
        msg: authState.message ?? 'Failed to update username',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Palette.border,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Change username',
          style: TextStyle(
            color: Colors.white,
            fontSize: 21,
            fontWeight: FontWeight.w500,
          ),
        ),
        elevation: 0,
      ),
      body: Stack(
        children: [
          Divider(
            thickness: 0.2,
            color: Colors.grey[500],
            indent: 10,
            endIndent: 10,
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Current',
                    style: TextStyle(color: Palette.borderHover, fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    currentUserName,
                    style: const TextStyle(
                      color: Palette.borderHover,
                      fontSize: 16,
                    ),
                  ),
                  Divider(
                    thickness: 0.01,
                    color: Colors.grey[600],
                    indent: 10,
                    endIndent: 10,
                  ),
                  const SizedBox(height: 26),
                  const Text(
                    'New',
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                  const SizedBox(height: 1),
                  TextFormField(
                    controller: _usernameController,
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                    decoration: const InputDecoration(
                      filled: false,
                      prefixText: '@',
                      prefixStyle: TextStyle(color: Colors.white, fontSize: 16),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.blue, width: 2),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.blue, width: 2),
                      ),
                      errorBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.red, width: 2),
                      ),
                      focusedErrorBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.red, width: 2),
                      ),
                      errorStyle: TextStyle(color: Colors.red, fontSize: 12),
                    ),
                    validator: _validateUsername,
                    enabled: !_isLoading,
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 5,
            right: 10,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _handleDone,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                disabledBackgroundColor: Colors.blue.withOpacity(0.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 2,
                ),
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text(
                      'Done',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
