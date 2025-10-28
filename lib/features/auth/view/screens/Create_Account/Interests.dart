import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lite_x/core/routes/Route_Constants.dart';
import 'package:lite_x/core/theme/Palette.dart';
import 'package:lite_x/features/auth/view/widgets/buildXLogo.dart';

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
      // context.goNamed(RouteConstants.home);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: Duration(seconds: 2),
          backgroundColor: Palette.container_message_color,
          content: Text(
            'Preferences saved: ${_selectedInterests.join(', ')}',
            style: const TextStyle(color: Palette.textWhite),
          ),
        ),
      );
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
    final bool isNextEnabled = _selectedInterests.isNotEmpty;

    return Scaffold(
      backgroundColor: Palette.background,
      appBar: AppBar(
        title: buildXLogo(size: 36),
        centerTitle: true,
        backgroundColor: Palette.background,
        elevation: 0,
      ),
      body: Stack(
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
                  style: TextStyle(fontSize: 16, color: Palette.textSecondary),
                ),
                const SizedBox(height: 28),
                _buildInterestsWrap(),
                const SizedBox(height: 125),
              ],
            ),
          ),
          _buildNextButton(isNextEnabled),
        ],
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

  Widget _buildNextButton(bool isEnabled) {
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
          onPressed: isEnabled ? _handleNext : null,
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
