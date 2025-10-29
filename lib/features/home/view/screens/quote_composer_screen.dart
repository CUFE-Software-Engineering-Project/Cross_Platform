import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lite_x/features/home/models/tweet_model.dart';
import 'package:lite_x/features/home/view_model/home_view_model.dart';

class QuoteComposerScreen extends ConsumerStatefulWidget {
  final TweetModel quotedTweet;

  const QuoteComposerScreen({super.key, required this.quotedTweet});

  @override
  ConsumerState<QuoteComposerScreen> createState() =>
      _QuoteComposerScreenState();
}

class _QuoteComposerScreenState extends ConsumerState<QuoteComposerScreen> {
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _isPosting = false;

  @override
  void initState() {
    super.initState();
    // Auto-focus the text field
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _postQuote() async {
    if (_textController.text.trim().isEmpty) return;

    setState(() {
      _isPosting = true;
    });

    try {
      // Create quote tweet via view model
      await ref
          .read(homeViewModelProvider.notifier)
          .createQuoteTweet(
            content: _textController.text.trim(),
            quotedTweetId: widget.quotedTweet.id,
            quotedTweet: widget.quotedTweet,
            replyControl: "EVERYONE",
          );

      if (mounted) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Quote posted successfully'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 2),
          ),
        );
        Navigator.pop(context, true); // Return success
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to post quote: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
        setState(() {
          _isPosting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildQuoteComposer(),
                  const SizedBox(height: 16),
                  _buildQuotedTweet(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.black,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.close, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ElevatedButton(
            onPressed: _textController.text.trim().isEmpty || _isPosting
                ? null
                : _postQuote,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              disabledBackgroundColor: Colors.blue.withOpacity(0.5),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              elevation: 0,
            ),
            child: _isPosting
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text(
                    'Post',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuoteComposer() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Current user avatar
        CircleAvatar(
          radius: 20,
          backgroundColor: Colors.grey[700],
          child: const Icon(Icons.person, color: Colors.white, size: 24),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: TextField(
            controller: _textController,
            focusNode: _focusNode,
            maxLines: null,
            style: const TextStyle(color: Colors.white, fontSize: 18),
            decoration: InputDecoration(
              hintText: 'Add a comment...',
              hintStyle: TextStyle(color: Colors.grey[600], fontSize: 18),
              border: InputBorder.none,
            ),
            onChanged: (value) {
              setState(() {}); // Rebuild to enable/disable post button
            },
          ),
        ),
      ],
    );
  }

  Widget _buildQuotedTweet() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[800]!, width: 1),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Quoted tweet author
          Row(
            children: [
              CircleAvatar(
                radius: 12,
                backgroundImage: NetworkImage(widget.quotedTweet.authorAvatar),
                backgroundColor: Colors.grey[800],
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Row(
                  children: [
                    Flexible(
                      child: Text(
                        widget.quotedTweet.authorName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        '@${widget.quotedTweet.authorUsername}',
                        style: TextStyle(color: Colors.grey[500], fontSize: 14),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Quoted tweet content
          Text(
            widget.quotedTweet.content,
            style: const TextStyle(color: Colors.white, fontSize: 15),
            maxLines: 5,
            overflow: TextOverflow.ellipsis,
          ),
          if (widget.quotedTweet.images.isNotEmpty) ...[
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                widget.quotedTweet.images.first,
                width: double.infinity,
                height: 100,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 100,
                    color: Colors.grey[900],
                    child: const Center(
                      child: Icon(Icons.broken_image, color: Colors.grey),
                    ),
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }
}
