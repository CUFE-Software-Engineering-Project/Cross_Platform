// lib/features/home/widgets/profile_avatar.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

// Provider for user profile data (future backend integration)
final currentUserProvider = StateProvider<UserProfile?>((ref) => null);

class UserProfile {
  final String id;
  final String name;
  final String username;
  final String avatarUrl;

  UserProfile({
    required this.id,
    required this.name,
    required this.username,
    required this.avatarUrl,
  });
}

class ProfileAvatar extends ConsumerWidget {
  const ProfileAvatar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);

    return GestureDetector(
      onTap: () => _openProfileMenu(context, ref),
      child: Container(
        width: 32,
        height: 32,
        child: CircleAvatar(
          radius: 16,
          backgroundColor: Colors.grey[800],
          backgroundImage: user?.avatarUrl.isNotEmpty == true
              ? NetworkImage(user!.avatarUrl)
              : null,
          child: user?.avatarUrl.isEmpty != false
              ? Icon(Icons.person, color: Colors.grey[400], size: 18)
              : null,
        ),
      ),
    );
  }

  void _openProfileMenu(BuildContext context, WidgetRef ref) {
    // TODO: Open side drawer or profile menu
    Scaffold.of(context).openDrawer();
  }
}
