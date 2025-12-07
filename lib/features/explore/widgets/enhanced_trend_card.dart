import 'package:flutter/material.dart';
import 'package:lite_x/core/theme/palette.dart';
import '../models/trend_model.dart';

class EnhancedTrendCard extends StatelessWidget {
  final TrendModel trend;
  final VoidCallback? onTap;

  const EnhancedTrendCard({
    super.key,
    required this.trend,
    this.onTap,
  });

  String _formatPostCount(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(0)}K';
    }
    return count.toString();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap ?? () {
        // Navigate to trend timeline
      },
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: Palette.divider,
              width: 1,
            ),
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(8),
            child: Ink(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.transparent,
              ),
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                  // Left Content Section
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Headline
                        Text(
                          trend.headline ?? trend.title,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Palette.textPrimary,
                            height: 1.3,
                          ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 12),
                      // Avatars Row and Metadata in one row
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Avatars Row
                          if (trend.avatarUrls != null && trend.avatarUrls!.isNotEmpty) ...[
                            _buildAvatarRow(trend.avatarUrls!),
                            const SizedBox(width: 12),
                          ],
                          // Metadata Line
                          Expanded(
  child: Row(
    children: [
      Flexible(
        child: Text(
          trend.timestamp ?? '',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 13, color: Palette.textSecondary),
        ),
      ),

      const Text(' · ', style: TextStyle(fontSize: 13)),

      Flexible(
        child: Text(
          trend.category ?? '',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 13, color: Palette.textSecondary),
        ),
      ),

      const Text(' · ', style: TextStyle(fontSize: 13)),

      Flexible(
        child: Text(
          '${_formatPostCount(trend.postCount)} posts',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 13, color: Palette.textSecondary),
        ),
      ),
    ],
  ),
)


                        ],
                      ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Right Content Section (Thumbnail)
                  if (trend.imageUrl != null && trend.imageUrl!.isNotEmpty)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        trend.imageUrl!,
                        width: 72,
                        height: 72,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            color: Palette.cardBackground,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.image,
                            color: Palette.icons,
                            size: 24,
                          ),
                        ),
                      ),
                    )
                  else
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: Palette.cardBackground,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.image,
                        color: Palette.icons,
                        size: 24,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarRow(List<String> avatarUrls) {
    // Show maximum 3 avatars, overlapping by 12px
    final avatarsToShow = avatarUrls.take(3).toList();
    
    // Calculate width: first avatar (24px) + overlap spacing (12px * (count - 1))
    final totalWidth = 24.0 + (12.0 * (avatarsToShow.length - 1));

    return SizedBox(
      width: totalWidth,
      height: 24,
      child: Stack(
        clipBehavior: Clip.none,
        children: avatarsToShow.asMap().entries.map((entry) {
          final index = entry.key;
          final avatarUrl = entry.value;
          
          return Positioned(
            left: index * 12.0, // Overlap by 12px
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Palette.background,
                  width: 1.5,
                ),
                color: Palette.cardBackground,
              ),
              child: avatarUrl.isNotEmpty
                  ? ClipOval(
                      child: Image.network(
                        avatarUrl,
                        width: 24,
                        height: 24,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => const Icon(
                          Icons.person,
                          size: 14,
                          color: Palette.icons,
                        ),
                      ),
                    )
                  : const Icon(
                      Icons.person,
                      size: 14,
                      color: Palette.icons,
                    ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

