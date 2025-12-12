import 'package:flutter/material.dart';
import 'package:lite_x/features/profile/models/shared.dart';
import '../../models/trend_model.dart';

class TrendTile extends StatelessWidget {
  final TrendModel trend;
  final String trendCategory;
  final bool showRank;
  const TrendTile({
    super.key,
    required this.trend,
    required this.trendCategory,
    required this.showRank,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Context label (e.g., Trending in Egypt)
                Text(
                  "${showRank ? trend.rank : ""}${showRank ? "." : ""}Trending in ${this.trendCategory}",
                  style: textTheme.labelSmall?.copyWith(
                    color: const Color.fromARGB(255, 95, 101, 104),
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                // Title
                Text(
                  "#" + trend.title,
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 4),
                // Posts count
                if (trend.postCount != 0)
                  Text(
                    "${Shared.formatCount(trend.postCount.toInt())} posts",
                    style: textTheme.labelSmall?.copyWith(
                      color: colorScheme.onSurface.withOpacity(0.7),
                      fontSize: 13,
                    ),
                  ),
              ],
            ),
          ),
          // Kebab menu icon
          IconButton(
            icon: const Icon(Icons.more_vert),
            color: colorScheme.onSurface.withOpacity(0.7),
            iconSize: 18,
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}
