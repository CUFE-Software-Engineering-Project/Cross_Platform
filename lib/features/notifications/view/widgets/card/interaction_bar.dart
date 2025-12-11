import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:lite_x/core/theme/palette.dart';
import 'package:lite_x/core/providers/dio_interceptor.dart';
import 'package:lite_x/features/home/repositories/home_repository.dart';
import 'package:lite_x/features/home/view/screens/quote_composer_screen.dart';

class InteractionBar extends ConsumerStatefulWidget {
  final String tweetId;
  final int repliesCount;
  final int retweetCount;
  final int likesCount;
  final int quotesCount;
  final bool isLiked;
  final bool isRetweeted;
  final VoidCallback? onUpdate;

  const InteractionBar({
    super.key,
    required this.tweetId,
    this.repliesCount = 0,
    this.retweetCount = 0,
    this.likesCount = 0,
    this.quotesCount = 0,
    this.isLiked = false,
    this.isRetweeted = false,
    this.onUpdate,
  });

  @override
  ConsumerState<InteractionBar> createState() => _InteractionBarState();
}

class _InteractionBarState extends ConsumerState<InteractionBar> {
  bool _liked = false;
  bool _retweeted = false;
  int _likesCount = 0;
  int _retweetsCount = 0;
  bool _handlingQuote = false;

  @override
  void initState() {
    super.initState();
    _liked = widget.isLiked;
    _retweeted = widget.isRetweeted;
    _likesCount = widget.likesCount;
    _retweetsCount = widget.retweetCount;
  }

  @override
  void didUpdateWidget(InteractionBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isLiked != widget.isLiked) {
      _liked = widget.isLiked;
    }
    if (oldWidget.isRetweeted != widget.isRetweeted) {
      _retweeted = widget.isRetweeted;
    }
    if (oldWidget.likesCount != widget.likesCount) {
      _likesCount = widget.likesCount;
    }
    if (oldWidget.retweetCount != widget.retweetCount) {
      _retweetsCount = widget.retweetCount;
    }
  }

  Future<void> _toggleLike() async {
    final dio = ref.read(dioProvider);
    final wasLiked = _liked;
    final oldCount = _likesCount;

    // Optimistic update
    setState(() {
      _liked = !_liked;
      _likesCount += _liked ? 1 : -1;
    });

    try {
      if (wasLiked) {
        await dio.delete('/api/tweets/${widget.tweetId}/likes');
      } else {
        await dio.post('/api/tweets/${widget.tweetId}/likes');
      }
      // Callback to refresh parent if provided
      widget.onUpdate?.call();
    } catch (e) {
      // Revert on error
      if (mounted) {
        setState(() {
          _liked = wasLiked;
          _likesCount = oldCount;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to ${wasLiked ? 'unlike' : 'like'} tweet'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _toggleRetweet() async {
    final dio = ref.read(dioProvider);
    final wasRetweeted = _retweeted;
    final oldCount = _retweetsCount;

    // Optimistic update
    setState(() {
      _retweeted = !_retweeted;
      _retweetsCount += _retweeted ? 1 : -1;
    });

    try {
      if (wasRetweeted) {
        await dio.delete('/api/tweets/${widget.tweetId}/retweets');
      } else {
        await dio.post('/api/tweets/${widget.tweetId}/retweets');
      }
      // Callback to refresh parent if provided
      widget.onUpdate?.call();
    } catch (e) {
      // Revert on error
      if (mounted) {
        setState(() {
          _retweeted = wasRetweeted;
          _retweetsCount = oldCount;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to ${wasRetweeted ? 'unretweet' : 'retweet'}',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _handleReply() {
    // TODO: Navigate to reply screen or show reply dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Reply functionality coming soon')),
    );
  }

  Future<void> _handleQuote() async {
    if (_handlingQuote) return;
    _handlingQuote = true;

    try {
      final repository = ref.read(homeRepositoryProvider);
      final tweet = await repository.getTweetById(widget.tweetId);

      if (!mounted) return;
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => QuoteComposerScreen(quotedTweet: tweet),
        ),
      );
      widget.onUpdate?.call();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to open quote composer'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      _handlingQuote = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildButton(
          Icons.reply,
          widget.repliesCount,
          Palette.reply,
          _handleReply,
        ),
        _buildButton(
          Icons.repeat,
          _retweetsCount,
          _retweeted ? Palette.retweet : Palette.reply,
          _toggleRetweet,
        ),
        _buildButton(
          Icons.favorite,
          _likesCount,
          _liked ? Palette.like : Palette.reply,
          _toggleLike,
        ),
        _buildButton(
          Icons.format_quote,
          widget.quotesCount,
          Palette.reply,
          _handleQuote,
        ),
      ],
    );
  }

  Widget _buildButton(
    IconData icon,
    int count,
    Color color,
    VoidCallback onTap,
  ) {
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
