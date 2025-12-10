import 'package:flutter/material.dart';
import '../../models/tweet_summary.dart';

class TweetSummaryDialog extends StatelessWidget {
  final TweetSummary summary;

  const TweetSummaryDialog({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.black,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: Color(0xFF1DA1F2), width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Grok AI Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1DA1F2).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.auto_awesome,
                    color: Color(0xFF1DA1F2),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Tweet Insights',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // AI Summary Text (if available)
            if (summary.summary != null && summary.summary!.isNotEmpty) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1DA1F2).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFF1DA1F2).withOpacity(0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.auto_awesome,
                          color: Color(0xFF1DA1F2),
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'AI Summary',
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      summary.summary!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],

            // Metrics Grid
            _buildMetricsGrid(),

            const SizedBox(height: 20),

            // Close Button
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF1DA1F2),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
              child: const Text(
                'Close',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricsGrid() {
    final metrics = [
      {
        'icon': Icons.visibility_outlined,
        'label': 'Views',
        'value': summary.views,
      },
      {'icon': Icons.favorite_border, 'label': 'Likes', 'value': summary.likes},
      {
        'icon': Icons.chat_bubble_outline,
        'label': 'Replies',
        'value': summary.replies,
      },
      {'icon': Icons.repeat, 'label': 'Retweets', 'value': summary.retweets},
      {'icon': Icons.format_quote, 'label': 'Quotes', 'value': summary.quotes},
      {
        'icon': Icons.bookmark_border,
        'label': 'Bookmarks',
        'value': summary.bookmarks,
      },
    ];

    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: metrics
          .map(
            (metric) => _buildMetricCard(
              icon: metric['icon'] as IconData,
              label: metric['label'] as String,
              value: metric['value'] as int,
            ),
          )
          .toList(),
    );
  }

  Widget _buildMetricCard({
    required IconData icon,
    required String label,
    required int value,
  }) {
    return Container(
      width: 100,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[800]!, width: 1),
      ),
      child: Column(
        children: [
          Icon(icon, color: const Color(0xFF1DA1F2), size: 28),
          const SizedBox(height: 8),
          Text(
            _formatNumber(value),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(color: Colors.grey[400], fontSize: 12)),
        ],
      ),
    );
  }

  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }
}
