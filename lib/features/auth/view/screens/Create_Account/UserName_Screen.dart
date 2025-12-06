import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lite_x/core/providers/current_user_provider.dart';
import 'package:lite_x/core/routes/Route_Constants.dart';
import 'package:lite_x/core/theme/palette.dart';
import 'package:lite_x/core/utils.dart';
import 'package:lite_x/core/view/widgets/Loader.dart';
import 'package:lite_x/features/auth/view/widgets/CustomTextField.dart';
import 'package:lite_x/features/auth/view/widgets/buildXLogo.dart';
import 'package:lite_x/features/auth/view_model/auth_state.dart';
import 'package:lite_x/features/auth/view_model/auth_view_model.dart';

class UsernameScreen extends ConsumerStatefulWidget {
  const UsernameScreen({super.key});

  @override
  ConsumerState<UsernameScreen> createState() => _UsernameScreenState();
}

class _UsernameScreenState extends ConsumerState<UsernameScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _isFormValid = ValueNotifier<bool>(false);
  List<String> suggestions = [];

  @override
  void initState() {
    super.initState();
    _usernameController.addListener(_validateForm);
    WidgetsBinding.instance.addPostFrameCallback((_) {});
  }

  void _validateForm() {
    _isFormValid.value =
        _usernameController.text.trim().isNotEmpty &&
        _usernameController.text.trim().length >= 3;
  }

  void generateSuggestions(String name) {
    final clean = name.replaceAll(" ", "").toLowerCase();
    setState(() {
      suggestions = [
        "${clean}${Random().nextInt(50)}",
        "${clean}_x",
        "${clean}_${DateTime.now().year}",
        "${clean}_${Random().nextInt(9999)}",
      ];
    });
  }

  void _handleNext() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final username = _usernameController.text.trim();
    final currentUser = ref.read(currentUserProvider);

    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Error: User not found. Please restart signup.',
            style: TextStyle(color: Palette.background),
          ),
          backgroundColor: Palette.textPrimary,
        ),
      );
      return;
    }

    ref.read(authViewModelProvider.notifier).updateUsername(username: username);
  }

  void _handleSkip() {
    context.goNamed(RouteConstants.Interests);
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _isFormValid.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(authViewModelProvider, (previous, next) {
      if (next.type == AuthStateType.success) {
        context.goNamed(RouteConstants.Interests);
        ref.read(authViewModelProvider.notifier).setAuthenticated();
      } else if (next.type == AuthStateType.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              next.message ?? 'An error occurred',
              style: TextStyle(color: Palette.background),
            ),
            backgroundColor: Palette.textPrimary,
          ),
        );
        // ref.read(authViewModelProvider.notifier).resetState();
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
                      child: Form(
                        key: _formKey,
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 28,
                            vertical: 16,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'What should we call you?',
                                style: TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.w800,
                                  color: Palette.textWhite,
                                ),
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                'Your @username is unique. You can always change it later.',
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Palette.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 20),
                              CustomTextField(
                                controller: _usernameController,
                                labelText: 'Username',
                                validator: usernameValidator,
                                onChanged: (value) {
                                  if (value.isNotEmpty) {
                                    generateSuggestions(value);
                                  } else {
                                    setState(() {
                                      suggestions = [];
                                    });
                                  }
                                },
                              ),
                              if (suggestions.isNotEmpty) ...[
                                const SizedBox(height: 24),
                                Wrap(
                                  spacing: 1,
                                  children: suggestions.asMap().entries.map((
                                    entry,
                                  ) {
                                    final index = entry.key;
                                    final suggestion = entry.value;

                                    return GestureDetector(
                                      onTap: () {
                                        _usernameController.text = suggestion;
                                      },
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.only(
                                              left: 0,
                                              right: 10,
                                              top: 5,
                                              bottom: 5,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.transparent,
                                              borderRadius:
                                                  BorderRadius.circular(22),
                                            ),
                                            child: Text(
                                              '@$suggestion',
                                              style: const TextStyle(
                                                color: Palette.primary,
                                                fontSize: 14,
                                              ),
                                            ),
                                          ),
                                          if (index != suggestions.length - 1)
                                            const Text(
                                              ', ',
                                              style: TextStyle(
                                                color: Palette.textSecondary,
                                                fontSize: 16,
                                              ),
                                            ),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                ),
                                const SizedBox(height: 14),
                                GestureDetector(
                                  onTap: () {
                                    generateSuggestions(
                                      _usernameController.text,
                                    );
                                  },
                                  child: const Text(
                                    'Show more',
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: Palette.primary,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
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
                color: Colors.black.withOpacity(0.5),
                child: const Center(child: Loader()),
              ),
          ],
        ),
      ),
    );
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
