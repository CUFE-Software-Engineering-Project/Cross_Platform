import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lite_x/core/classes/PickedImage.dart';
import 'package:lite_x/features/home/view_model/home_view_model.dart';
import 'package:lite_x/features/media/upload_media.dart';

enum PostPrivacy {
  everyone,
  following,
  mentioned;

  String get label {
    switch (this) {
      case PostPrivacy.everyone:
        return 'Everyone can reply';
      case PostPrivacy.following:
        return 'People you follow';
      case PostPrivacy.mentioned:
        return 'Only mentioned users';
    }
  }

  IconData get icon {
    switch (this) {
      case PostPrivacy.everyone:
        return Icons.public;
      case PostPrivacy.following:
        return Icons.people;
      case PostPrivacy.mentioned:
        return Icons.alternate_email;
    }
  }

  String get apiValue {
    switch (this) {
      case PostPrivacy.everyone:
        return 'EVERYONE';
      case PostPrivacy.following:
        return 'FOLLOWING';
      case PostPrivacy.mentioned:
        return 'MENTIONED';
    }
  }
}

class CreatePostScreen extends ConsumerStatefulWidget {
  final String? replyToId;
  final String? replyToUsername;

  const CreatePostScreen({super.key, this.replyToId, this.replyToUsername});

  @override
  ConsumerState<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends ConsumerState<CreatePostScreen> {
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _isPosting = false;
  final List<File> _selectedImages = [];
  PostPrivacy _selectedPrivacy = PostPrivacy.everyone;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
    _textController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _postTweet() async {
    if (_textController.text.trim().isEmpty) return;

    setState(() {
      _isPosting = true;
    });

    try {
      List<String> mediaIds = [];
      if (_selectedImages.isNotEmpty) {
        final uploadedIds = await upload_media(_selectedImages);
        mediaIds = uploadedIds.where((id) => id.isNotEmpty).toList();

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
      }

      await ref
          .read(homeViewModelProvider.notifier)
          .createPost(
            content: _textController.text.trim(),
            replyControl: _selectedPrivacy.apiValue,
            mediaIds: mediaIds,
            replyToId: widget.replyToId,
          );

      if (mounted) {
        setState(() {
          _textController.clear();
          _selectedImages.clear();
        });
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.replyToId != null
                  ? 'Reply posted successfully!'
                  : 'Post created successfully!',
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to post: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isPosting = false;
        });
      }
    }
  }

  Future<void> _pickImage() async {
    if (_selectedImages.length >= 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Maximum 4 images allowed per post.'),
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
    final double aspectRatio = _selectedImages.length == 1 ? 16 / 9 : 1;

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
            childAspectRatio: aspectRatio,
          ),
          itemCount: _selectedImages.length,
          itemBuilder: (context, index) {
            final file = _selectedImages[index];
            return Stack(
              children: [
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(file, fit: BoxFit.cover),
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

  void _showPrivacyOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E1E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[600],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Who can reply?',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Choose who can reply to this post.',
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
            ),
            const SizedBox(height: 16),
            ...PostPrivacy.values.map((privacy) {
              return ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: privacy == _selectedPrivacy
                        ? Colors.blue.withOpacity(0.2)
                        : Colors.grey[800],
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    privacy.icon,
                    color: privacy == _selectedPrivacy
                        ? Colors.blue
                        : Colors.grey,
                    size: 20,
                  ),
                ),
                title: Text(
                  privacy.label,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
                trailing: privacy == _selectedPrivacy
                    ? const Icon(Icons.check_circle, color: Colors.blue)
                    : null,
                onTap: () {
                  setState(() {
                    _selectedPrivacy = privacy;
                  });
                  Navigator.pop(context);
                },
              );
            }).toList(),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final canPost = _textController.text.trim().isNotEmpty && !_isPosting;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
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
              onPressed: canPost ? _postTweet : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                disabledBackgroundColor: Colors.blue.withOpacity(0.5),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
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
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: Colors.blue,
                        child: Text(
                          'V',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: _textController,
                          focusNode: _focusNode,
                          maxLines: null,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                          decoration: InputDecoration(
                            hintText: "What's happening?",
                            hintStyle: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 16,
                            ),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (_selectedImages.isNotEmpty) ...[
                    _buildSelectedImagesPreview(),
                    const SizedBox(height: 16),
                  ],
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: Colors.grey[800]!, width: 1),
              ),
            ),
            child: Row(
              children: [
                InkWell(
                  onTap: _showPrivacyOptions,
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.blue, width: 1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _selectedPrivacy.icon,
                          color: Colors.blue,
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _selectedPrivacy.label,
                          style: const TextStyle(
                            color: Colors.blue,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: Colors.grey[800]!, width: 1),
              ),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.image_outlined, color: Colors.blue),
                  onPressed: _isPosting ? null : _pickImage,
                ),
                IconButton(
                  icon: const Icon(Icons.gif_box_outlined, color: Colors.blue),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('GIF picker - Coming soon!'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.poll_outlined, color: Colors.blue),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Poll creator - Coming soon!'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(
                    Icons.location_on_outlined,
                    color: Colors.blue,
                  ),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Location - Coming soon!'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(
                    Icons.add_circle_outline,
                    color: Colors.blue,
                  ),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('More options - Coming soon!'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
