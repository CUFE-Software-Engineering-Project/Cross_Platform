import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lite_x/core/classes/PickedImage.dart';
import 'package:lite_x/features/home/models/tweet_model.dart';
import 'package:lite_x/features/home/view_model/home_view_model.dart';
import 'package:lite_x/features/media/upload_media.dart';

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
  final List<File> _selectedImages = [];

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
      final mediaIds = await _uploadSelectedImages();
      await ref
          .read(homeViewModelProvider.notifier)
          .createPost(
            content: _textController.text.trim(),
            replyToId: widget.replyingToTweet.id,
            replyControl: "EVERYONE",
            mediaIds: mediaIds,
          );

      if (mounted) {
        setState(() {
          _selectedImages.clear();
          _textController.clear();
        });
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

  Future<List<String>> _uploadSelectedImages() async {
    if (_selectedImages.isEmpty) return [];
    final uploadedIds = await upload_media(_selectedImages);
    final mediaIds = uploadedIds.where((id) => id.isNotEmpty).toList();

    if (mediaIds.length != _selectedImages.length && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Some images failed to upload. Try again.'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.orange,
        ),
      );
    }

    if (mediaIds.isEmpty) {
      throw Exception('Unable to upload selected images.');
    }
    return mediaIds;
  }

  Future<void> _pickImage() async {
    if (_selectedImages.length >= 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Maximum 4 images allowed per reply.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    final picked = await pickImage();
    if (picked?.file != null) {
      setState(() {
        _selectedImages.add(picked!.file!);
      });
    }
  }

  void _removeImage(int index) {
    if (index < 0 || index >= _selectedImages.length) return;
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  Widget _buildSelectedImagesPreview() {
    if (_selectedImages.isEmpty) return const SizedBox.shrink();
    final crossAxisCount = _selectedImages.length == 1 ? 1 : 2;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${_selectedImages.length} / 4 photos',
          style: TextStyle(color: Colors.grey[500], fontSize: 13),
        ),
        const SizedBox(height: 8),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: _selectedImages.length == 1 ? 16 / 9 : 1.0,
          ),
          itemCount: _selectedImages.length,
          itemBuilder: (context, index) {
            return Stack(
              children: [
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      _selectedImages[index],
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: InkWell(
                    onTap: () => _removeImage(index),
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.black54,
                        shape: BoxShape.circle,
                      ),
                      padding: const EdgeInsets.all(4),
                      child: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
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
                  if (_selectedImages.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    _buildSelectedImagesPreview(),
                  ],
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
            _buildIconButton(Icons.image_outlined, onTap: _pickImage),
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

  Widget _buildIconButton(IconData icon, {VoidCallback? onTap}) {
    return InkWell(
      onTap: _isPosting ? null : onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Icon(icon, color: Colors.blue, size: 22),
      ),
    );
  }
}
