import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lite_x/core/classes/PickedImage.dart';
import 'package:lite_x/core/providers/current_user_provider.dart';
import 'package:lite_x/features/home/models/tweet_model.dart';
import 'package:lite_x/features/home/view_model/home_view_model.dart';
import 'package:lite_x/features/media/upload_media.dart';
import 'package:lite_x/features/home/providers/user_profile_provider.dart';

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

  String? _getPhotoUrl(String? photo) {
    if (photo == null || photo.isEmpty) return null;
    if (photo.startsWith('http://') || photo.startsWith('https://')) {
      return photo;
    }
    return 'https://litex.siematworld.online/media/$photo';
  }

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
    final remainingSlots = 4 - _selectedImages.length;
    if (remainingSlots <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Maximum 4 images allowed per reply.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final pickedList = await pickImages(maxImages: remainingSlots);
    if (pickedList.isEmpty) return;

    setState(() {
      for (final picked in pickedList) {
        if (picked.file != null) {
          _selectedImages.add(picked.file!);
        }
      }
    });
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
    final user = ref.watch(currentUserProvider);
    final profileState = ref.watch(userProfileProvider);

    // Use profile photo from API if available, otherwise fall back to user photo
    String? userPhotoUrl;
    profileState.when(
      data: (profile) {
        userPhotoUrl = profile?.profilePhotoUrl ?? _getPhotoUrl(user?.photo);
        print('🖼️ Reply Composer - Photo URL: $userPhotoUrl');
      },
      loading: () {
        userPhotoUrl = _getPhotoUrl(user?.photo);
      },
      error: (_, __) {
        userPhotoUrl = _getPhotoUrl(user?.photo);
      },
    );

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 12),
                    _buildReplyingToTweet(),
                    const SizedBox(height: 8),
                    _buildReplyComposer(userPhotoUrl),
                    if (_selectedImages.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Padding(
                        padding: const EdgeInsets.only(left: 52),
                        child: _buildSelectedImagesPreview(),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
          _buildBottomBar(),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    final canReply = _textController.text.trim().isNotEmpty && !_isPosting;

    return AppBar(
      backgroundColor: Colors.black,
      elevation: 0,
      leading: TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text(
          'Cancel',
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
      ),
      leadingWidth: 80,
      actions: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ElevatedButton(
            onPressed: canReply ? _postReply : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: canReply
                  ? const Color(0xFF1D9BF0)
                  : const Color(0xFF1D9BF0).withOpacity(0.5),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              elevation: 0,
              minimumSize: const Size(60, 32),
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
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildReplyingToTweet() {
    final authorPhotoUrl = _getPhotoUrl(widget.replyingToTweet.authorAvatar);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: Colors.grey[800],
              backgroundImage: authorPhotoUrl != null
                  ? NetworkImage(authorPhotoUrl)
                  : null,
              child: authorPhotoUrl == null
                  ? Icon(Icons.person, color: Colors.grey[600], size: 24)
                  : null,
            ),
            Container(
              width: 2,
              height: 48,
              margin: const EdgeInsets.symmetric(vertical: 2),
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
                  Flexible(
                    child: Text(
                      widget.replyingToTweet.authorName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      widget.replyingToTweet.authorUsername,
                      style: TextStyle(color: Colors.grey[500], fontSize: 15),
                      overflow: TextOverflow.ellipsis,
                    ),
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
                maxLines: 5,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              RichText(
                text: TextSpan(
                  style: TextStyle(color: Colors.grey[500], fontSize: 15),
                  children: [
                    const TextSpan(text: 'Replying to '),
                    TextSpan(
                      text: widget.replyingToTweet.authorUsername,
                      style: const TextStyle(color: Color(0xFF1D9BF0)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildReplyComposer(String? userPhotoUrl) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 20,
          backgroundColor: Colors.grey[800],
          backgroundImage: userPhotoUrl != null
              ? NetworkImage(userPhotoUrl)
              : null,
          child: userPhotoUrl == null
              ? Icon(Icons.person, color: Colors.grey[600], size: 24)
              : null,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: TextField(
            controller: _textController,
            focusNode: _focusNode,
            maxLines: null,
            minLines: 3,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              height: 1.4,
            ),
            decoration: InputDecoration(
              hintText: 'Post your reply',
              hintStyle: TextStyle(color: Colors.grey[600], fontSize: 20),
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
              isDense: true,
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
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.grey[900]!, width: 0.5)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(
                  Icons.image_outlined,
                  color: Color(0xFF1D9BF0),
                ),
                onPressed: _isPosting ? null : _pickImage,
                iconSize: 20,
                padding: const EdgeInsets.all(8),
                constraints: const BoxConstraints(),
              ),
              IconButton(
                icon: const Icon(
                  Icons.gif_box_outlined,
                  color: Color(0xFF1D9BF0),
                ),
                onPressed: _isPosting ? null : () {},
                iconSize: 20,
                padding: const EdgeInsets.all(8),
                constraints: const BoxConstraints(),
              ),
              IconButton(
                icon: const Icon(Icons.poll_outlined, color: Color(0xFF1D9BF0)),
                onPressed: _isPosting ? null : () {},
                iconSize: 20,
                padding: const EdgeInsets.all(8),
                constraints: const BoxConstraints(),
              ),
              IconButton(
                icon: const Icon(
                  Icons.emoji_emotions_outlined,
                  color: Color(0xFF1D9BF0),
                ),
                onPressed: _isPosting ? null : () {},
                iconSize: 20,
                padding: const EdgeInsets.all(8),
                constraints: const BoxConstraints(),
              ),
              IconButton(
                icon: const Icon(
                  Icons.calendar_today_outlined,
                  color: Color(0xFF1D9BF0),
                ),
                onPressed: _isPosting ? null : () {},
                iconSize: 20,
                padding: const EdgeInsets.all(8),
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
