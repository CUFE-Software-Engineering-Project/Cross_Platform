import 'package:flutter/material.dart';
import 'package:lite_x/core/theme/Palette.dart';
import '../models/who_to_follow_model.dart';

class WhoToFollowCard extends StatelessWidget {
  final WhoToFollowModel user;
  final VoidCallback? onTap;
  final Function(String)? onFollowTap;

  const WhoToFollowCard({
    super.key,
    required this.user,
    this.onTap,
    this.onFollowTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap:
            onTap ??
            () {
              // Navigate to user profile
            },
        borderRadius: BorderRadius.circular(12),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Colors.transparent,
          ),
          child: Container(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar Section (Left)
                GestureDetector(
                  onTap:
                      onTap ??
                      () {
                        // Navigate to user profile
                      },
                  child: CircleAvatar(
                    radius: 28,
                    backgroundColor: Palette.primary,
                    backgroundImage: user.avatarUrl.isNotEmpty
                        ? NetworkImage(user.avatarUrl)
                        : null,
                    child: user.avatarUrl.isEmpty
                        ? const Icon(
                            Icons.person,
                            size: 28,
                            color: Palette.textPrimary,
                          )
                        : null,
                  ),
                ),
                const SizedBox(width: 12),
                // Information Section (Middle)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Display Name and Verified Badge
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              user.displayName,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Palette.textPrimary,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (user.isVerified) ...[
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.check_circle,
                              size: 16,
                              color: Palette.verified,
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),
                      // Username
                      Text(
                        '@${user.username}',
                        style: const TextStyle(
                          fontSize: 15,
                          color: Palette.textSecondary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      // Bio or Description
                      if (user.bio != null && user.bio!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          user.bio!,
                          style: const TextStyle(
                            fontSize: 15,
                            color: Palette.textPrimary,
                            height: 1.3,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                // Follow Button Section (Right)
                SizedBox(
                  width: 100,
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        onFollowTap?.call(user.id);
                      },
                      borderRadius: BorderRadius.circular(20),
                      child: Ink(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: user.isFollowing
                                ? Palette.textSecondary
                                : Palette.textPrimary,
                            width: 1,
                          ),
                          color: user.isFollowing
                              ? Colors.transparent
                              : Palette.textPrimary,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          child: Center(
                            child: Text(
                              user.isFollowing ? 'Following' : 'Follow',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: user.isFollowing
                                    ? Palette.textPrimary
                                    : Palette.background,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
