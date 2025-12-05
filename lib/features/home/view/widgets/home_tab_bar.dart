import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lite_x/features/home/view_model/home_state.dart';
import 'package:lite_x/features/home/view_model/home_view_model.dart';

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

    final initialFeed = ref.read(homeViewModelProvider).currentFeed;
    // For You is at position 0 (left), Following is at position 1 (right)
    _animationController.value = initialFeed == FeedType.following ? 1.0 : 0.0;
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selectedFeed = ref.watch(
      homeViewModelProvider.select((state) => state.currentFeed),
    );

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
                  isSelected: selectedFeed == FeedType.forYou,
                  onTap: () => _onTabSelected(FeedType.forYou),
                ),
              ),
              Expanded(
                child: _TabButton(
                  title: 'Following',
                  isSelected: selectedFeed == FeedType.following,
                  onTap: () => _onTabSelected(FeedType.following),
                ),
              ),
            ],
          ),
          _buildAnimatedIndicator(selectedFeed),
        ],
      ),
    );
  }

  Widget _buildAnimatedIndicator(FeedType selectedFeed) {
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
            margin: selectedFeed == FeedType.forYou
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

  void _onTabSelected(FeedType feed) {
    if (feed == FeedType.following) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }

    ref.read(homeViewModelProvider.notifier).switchFeed(feed);
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
