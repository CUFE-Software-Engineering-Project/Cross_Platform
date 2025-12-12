import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class TextWithHashtags {
  static TextSpan buildTextSpan({
    required String text,
    required TextStyle style,
    Function(String)? onHashtagTap,
    Function(String)? onMentionTap,
    List<String>? knownHashtags, // Hashtags from backend
  }) {
    final List<InlineSpan> spans = [];

    // Build regex based on known hashtags from backend if available
    String hashtagPattern;
    if (knownHashtags != null && knownHashtags.isNotEmpty) {
      // Use exact hashtags from backend - escape special chars and match them
      final escapedTags = knownHashtags
          .map((tag) => RegExp.escape(tag.replaceAll('#', '')))
          .join('|');
      hashtagPattern = '#(?:$escapedTags)';
    } else {
      // Fallback to general pattern
      hashtagPattern = r'#[\w\u0600-\u06FF]+';
    }

    final RegExp hashtagRegex = RegExp(hashtagPattern, caseSensitive: false);
    final RegExp mentionRegex = RegExp(r'@[\w\u0600-\u06FF]+');
    final RegExp combinedRegex = RegExp(
      '($hashtagPattern|@[\\w\\u0600-\\u06FF]+)',
      caseSensitive: false,
    );

    int lastMatchEnd = 0;

    for (final match in combinedRegex.allMatches(text)) {
      // Add normal text before the match
      if (match.start > lastMatchEnd) {
        spans.add(
          TextSpan(
            text: text.substring(lastMatchEnd, match.start),
            style: style,
          ),
        );
      }

      final matchText = match.group(0)!;
      final isHashtag = hashtagRegex.hasMatch(matchText);
      final isMention = mentionRegex.hasMatch(matchText);

      if (isHashtag && onHashtagTap != null) {
        // Clickable hashtag
        final hashtag = matchText.substring(1); // Remove #
        spans.add(
          TextSpan(
            text: matchText,
            style: style.copyWith(
              color: const Color(0xFF1DA1F2),
              fontWeight: FontWeight.w500,
            ),
            recognizer: TapGestureRecognizer()
              ..onTap = () => onHashtagTap(hashtag),
          ),
        );
      } else if (isMention && onMentionTap != null) {
        // Clickable mention
        final username = matchText.substring(1); // Remove @
        spans.add(
          TextSpan(
            text: matchText,
            style: style.copyWith(
              color: const Color(0xFF1DA1F2),
              fontWeight: FontWeight.w500,
            ),
            recognizer: TapGestureRecognizer()
              ..onTap = () => onMentionTap(username),
          ),
        );
      } else {
        // Non-clickable (no handler provided)
        spans.add(
          TextSpan(
            text: matchText,
            style: style.copyWith(
              color: const Color(0xFF1DA1F2),
              fontWeight: FontWeight.w500,
            ),
          ),
        );
      }

      lastMatchEnd = match.end;
    }

    // Add remaining text
    if (lastMatchEnd < text.length) {
      spans.add(TextSpan(text: text.substring(lastMatchEnd), style: style));
    }

    return TextSpan(children: spans);
  }
}
