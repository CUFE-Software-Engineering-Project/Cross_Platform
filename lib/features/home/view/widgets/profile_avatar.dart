import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lite_x/core/providers/current_user_provider.dart';

class ProfileAvatar extends ConsumerWidget {
  const ProfileAvatar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    if (user == null) {
      return GestureDetector(
        onTap: () => _openProfileMenu(context, user),
        child: Container(
          width: 32,
          height: 32,
          child: CircleAvatar(
            radius: 16,
            backgroundColor: Colors.grey[800],
            child: Icon(Icons.person, color: Colors.grey[400], size: 18),
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: () => _openProfileMenu(context, user),
      child: Container(
        width: 32,
        height: 32,
        child: CircleAvatar(
          radius: 16,
          backgroundColor: Colors.grey[800],
          backgroundImage: user.photo != null && user.photo!.isNotEmpty
              ? NetworkImage(user.photo!)
              : null,
          child: user.photo == null || user.photo!.isEmpty
              ? Icon(Icons.person, color: Colors.grey[400], size: 18)
              : null,
        ),
      ),
    );
  }

  void _openProfileMenu(BuildContext context, user) {
    if (user != null) {
      context.push("/profilescreen/${user.username}");
    }
  }
}
