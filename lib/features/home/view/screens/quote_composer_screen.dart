import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lite_x/core/classes/PickedImage.dart';
import 'package:lite_x/features/home/models/tweet_model.dart';
import 'package:lite_x/features/home/view/widgets/media_gallery.dart';
import 'package:lite_x/features/home/view_model/home_view_model.dart';
import 'package:lite_x/features/media/upload_media.dart';
import 'package:lite_x/core/providers/current_user_provider.dart';
import 'package:lite_x/features/home/providers/user_profile_provider.dart';

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

  Future<void> _postQuote() async {
    if (_textController.text.trim().isEmpty) return;

    setState(() {
      _isPosting = true;
    });

    try {
      final mediaIds = await _uploadSelectedImages();
      await ref
          .read(homeViewModelProvider.notifier)
          .createQuoteTweet(
            content: _textController.text.trim(),
            quotedTweetId: widget.quotedTweet.id,
            quotedTweet: widget.quotedTweet,
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

  Future<List<String>> _uploadSelectedImages() async {
    if (_selectedImages.isEmpty) return [];
    final uploadedIds = await upload_media(_selectedImages);
    final mediaIds = uploadedIds.where((id) => id.isNotEmpty).toList();

    if (mediaIds.length != _selectedImages.length && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Some images failed to upload. Try again.'),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
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
          content: Text('Maximum 4 images allowed per quote.'),
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

    return GridView.builder(
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
                child: Image.file(_selectedImages[index], fit: BoxFit.cover),
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
                  child: const Icon(Icons.close, color: Colors.white, size: 16),
                ),
              ),
            ),
          ],
        );
      },
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
    final user = ref.watch(currentUserProvider);
    final profileState = ref.watch(userProfileProvider);

    // Use profile photo from API if available, otherwise fall back to user photo
    String? userPhotoUrl;
    profileState.when(
      data: (profile) {
        userPhotoUrl = profile?.profilePhotoUrl ?? _getPhotoUrl(user?.photo);
        print('🖼️ Quote Composer - Photo URL: $userPhotoUrl');
      },
      loading: () {
        userPhotoUrl = _getPhotoUrl(user?.photo);
      },
      error: (_, __) {
        userPhotoUrl = _getPhotoUrl(user?.photo);
      },
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: Colors.grey[700],
              backgroundImage: userPhotoUrl != null
                  ? NetworkImage(userPhotoUrl!)
                  : null,
              child: userPhotoUrl == null
                  ? const Icon(Icons.person, color: Colors.white, size: 24)
                  : null,
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
                  setState(() {});
                },
              ),
            ),
          ],
        ),
        if (_selectedImages.isNotEmpty) ...[
          const SizedBox(height: 12),
          _buildSelectedImagesPreview(),
        ],
        const SizedBox(height: 12),
        Row(
          children: [
            IconButton(
              onPressed: _isPosting ? null : _pickImage,
              icon: const Icon(Icons.image_outlined, color: Colors.blue),
            ),
            const SizedBox(width: 4),
            Text(
              '${_selectedImages.length} / 4 photos',
              style: TextStyle(color: Colors.grey[500], fontSize: 13),
            ),
          ],
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
          Text(
            widget.quotedTweet.content,
            style: const TextStyle(color: Colors.white, fontSize: 15),
            maxLines: 5,
            overflow: TextOverflow.ellipsis,
          ),
          if (widget.quotedTweet.images.isNotEmpty) ...[
            const SizedBox(height: 8),
            MediaGallery(
              urls: widget.quotedTweet.images,
              borderRadius: 8,
              minHeight: 100,
              maxHeight: 160,
            ),
          ],
        ],
      ),
    );
  }
}
