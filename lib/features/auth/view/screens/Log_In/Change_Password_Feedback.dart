import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lite_x/core/routes/Route_Constants.dart';
import 'package:lite_x/core/theme/Palette.dart';
import 'package:lite_x/features/auth/view/widgets/buildXLogo.dart';

class ChangePasswordFeedback extends ConsumerStatefulWidget {
  const ChangePasswordFeedback({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _ChangePasswordFeedbackState();
}

class _ChangePasswordFeedbackState
    extends ConsumerState<ChangePasswordFeedback> {
  String _selectedMethod = "";
  @override
  void initState() {
    super.initState();
    // Future.microtask(() {
    //   ref.read(authViewModelProvider.notifier).resetState();//
    // });
  }

  void _handleNext() {
    if (_selectedMethod.isNotEmpty) {
      context.goNamed(RouteConstants.homescreen);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Palette.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close, color: Palette.textWhite),
          onPressed: () => context.goNamed(RouteConstants.introscreen),
        ),
        title: buildXLogo(size: 36),
        centerTitle: true,
        backgroundColor: Palette.background,
        elevation: 0,
      ),

      body: Center(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(color: Palette.background),
          child: Column(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          children: [
                            const Text(
                              'Why\'d you change your password?',
                              style: TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.w800,
                                color: Palette.textWhite,
                              ),
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'Your feedback helps us understand when and why people need to change their passwords.',
                              style: TextStyle(
                                fontSize: 16,
                                color: Palette.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 32),
                            _buildOption(
                              title: 'I forgot my password',
                              optionValue: 'forgot',
                            ),
                            const SizedBox(height: 24),
                            _buildOption(
                              title:
                                  'There was suspicious activity on my account',
                              optionValue: 'suspicious',
                            ),
                            const SizedBox(height: 24),
                            _buildOption(
                              title:
                                  'I changed my password for a different reason',
                              optionValue: 'different',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              _buildNextButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOption({required String title, required String optionValue}) {
    final isSelected = _selectedMethod == optionValue;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedMethod = optionValue;
        });
      },
      child: Container(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  color: Palette.textWhite,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? Palette.primary : Palette.textSecondary,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 14,
                        height: 14,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Palette.primary,
                        ),
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNextButton() {
    return Container(
      padding: EdgeInsets.all(10),
      alignment: Alignment.centerRight,
      child: SizedBox(
        width: 100,
        height: 45,
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: ElevatedButton(
            onPressed: _selectedMethod.isNotEmpty ? _handleNext : null,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              backgroundColor: Palette.textWhite,
              disabledBackgroundColor: Palette.textWhite.withOpacity(0.6),
              foregroundColor: Palette.background,
              disabledForegroundColor: Palette.border,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
            child: const Text(
              'Next',
              style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }
}
