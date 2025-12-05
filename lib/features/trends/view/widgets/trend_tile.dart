import 'package:flutter/material.dart';
import '../../models/trend_model.dart';

class TrendTile extends StatelessWidget {
  final TrendModel trend;
  const TrendTile({super.key, required this.trend});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Rank number
          Padding(
            padding: const EdgeInsets.only(right: 12.0, top: 2.0),
            child: Text(
              '${trend.rank}',
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ),
          // Main content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Context label (e.g., Trending in Egypt)
                Text(
                  trend.contextLabel,
                  style: textTheme.labelSmall?.copyWith(
                    color: colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 4),
                // Title
                Text(
                  trend.title,
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                // Posts count
                if (trend.postsCountLabel != null)
                  Text(
                    trend.postsCountLabel!,
                    style: textTheme.labelSmall?.copyWith(
                      color: colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
              ],
            ),
          ),
          // Kebab menu icon
          if (trend.hasMenu)
            IconButton(
              icon: const Icon(Icons.more_vert),
              color: colorScheme.onSurface.withOpacity(0.7),
              onPressed: () {},
            ),
        ],
      ),
    );
  }
}
