import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lite_x/core/providers/current_user_provider.dart';
import 'package:lite_x/features/home/providers/user_profile_provider.dart';

class ProfileAvatar extends ConsumerWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;

  const ProfileAvatar({super.key, required this.scaffoldKey});

  String? _getPhotoUrl(String? photo) {
    if (photo == null || photo.isEmpty) return null;

    // If it's already a full URL, return it
    if (photo.startsWith('http://') || photo.startsWith('https://')) {
      return photo;
    }

    // Otherwise, construct the full media URL
    return 'https://litex.siematworld.online/media/$photo';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final profileState = ref.watch(userProfileProvider);

    // Debug logging
    print('👤 User photo: ${user?.photo}');
    print('👤 User name: ${user?.name}');
    print(
      '📊 Profile state: ${profileState.when(data: (p) => 'data - photo: ${p?.profilePhotoUrl}', loading: () => 'loading', error: (e, _) => 'error: $e')}',
    );

    return GestureDetector(
      onTap: () => _openDrawer(),
      child: Container(
        width: 32,
        height: 32,
        child: profileState.when(
          data: (profile) {
            // Use profile photo from API if available, otherwise fall back to user photo
            final photoUrl =
                profile?.profilePhotoUrl ?? _getPhotoUrl(user?.photo);

            return CircleAvatar(
              radius: 16,
              backgroundColor: Colors.grey[800],
              backgroundImage: photoUrl != null ? NetworkImage(photoUrl) : null,
              child: photoUrl == null
                  ? Icon(Icons.person, color: Colors.grey[400], size: 18)
                  : null,
            );
          },
          loading: () {
            // Show user photo while loading profile from API
            final photoUrl = _getPhotoUrl(user?.photo);
            return CircleAvatar(
              radius: 16,
              backgroundColor: Colors.grey[800],
              backgroundImage: photoUrl != null ? NetworkImage(photoUrl) : null,
              child: photoUrl == null
                  ? const SizedBox(
                      width: 12,
                      height: 12,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : null,
            );
          },
          error: (_, __) {
            // Fall back to user photo on error
            final photoUrl = _getPhotoUrl(user?.photo);
            return CircleAvatar(
              radius: 16,
              backgroundColor: Colors.grey[800],
              backgroundImage: photoUrl != null ? NetworkImage(photoUrl) : null,
              child: photoUrl == null
                  ? Icon(Icons.person, color: Colors.grey[400], size: 18)
                  : null,
            );
          },
        ),
      ),
    );
  }

  void _openDrawer() {
    scaffoldKey.currentState?.openDrawer();
  }
}
