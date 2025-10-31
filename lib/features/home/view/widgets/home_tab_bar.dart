import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
final homeTabProvider = StateProvider<HomeTab>((ref) => HomeTab.forYou);
final tabPageControllerProvider = Provider<PageController>((ref) {
  return PageController(initialPage: 0);
});

enum HomeTab { forYou, following }

class HomeTabBar extends ConsumerStatefulWidget {
  const HomeTabBar({super.key});

  @override
  ConsumerState<HomeTabBar> createState() => _HomeTabBarState();
}

class _HomeTabBarState extends ConsumerState<HomeTabBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _indicatorAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _indicatorAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selectedTab = ref.watch(homeTabProvider);

    return Container(
      height: 48,
      color: Colors.black,
      child: Stack(
        children: [
          Row(
            children: [
              Expanded(
                child: _TabButton(
                  title: 'For you',
                  isSelected: selectedTab == HomeTab.forYou,
                  onTap: () => _onTabSelected(HomeTab.forYou),
                ),
              ),
              Expanded(
                child: _TabButton(
                  title: 'Following',
                  isSelected: selectedTab == HomeTab.following,
                  onTap: () => _onTabSelected(HomeTab.following),
                ),
              ),
            ],
          ),
          _buildAnimatedIndicator(selectedTab),
        ],
      ),
    );
  }

  Widget _buildAnimatedIndicator(HomeTab selectedTab) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: AnimatedBuilder(
        animation: _indicatorAnimation,
        builder: (context, child) {
          final screenWidth = MediaQuery.of(context).size.width;
          final tabWidth = screenWidth / 2;
          final indicatorPosition = tabWidth;

          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            margin: selectedTab == HomeTab.forYou
                ? EdgeInsets.only(right: indicatorPosition)
                : EdgeInsets.only(left: indicatorPosition),
            width: tabWidth,
            height: 3,
            decoration: const BoxDecoration(
              color: Color(0xFF1DA1F2), // X blue
              borderRadius: BorderRadius.vertical(top: Radius.circular(1.5)),
            ),
          );
        },
      ),
    );
  }

  void _onTabSelected(HomeTab tab) {
    ref.read(homeTabProvider.notifier).state = tab;
    if (tab == HomeTab.following) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }
}

class _TabButton extends StatelessWidget {
  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  const _TabButton({
    required this.title,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        alignment: Alignment.center,
        child: AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey[500],
            fontSize: 15,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          ),
          child: Text(title),
        ),
      ),
    );
  }
}