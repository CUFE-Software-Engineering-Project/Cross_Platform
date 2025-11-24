import 'package:flutter/material.dart';
import 'package:lite_x/core/theme/palette.dart';
import '../models/trend_model.dart';

class TrendCard extends StatelessWidget {
  final TrendModel trend;
  final VoidCallback? onTap;

  const TrendCard({
    super.key,
    required this.trend,
    this.onTap,
  });

  String _formatPostCount(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Category/Location
                      if (trend.category != null || trend.location != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Text(
                            trend.location != null
                                ? 'Trending in ${trend.location}'
                                : trend.category != null
                                    ? 'Trending in ${trend.category}'
                                    : '',
                            style: const TextStyle(
                              fontSize: 13,
                              color: Palette.textSecondary,
                            ),
                          ),
                        ),
                      // Title
                      Row(
                        children: [
                          Text(
                            trend.isHashtag ? '#${trend.title}' : trend.title,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Palette.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      // Post count
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          '${_formatPostCount(trend.postCount)} posts',
                          style: const TextStyle(
                            fontSize: 13,
                            color: Palette.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // More options button
                IconButton(
                  icon: const Icon(
                    Icons.more_vert,
                    size: 20,
                    color: Palette.icons,
                  ),
                  onPressed: () {
                    // Show trend options
                  },
                  constraints: const BoxConstraints(),
                  padding: EdgeInsets.zero,
                ),
              ],
            ),
            // Optional description or preview
            if (trend.description != null) ...[
              const SizedBox(height: 8),
              Text(
                trend.description!,
                style: const TextStyle(
                  fontSize: 13,
                  color: Palette.textSecondary,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

