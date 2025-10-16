// lib/features/shared/widgets/bottom_navigation.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lite_x/core/routes/app_shell.dart';

class XBottomNavigation extends ConsumerWidget {
  const XBottomNavigation({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = ref.watch(shellNavigationProvider);

    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: Colors.black,
        border: Border(top: BorderSide(color: Colors.grey[800]!, width: 0.5)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _NavItem(
            icon: Icons.home,
            isSelected: selectedIndex == 0,
            onTap: () => _onTabTapped(ref, 0),
          ),
          _NavItem(
            icon: Icons.search,
            isSelected: selectedIndex == 1,
            onTap: () => _onTabTapped(ref, 1),
          ),
          _NavItem(
            icon: Icons.group_outlined,
            isSelected: selectedIndex == 2,
            onTap: () => _onTabTapped(ref, 2),
          ),
          _NavItem(
            icon: Icons.notifications_outlined,
            isSelected: selectedIndex == 3,
            onTap: () => _onTabTapped(ref, 3),
          ),
          _NavItem(
            icon: Icons.mail_outline,
            isSelected: selectedIndex == 4,
            onTap: () => _onTabTapped(ref, 4),
          ),
        ],
      ),
    );
  }

  void _onTabTapped(WidgetRef ref, int index) {
    ref.read(shellNavigationProvider.notifier).state = index;
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        child: Icon(
          icon,
          color: isSelected ? Colors.white : Colors.grey[600],
          size: 26,
        ),
      ),
    );
  }
}
