import 'package:flutter/material.dart';
import '../../utils/text_with_hashtags.dart';

class ExpandableText extends StatefulWidget {
  final String text;
  final int maxLines;
  final TextStyle? style;
  final TextDirection? textDirection;
  final VoidCallback? onReadMore;
  final Function(String)? onHashtagTap;
  final Function(String)? onMentionTap;
  final List<String>? knownHashtags;

  const ExpandableText({
    super.key,
    required this.text,
    this.maxLines = 3,
    this.style,
    this.textDirection,
    this.onReadMore,
    this.onHashtagTap,
    this.onMentionTap,
    this.knownHashtags,
  });

  @override
  State<ExpandableText> createState() => _ExpandableTextState();
}

class _ExpandableTextState extends State<ExpandableText> {
  bool _isExpanded = false;
  bool _showReadMore = false;
  TextSpan? _cachedTextSpan;
  String? _cachedText;

  TextSpan _buildTextSpan(TextStyle defaultStyle) {
    // Cache the text span to avoid rebuilding on every frame
    if (_cachedText != widget.text || _cachedTextSpan == null) {
      _cachedText = widget.text;
      _cachedTextSpan = TextWithHashtags.buildTextSpan(
        text: widget.text,
        style: defaultStyle,
        onHashtagTap: widget.onHashtagTap,
        onMentionTap: widget.onMentionTap,
        knownHashtags: widget.knownHashtags,
      );
    }
    return _cachedTextSpan!;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final defaultStyle =
            widget.style ??
            const TextStyle(color: Colors.white, fontSize: 15, height: 1.4);

        final textSpan = _buildTextSpan(defaultStyle);

        final textPainter = TextPainter(
          text: textSpan,
          maxLines: widget.maxLines,
          textDirection: widget.textDirection ?? TextDirection.ltr,
        );

        textPainter.layout(maxWidth: constraints.maxWidth);

        // Check if text overflows
        final showReadMore = textPainter.didExceedMaxLines;
        if (_showReadMore != showReadMore) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              setState(() {
                _showReadMore = showReadMore;
              });
            }
          });
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RichText(
              text: textSpan,
              textDirection: widget.textDirection,
              maxLines: _isExpanded ? null : widget.maxLines,
              overflow: _isExpanded
                  ? TextOverflow.visible
                  : TextOverflow.ellipsis,
            ),
            if (_showReadMore)
              GestureDetector(
                onTap: () {
                  if (widget.onReadMore != null) {
                    widget.onReadMore!();
                  } else {
                    setState(() {
                      _isExpanded = !_isExpanded;
                    });
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    _isExpanded ? 'Show less' : 'Read more',
                    style: const TextStyle(
                      color: Color(0xFF1DA1F2),
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
