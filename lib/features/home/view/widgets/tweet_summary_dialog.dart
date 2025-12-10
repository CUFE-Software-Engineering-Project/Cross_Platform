import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../models/tweet_summary.dart';

class TweetSummaryDialog extends StatelessWidget {
  final TweetSummary summary;

  const TweetSummaryDialog({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [const Color(0xFF1E1E1E), Colors.black],
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            width: 1.5,
            color: const Color(0xFF1DA1F2).withOpacity(0.3),
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1DA1F2).withOpacity(0.2),
              blurRadius: 24,
              spreadRadius: 0,
            ),
          ],
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(28.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Grok AI Header with SVG icon
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFF1DA1F2).withOpacity(0.3),
                            const Color(0xFF1DA1F2).withOpacity(0.1),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: const Color(0xFF1DA1F2).withOpacity(0.4),
                          width: 1,
                        ),
                      ),
                      child: SvgPicture.asset(
                        'assets/svg/grok.svg',
                        width: 28,
                        height: 28,
                        colorFilter: const ColorFilter.mode(
                          Color(0xFF1DA1F2),
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'AI Insights',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                          Text(
                            'Powered by Grok',
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),

                // AI Summary Text (if available)
                if (summary.summary != null && summary.summary!.isNotEmpty) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          const Color(0xFF1DA1F2).withOpacity(0.15),
                          const Color(0xFF1DA1F2).withOpacity(0.05),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFF1DA1F2).withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1DA1F2).withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: SvgPicture.asset(
                                'assets/svg/grok.svg',
                                width: 14,
                                height: 14,
                                colorFilter: const ColorFilter.mode(
                                  Color(0xFF1DA1F2),
                                  BlendMode.srcIn,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              'AI Summary',
                              style: TextStyle(
                                color: const Color(0xFF1DA1F2),
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          summary.summary!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            height: 1.6,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                // Metrics Grid
                _buildMetricsGrid(),

                const SizedBox(height: 24),

                // Close Button
                Container(
                  width: double.infinity,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1DA1F2), Color(0xFF1890D5)],
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF1DA1F2).withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => Navigator.of(context).pop(),
                      borderRadius: BorderRadius.circular(24),
                      child: const Center(
                        child: Text(
                          'Close',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
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

  Widget _buildMetricsGrid() {
    final metrics = [
      {
        'icon': Icons.visibility_outlined,
        'label': 'Views',
        'value': summary.views,
        'color': const Color(0xFF1DA1F2),
      },
      {
        'icon': Icons.favorite_border,
        'label': 'Likes',
        'value': summary.likes,
        'color': const Color(0xFFF91880),
      },
      {
        'icon': Icons.chat_bubble_outline,
        'label': 'Replies',
        'value': summary.replies,
        'color': const Color(0xFF1DA1F2),
      },
      {
        'icon': Icons.repeat,
        'label': 'Retweets',
        'value': summary.retweets,
        'color': const Color(0xFF00BA7C),
      },
      {
        'icon': Icons.format_quote,
        'label': 'Quotes',
        'value': summary.quotes,
        'color': const Color(0xFF1DA1F2),
      },
      {
        'icon': Icons.bookmark_border,
        'label': 'Bookmarks',
        'value': summary.bookmarks,
        'color': const Color(0xFF1DA1F2),
      },
    ];

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: metrics
          .map(
            (metric) => _buildMetricCard(
              icon: metric['icon'] as IconData,
              label: metric['label'] as String,
              value: metric['value'] as int,
              color: metric['color'] as Color,
            ),
          )
          .toList(),
    );
  }

  Widget _buildMetricCard({
    required IconData icon,
    required String label,
    required int value,
    required Color color,
  }) {
    return Container(
      width: 95,
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.grey[900]!, Colors.grey[850]!],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey[800]!.withOpacity(0.5), width: 1),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 10),
          Text(
            _formatNumber(value),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
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
