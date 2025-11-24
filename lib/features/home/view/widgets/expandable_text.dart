import 'package:flutter/material.dart';

class ExpandableText extends StatefulWidget {
  final String text;
  final int maxLines;
  final TextStyle? style;
  final TextDirection? textDirection;
  final VoidCallback? onReadMore;

  const ExpandableText({
    super.key,
    required this.text,
    this.maxLines = 3,
    this.style,
    this.textDirection,
    this.onReadMore,
  });

  @override
  State<ExpandableText> createState() => _ExpandableTextState();
}

class _ExpandableTextState extends State<ExpandableText> {
  bool _isExpanded = false;
  bool _showReadMore = false;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final textPainter = TextPainter(
          text: TextSpan(
            text: widget.text,
            style:
                widget.style ??
                const TextStyle(color: Colors.white, fontSize: 15, height: 1.4),
          ),
          maxLines: widget.maxLines,
          textDirection: widget.textDirection ?? TextDirection.ltr,
        );

        textPainter.layout(maxWidth: constraints.maxWidth);

        // Check if text overflows
        _showReadMore = textPainter.didExceedMaxLines;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.text,
              style:
                  widget.style ??
                  const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    height: 1.4,
                  ),
              textDirection: widget.textDirection,
              maxLines: _isExpanded ? null : widget.maxLines,
              overflow: _isExpanded ? null : TextOverflow.ellipsis,
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
