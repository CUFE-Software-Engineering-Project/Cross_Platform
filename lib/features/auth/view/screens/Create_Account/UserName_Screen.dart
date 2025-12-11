import 'dart:async';
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
  Timer? _debounce;
  bool _isSuggestionLoading = false;

  @override
  void initState() {
    super.initState();
    _usernameController.addListener(_validateForm);
    WidgetsBinding.instance.addPostFrameCallback((_) {});
  }

  void _validateForm() {
    final isValid =
        _usernameController.text.trim().isNotEmpty &&
        _usernameController.text.trim().length > 3;

    _isFormValid.value = isValid;

    if (_usernameController.text.trim().length > 3) {
      _fetchSuggestions(_usernameController.text.trim());
    } else {
      if (suggestions.isNotEmpty || _isSuggestionLoading) {
        setState(() {
          suggestions = [];
          _isSuggestionLoading = false;
        });
      }
    }
  }

  void _fetchSuggestions(String name) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    setState(() {
      _isSuggestionLoading = true;
      suggestions = [];
    });

    _debounce = Timer(const Duration(milliseconds: 500), () async {
      final fetchedSuggestions = await ref
          .read(authViewModelProvider.notifier)
          .suggestUsernames(username: name);

      if (mounted) {
        setState(() {
          suggestions = fetchedSuggestions.take(4).toList();
          _isSuggestionLoading = false;
        });
      }
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
    _debounce?.cancel();
    _usernameController.removeListener(_validateForm);
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
      }
    });

    final authState = ref.watch(authViewModelProvider);
    final isFormSubmitting = authState.isLoading;

    return Scaffold(
      backgroundColor: Palette.background,
      appBar: AppBar(
        title: buildXLogo(size: 36),
        centerTitle: true,
        backgroundColor: Palette.background,
        elevation: 0,
      ),
      body: AbsorbPointer(
        absorbing: isFormSubmitting,
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
                              ),
                              if (suggestions.isNotEmpty &&
                                  !_isSuggestionLoading) ...[
                                const SizedBox(height: 20),
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
                                              right: 8,
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
                                const SizedBox(height: 4),
                                GestureDetector(
                                  onTap: () {
                                    _fetchSuggestions(
                                      _usernameController.text.trim(),
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
            if (isFormSubmitting)
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
      padding: const EdgeInsets.all(10),
      child: Row(
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: OutlinedButton(
              onPressed: _handleSkip,
              style: OutlinedButton.styleFrom(
                foregroundColor: Palette.textWhite,
                side: const BorderSide(color: Palette.textWhite, width: 1),
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 10,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              child: const Text(
                'Skip for now',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          const Spacer(),
          ValueListenableBuilder<bool>(
            valueListenable: _isFormValid,
            builder: (context, isValid, child) {
              return SizedBox(
                width: 100,
                height: 45,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: ElevatedButton(
                    onPressed: isValid ? _handleNext : null,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      backgroundColor: Palette.textWhite,
                      disabledBackgroundColor: Palette.textWhite.withOpacity(
                        0.6,
                      ),
                      foregroundColor: Palette.background,
                      disabledForegroundColor: Palette.border,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child: const Text(
                      'Next',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
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
