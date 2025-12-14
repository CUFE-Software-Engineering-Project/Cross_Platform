import 'package:flutter/material.dart';
import 'package:lite_x/core/theme/Palette.dart';
import 'package:lite_x/features/search/data/search_repository.dart';
import 'package:lite_x/features/profile/models/shared.dart';

class PeopleCard extends StatelessWidget {
  final SearchSuggestionUser user;
  final VoidCallback? onTap;
  final VoidCallback? onFollowTap;
  final bool showFollowButton;

  const PeopleCard({
    super.key,
    required this.user,
    this.onTap,
    this.onFollowTap,
    this.showFollowButton = true,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            ClipOval(
              child: SizedBox(
                width: 40,
                height: 40,
                child: BuildSmallProfileImage(
                  mediaId: user.avatarUrl,
                  radius: 20,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          user.name,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Palette.textPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      if (user.verified)
                        const Padding(
                          padding: EdgeInsets.only(left: 4.0),
                          child: Icon(
                            Icons.verified,
                            color: Palette.verified,
                            size: 16,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '@${user.userName}',
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Palette.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                  if (user.bio != null && user.bio!.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      user.bio!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Palette.textTertiary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 12),
            showFollowButton
                ? OutlinedButton(
                    onPressed: onFollowTap,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.black,
                      backgroundColor: Colors.white,
                    ),
                    child: Text(
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),

                      user.isFollowing
                          ? 'Following'
                          : user.isFollower
                          ? 'Follow back'
                          : 'Follow',
                    ),
                  )
                : const SizedBox.shrink(),
          ],
        ),
      ),
    );
  }
}
