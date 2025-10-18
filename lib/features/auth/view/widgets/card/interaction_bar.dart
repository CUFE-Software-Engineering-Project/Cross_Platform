import 'package:flutter/material.dart';
import 'package:lite_x/core/theme/palette.dart';

class InteractionBar extends StatefulWidget {
  final int replyCount;
  final int retweetCount;
  final int likeCount;
  final int shareCount;

  const InteractionBar({
    super.key,
    this.replyCount = 0,
    this.retweetCount = 0,
    this.likeCount = 0,
    this.shareCount = 0,
  });

  @override
  State<InteractionBar> createState() => _InteractionBarState();
}

class _InteractionBarState extends State<InteractionBar> {
  bool _replied = false;
  bool _retweeted = false;
  bool _liked = false;

  late int _replyCount;
  late int _retweetCount;
  late int _likeCount;

  @override
  void initState() {
    super.initState();
    _replyCount = widget.replyCount;
    _retweetCount = widget.retweetCount;
    _likeCount = widget.likeCount;
  }

  void _toggleReply() {
    setState(() {
      _replied = !_replied;
      _replied ? _replyCount++ : _replyCount--;
    });
  }

  void _toggleRetweet() {
    setState(() {
      _retweeted = !_retweeted;
      _retweeted ? _retweetCount++ : _retweetCount--;
    });
  }

  void _toggleLike() {
    setState(() {
      _liked = !_liked;
      _liked ? _likeCount++ : _likeCount--;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildButton(Icons.reply, _replyCount, _replied ? Palette.primary : Palette.reply, _toggleReply),
        _buildButton(Icons.repeat, _retweetCount, _retweeted ? Palette.retweet : Palette.reply, _toggleRetweet),
        _buildButton(Icons.favorite, _likeCount, _liked ? Palette.like : Palette.reply, _toggleLike),
        _buildButton(Icons.share, widget.shareCount, Palette.reply, () {}),
      ],
    );
  }

  Widget _buildButton(IconData icon, int count, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 4),
          Text(
            count > 0 ? count.toString() : '',
            style: TextStyle(color: color, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
