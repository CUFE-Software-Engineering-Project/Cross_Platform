import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lite_x/features/home/models/tweet_model.dart';
import 'package:lite_x/features/home/view_model/home_view_model.dart';

class ReplyComposerScreen extends ConsumerStatefulWidget {
  final TweetModel replyingToTweet;

  const ReplyComposerScreen({super.key, required this.replyingToTweet});

  @override
  ConsumerState<ReplyComposerScreen> createState() =>
      _ReplyComposerScreenState();
}

class _ReplyComposerScreenState extends ConsumerState<ReplyComposerScreen> {
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _isPosting = false;

  @override
  void initState() {
    super.initState();
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

  Future<void> _postReply() async {
    if (_textController.text.trim().isEmpty) return;

    setState(() {
      _isPosting = true;
    });

    try {
      await ref
          .read(homeViewModelProvider.notifier)
          .createPost(
            content: _textController.text.trim(),
            replyToId: widget.replyingToTweet.id,
            replyControl: "EVERYONE",
          );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Reply posted successfully'),
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
            content: Text('Failed to post reply: $e'),
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
                  _buildReplyingToTweet(),
                  const SizedBox(height: 16),
                  _buildReplyComposer(),
                ],
              ),
            ),
          ),
          _buildBottomBar(),
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
                : _postReply,
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
                    'Reply',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildReplyingToTweet() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundImage: NetworkImage(
                widget.replyingToTweet.authorAvatar,
              ),
              backgroundColor: Colors.grey[800],
            ),
            Container(
              width: 2,
              height: 40,
              margin: const EdgeInsets.symmetric(vertical: 4),
              color: Colors.grey[800],
            ),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    widget.replyingToTweet.authorName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    widget.replyingToTweet.authorUsername,
                    style: TextStyle(color: Colors.grey[600], fontSize: 15),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                widget.replyingToTweet.content,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  height: 1.4,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text(
                    'Replying to ',
                    style: TextStyle(color: Colors.grey[600], fontSize: 15),
                  ),
                  Text(
                    widget.replyingToTweet.authorUsername,
                    style: const TextStyle(color: Colors.blue, fontSize: 15),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildReplyComposer() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 20,
          backgroundColor: Colors.blue,
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
              hintText: 'Post your reply',
              hintStyle: TextStyle(color: Colors.grey[600], fontSize: 18),
              border: InputBorder.none,
            ),
            onChanged: (text) {
              setState(() {}); // Update button state
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.black,
        border: Border(top: BorderSide(color: Colors.grey[900]!, width: 0.5)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            _buildIconButton(Icons.image_outlined),
            const SizedBox(width: 16),
            _buildIconButton(Icons.gif_box_outlined),
            const SizedBox(width: 16),
            _buildIconButton(Icons.poll_outlined),
            const SizedBox(width: 16),
            _buildIconButton(Icons.emoji_emotions_outlined),
            const SizedBox(width: 16),
            _buildIconButton(Icons.calendar_today_outlined),
            const SizedBox(width: 16),
            _buildIconButton(Icons.location_on_outlined),
          ],
        ),
      ),
    );
  }

  Widget _buildIconButton(IconData icon) {
    return InkWell(
      onTap: () {
      },
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Icon(icon, color: Colors.blue, size: 22),
      ),
    );
  }
}