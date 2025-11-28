// lib/core/routes/app_shell.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:lite_x/features/home/view/screens/home_screen.dart';
import 'package:lite_x/features/profile/view/screens/explore_profile_screen.dart';
import 'package:lite_x/features/profile/view/screens/profile_search_screen.dart';
import 'package:lite_x/features/shared/widgets/bottom_navigation.dart';
import 'package:lite_x/features/notifications/view/screens/Notification_Screen.dart';

// Provider for managing which tab is selected
final shellNavigationProvider = StateProvider<int>((ref) => 0);

// Provider for bottom navigation visibility
final bottomNavVisibilityProvider = StateProvider<bool>((ref) => true);

class AppShell extends ConsumerWidget {
  const AppShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = ref.watch(shellNavigationProvider);
    final isBottomNavVisible = ref.watch(bottomNavVisibilityProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      body: IndexedStack(
        index: selectedIndex,
        children: [
          const HomeScreen(), // Index 0 - Home
          // _buildSearchScreen(), // Index 1 - Search
          ExploreProfileScreen(),
          _buildCommunitiesScreen(), // Index 2 - Communities
          NotificationScreen(), // Index 3 - Notifications
          _buildMessagesScreen(), // Index 4 - Messages
        ],
      ),
      bottomNavigationBar: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        height: isBottomNavVisible ? 60 : 0,
        clipBehavior: Clip.hardEdge,
        decoration: const BoxDecoration(),
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 300),
          opacity: isBottomNavVisible ? 1.0 : 0.0,
          child: OverflowBox(maxHeight: 60, child: const XBottomNavigation()),
        ),
      ),
    );
  }

  // Placeholder screens - you'll create these later
  Widget _buildSearchScreen() {
    return const Center(
      child: Text(
        'Search Screen',
        style: TextStyle(color: Colors.white, fontSize: 24),
      ),
    );
  }

  Widget _buildNotificationsScreen() {
    return const Center(
      child: Text(
        'Notifications Screen',
        style: TextStyle(color: Colors.white, fontSize: 24),
      ),
    );
  }

  Widget _buildMessagesScreen() {
    return const Center(
      child: Text(
        'Messages Screen',
        style: TextStyle(color: Colors.white, fontSize: 24),
      ),
    );
  }

  Widget _buildCommunitiesScreen() {
    return const Center(
      child: Text(
        'Communities Screen',
        style: TextStyle(color: Colors.white, fontSize: 24),
      ),
    );
  }
}
