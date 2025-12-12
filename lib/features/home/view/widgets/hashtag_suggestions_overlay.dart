import 'package:flutter/material.dart';
import '../../services/hashtag_service.dart';

class HashtagSuggestionsOverlay extends StatelessWidget {
  final List<HashtagSuggestion> suggestions;
  final Function(String) onHashtagSelected;
  final double? width;

  const HashtagSuggestionsOverlay({
    super.key,
    required this.suggestions,
    required this.onHashtagSelected,
    this.width,
  });

  String _formatCount(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    }
    return count.toString();
  }

  @override
  Widget build(BuildContext context) {
    if (suggestions.isEmpty) return const SizedBox.shrink();

    return Material(
      elevation: 8,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: width ?? MediaQuery.of(context).size.width - 32,
        constraints: const BoxConstraints(maxHeight: 200),
        decoration: BoxDecoration(
          color: const Color(0xFF16181C),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[800]!, width: 1),
        ),
        child: ListView.separated(
          padding: EdgeInsets.zero,
          shrinkWrap: true,
          itemCount: suggestions.length,
          separatorBuilder: (context, index) =>
              Divider(height: 1, thickness: 1, color: Colors.grey[800]),
          itemBuilder: (context, index) {
            final suggestion = suggestions[index];
            return InkWell(
              onTap: () => onHashtagSelected(suggestion.hashtag),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    const Icon(Icons.tag, color: Color(0xFF1DA1F2), size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '#${suggestion.hashtag}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${_formatCount(suggestion.tweetCount)} posts',
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.trending_up, color: Colors.grey[600], size: 18),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
