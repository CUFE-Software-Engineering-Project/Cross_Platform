import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lite_x/core/routes/Route_Constants.dart';
import 'package:lite_x/core/theme/Palette.dart';
import 'package:lite_x/core/view/widgets/Loader.dart';
import 'package:lite_x/features/auth/view/widgets/buildXLogo.dart';
import 'package:lite_x/features/auth/view_model/auth_state.dart';
import 'package:lite_x/features/auth/view_model/auth_view_model.dart';
import 'package:lite_x/features/auth/models/ExploreCategory.dart';

class Interests extends ConsumerStatefulWidget {
  const Interests({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _InterestsState();
}

class _InterestsState extends ConsumerState<Interests> {
  final Set<String> _selectedCategoryNames = {};
  List<ExploreCategory> _categories = [];
  bool _isLoadingCategories = true;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    setState(() {
      _isLoadingCategories = true;
    });

    final categories = await ref
        .read(authViewModelProvider.notifier)
        .getCategories();

    setState(() {
      _categories = categories;
      _isLoadingCategories = false;
    });

    if (categories.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Failed to load categories',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.black,
          ),
        );
      }
    }
  }

  void _handleNext() {
    if (_selectedCategoryNames.isNotEmpty) {
      ref
          .read(authViewModelProvider.notifier)
          .saveInterests(_selectedCategoryNames);
    }
  }

  void _toggleInterest(String categoryName) {
    setState(() {
      if (_selectedCategoryNames.contains(categoryName)) {
        _selectedCategoryNames.remove(categoryName);
      } else {
        _selectedCategoryNames.add(categoryName);
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
            content: Text(
              next.message ?? 'Failed to save interests',
              style: TextStyle(color: Palette.textWhite),
            ),
            backgroundColor: Palette.background,
          ),
        );
        ref.read(authViewModelProvider.notifier).setAuthenticated(); //
      }
    });

    final authState = ref.watch(authViewModelProvider);
    final isLoading = authState.isLoading;
    final bool isNextEnabled = _selectedCategoryNames.isNotEmpty;

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
            if (_isLoadingCategories)
              const Center(child: Loader())
            else
              SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
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
                    if (_categories.isEmpty)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(20.0),
                          child: Text(
                            'No categories available',
                            style: TextStyle(
                              color: Palette.textTertiary,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      )
                    else
                      _buildInterestsWrap(),
                    const SizedBox(height: 125),
                  ],
                ),
              ),
            if (!_isLoadingCategories)
              _buildNextButton(isNextEnabled, isLoading),
            if (isLoading)
              Container(color: Colors.black, child: const Loader()),
          ],
        ),
      ),
    );
  }

  Widget _buildInterestsWrap() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 5,
        crossAxisSpacing: 10.0,
        mainAxisSpacing: 10.0,
      ),
      itemCount: _categories.length,
      itemBuilder: (context, index) {
        final category = _categories[index];
        final bool isSelected = _selectedCategoryNames.contains(category.name);
        return FilterChip(
          label: SizedBox(
            width: double.infinity,
            child: Text(
              category.name,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: isSelected ? Palette.background : Palette.textWhite,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
          selected: isSelected,
          onSelected: (bool selected) {
            _toggleInterest(category.name);
          },
          backgroundColor: Palette.cardBackground,
          selectedColor: Palette.primary,
          checkmarkColor: Palette.background,
          showCheckmark: false,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50),
            side: BorderSide(
              color: isSelected ? Palette.primary : Palette.border,
              width: 1.5,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
        );
      },
    );
  }

  Widget _buildNextButton(bool isEnabled, bool isLoading) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 30),
        color: Palette.background,
        child: SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: (isEnabled && !isLoading) ? _handleNext : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: Palette.textWhite,
              disabledBackgroundColor: Palette.textWhite.withOpacity(0.6),
              foregroundColor: Palette.background,
              disabledForegroundColor: Palette.textSecondary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
            child: isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Palette.background,
                      ),
                    ),
                  )
                : const Text(
                    'Next',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                  ),
          ),
        ),
      ),
    );
  }
}
