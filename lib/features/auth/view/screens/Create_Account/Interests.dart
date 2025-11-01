import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lite_x/core/routes/Route_Constants.dart';
import 'package:lite_x/core/theme/Palette.dart';
import 'package:lite_x/core/view/widgets/Loader.dart';
import 'package:lite_x/features/auth/view/widgets/buildXLogo.dart';
import 'package:lite_x/features/auth/view_model/auth_state.dart';
import 'package:lite_x/features/auth/view_model/auth_view_model.dart';

class Interests extends ConsumerStatefulWidget {
  const Interests({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _InterestsState();
}

class _InterestsState extends ConsumerState<Interests> {
  final Set<String> _selectedInterests = {};
  final Map<String, String> _availableInterests = {
    'Sports': 'sports',
    'Entertainment': 'entertainment',
    'News': 'news',
    'Technology': 'tech',
    'Music': 'music',
    'Gaming': 'gaming',
    'Fashion & Beauty': 'fashion',
    'Food': 'food',
    'Business & Finance': 'business',
    'Science': 'science',
  };

  void _handleNext() {
    if (_selectedInterests.isNotEmpty) {
      ref
          .read(authViewModelProvider.notifier)
          .saveInterests(_selectedInterests);
    }
  }

  void _toggleInterest(String interestId) {
    setState(() {
      if (_selectedInterests.contains(interestId)) {
        _selectedInterests.remove(interestId);
      } else {
        _selectedInterests.add(interestId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(authViewModelProvider, (previous, next) {
      if (next.type == AuthStateType.success) {
        context.goNamed(RouteConstants.homescreen);
        ref.read(authViewModelProvider.notifier).setAuthenticated();
      } else if (next.type == AuthStateType.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.message ?? 'Failed to save interests'),
            backgroundColor: Palette.textWhite,
          ),
        );
        ref.read(authViewModelProvider.notifier).setAuthenticated();
      }
    });

    final authState = ref.watch(authViewModelProvider);
    final isLoading = authState.isLoading;
    final bool isNextEnabled = _selectedInterests.isNotEmpty;
    return Scaffold(
      backgroundColor: Palette.background,
      appBar: AppBar(
        title: buildXLogo(size: 36),
        centerTitle: true,
        backgroundColor: Palette.background,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: AbsorbPointer(
        absorbing: isLoading,
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'What do you want to see on X ?',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Palette.textWhite,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Select topics you\'re interested in to help personalize your experience. You can change these any time.',
                    style: TextStyle(
                      fontSize: 16,
                      color: Palette.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 28),
                  _buildInterestsWrap(),
                  const SizedBox(height: 125),
                ],
              ),
            ),
            _buildNextButton(isNextEnabled, isLoading),
            if (isLoading)
              Container(color: Colors.black, child: const Loader()),
          ],
        ),
      ),
    );
  }

  Widget _buildInterestsWrap() {
    return Wrap(
      spacing: 12.0,
      runSpacing: 12.0,
      children: _availableInterests.entries.map((entry) {
        final String label = entry.key;
        final String id = entry.value;
        final bool isSelected = _selectedInterests.contains(id);

        return FilterChip(
          label: Text(
            label,
            style: TextStyle(
              color: isSelected ? Palette.background : Palette.textWhite,
              fontWeight: FontWeight.bold,
            ),
          ),
          selected: isSelected,
          onSelected: (bool selected) {
            _toggleInterest(id);
          },
          backgroundColor: Palette.cardBackground,
          selectedColor: Palette.primary,
          checkmarkColor: Palette.background,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50),
            side: BorderSide(
              color: isSelected ? Palette.primary : Palette.border,
              width: 1.5,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        );
      }).toList(),
    );
  }

  Widget _buildNextButton(bool isEnabled, bool isLoading) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        padding: const EdgeInsets.only(
          bottom: 20,
          left: 20,
          right: 20,
          top: 20,
        ),
        decoration: BoxDecoration(color: Palette.background),
        width: double.infinity,
        child: ElevatedButton(
          onPressed: (isEnabled && !isLoading) ? _handleNext : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: Palette.textWhite,
            disabledBackgroundColor: Palette.textWhite.withOpacity(0.6),
            foregroundColor: Palette.background,
            disabledForegroundColor: Palette.textSecondary,
            minimumSize: const Size(double.infinity, 50),
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
    );
  }
}
