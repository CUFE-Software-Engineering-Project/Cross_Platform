import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lite_x/core/providers/current_user_provider.dart';
import 'package:lite_x/core/routes/Route_Constants.dart';
import 'package:lite_x/core/theme/palette.dart';
import 'package:lite_x/features/auth/view_model/auth_view_model.dart';
import 'package:lite_x/features/profile/models/shared.dart';
import 'package:lite_x/features/profile/view_model/providers.dart';

class ChangePasswordScreen extends ConsumerStatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  ConsumerState<ChangePasswordScreen> createState() =>
      _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends ConsumerState<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _currentController = TextEditingController();
  final TextEditingController _newController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();

  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _currentController.dispose();
    _newController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _updatePassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });
    final changePassword = ref.watch(changePasswordProfileProvider);

    final res = await changePassword(
      oldPassword: _currentController.text,
      newPassword: _newController.text,
      confirmNewPassword: _confirmController.text,
    );

    res.fold(
      (l) {
        showSmallPopUpMessage(
          context: context,
          message: l.message,
          borderColor: Colors.red,
          icon: Icon(Icons.error, color: Colors.red),
        );
        setState(() {
          _isLoading = false;
        });
      },
      (r) async {
        showSmallPopUpMessage(
          context: context,
          message: "Password changed successfully",
          borderColor: Colors.blue,
          icon: Icon(Icons.check, color: Colors.blue),
        );
        final authViewModel = ref.read(authViewModelProvider.notifier);
        await authViewModel.logout();
        context.goNamed(RouteConstants.introscreen);
      },
    );
  }

  Widget _label(String text) => Padding(
    padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
    child: Text(
      text,
      style: const TextStyle(color: Palette.textSecondary, fontSize: 16),
    ),
  );

  Widget _divider() => const Divider(color: Palette.textSecondary, height: 1);

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final username = user?.username ?? 'profilename';

    return Scaffold(
      backgroundColor: Palette.background,
      appBar: AppBar(
        backgroundColor: Palette.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Palette.textWhite),
          onPressed: () => Navigator.of(context).pop(),
        ),
        centerTitle: true,
        title: Text(
          '@$username',
          style: const TextStyle(color: Palette.textSecondary, fontSize: 18),
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Current password
                _label('Current password'),
                TextFormField(
                  controller: _currentController,
                  obscureText: _obscureCurrent,
                  style: const TextStyle(
                    color: Palette.textSecondary,
                    fontSize: 18,
                  ),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureCurrent
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: Palette.textSecondary,
                      ),
                      onPressed: () =>
                          setState(() => _obscureCurrent = !_obscureCurrent),
                    ),
                  ),
                  validator: (v) => (v == null || v.isEmpty)
                      ? 'Enter current password'
                      : null,
                ),
                _divider(),

                // New password
                _label('New password'),
                TextFormField(
                  controller: _newController,
                  obscureText: _obscureNew,
                  style: const TextStyle(
                    color: Palette.textSecondary,
                    fontSize: 18,
                  ),
                  decoration: InputDecoration(
                    hintText: 'At least 8 characters',
                    hintStyle: const TextStyle(
                      color: Palette.textSecondary,
                      fontSize: 18,
                    ),
                    border: InputBorder.none,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureNew ? Icons.visibility_off : Icons.visibility,
                        color: Palette.textSecondary,
                      ),
                      onPressed: () =>
                          setState(() => _obscureNew = !_obscureNew),
                    ),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Enter new password';
                    if (v.length < 8)
                      return 'Password must be at least 8 characters';
                    return null;
                  },
                ),
                _divider(),

                // Confirm password
                _label('Confirm password'),
                TextFormField(
                  controller: _confirmController,
                  obscureText: _obscureConfirm,
                  style: const TextStyle(
                    color: Palette.textSecondary,
                    fontSize: 18,
                  ),
                  decoration: InputDecoration(
                    hintText: 'At least 8 characters',
                    hintStyle: const TextStyle(
                      color: Palette.textSecondary,
                      fontSize: 18,
                    ),
                    border: InputBorder.none,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirm
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: Palette.textSecondary,
                      ),
                      onPressed: () =>
                          setState(() => _obscureConfirm = !_obscureConfirm),
                    ),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty)
                      return 'Confirm your new password';
                    if (v.length < 8)
                      return 'Password must be at least 8 characters';
                    if (v != _newController.text)
                      return 'Passwords do not match';
                    return null;
                  },
                ),
                _divider(),

                const SizedBox(height: 28),

                // Update button
                Center(
                  child: SizedBox(
                    width: 260,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                        elevation: 0,
                      ),
                      onPressed: _updatePassword,
                      child: _isLoading
                          ? CircularProgressIndicator(color: Colors.white)
                          : Text(
                              'Update password',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),
                Center(
                  child: TextButton(
                    onPressed: () {
                      context.pushNamed(RouteConstants.ForgotpasswordScreen);
                    },
                    child: const Text(
                      'Forgot password?',
                      style: TextStyle(color: Palette.textSecondary),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
