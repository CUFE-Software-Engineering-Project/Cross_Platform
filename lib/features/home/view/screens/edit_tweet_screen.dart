import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lite_x/features/home/models/tweet_model.dart';
import 'package:lite_x/features/home/repositories/home_repository.dart';
import 'package:lite_x/features/media/download_media.dart';
import 'package:lite_x/features/media/upload_media.dart';

class EditTweetScreen extends ConsumerStatefulWidget {
  final TweetModel tweet;

  const EditTweetScreen({super.key, required this.tweet});

  @override
  ConsumerState<EditTweetScreen> createState() => _EditTweetScreenState();
}

class _EditTweetScreenState extends ConsumerState<EditTweetScreen> {
  late TextEditingController _textController;
  final FocusNode _focusNode = FocusNode();
  bool _isUpdating = false;

  // Track existing media URLs from the tweet
  List<String> _existingMediaUrls = [];

  // Track existing media IDs (the backend expects IDs, not resolved URLs)
  List<String> _existingMediaIds = [];

  bool _existingMediaModified = false;

  // Track new media files to be uploaded
  List<File> _newMediaFiles = [];

  String _selectedReplyControl = 'EVERYONE';

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.tweet.content);
    _existingMediaUrls = List.from(widget.tweet.images);
    _selectedReplyControl = widget.tweet.replyControl;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
      _loadExistingMediaIds();
    });
  }

  Future<void> _loadExistingMediaIds() async {
    if (widget.tweet.id.isEmpty) return;
    try {
      final repository = ref.read(homeRepositoryProvider);
      final ids = await repository.getTweetMediaIds(widget.tweet.id);
      final urls = ids.isNotEmpty ? await getMediaUrls(ids) : const <String>[];
      if (!mounted) return;
      setState(() {
        _existingMediaIds = ids;
        if (urls.isNotEmpty) {
          _existingMediaUrls = urls;
        }
      });
    } catch (_) {
      // Ignore: we'll fall back to whatever we have when saving.
    }
  }

  Future<void> _ensureExistingMediaIdsLoaded() async {
    if (_existingMediaIds.isNotEmpty) return;
    if (widget.tweet.images.isEmpty) return;
    await _loadExistingMediaIds();
  }

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    try {
      final ImagePicker picker = ImagePicker();
      final List<XFile> images = await picker.pickMultiImage();

      if (images.isNotEmpty) {
        setState(() {
          _newMediaFiles.addAll(images.map((xfile) => File(xfile.path)));
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to pick images: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _removeExistingMedia(int index) {
    // Per requirement: removing media while editing should NOT delete media
    // from backend; it should only exclude its ID from the update payload.
    setState(() {
      _existingMediaModified = true;
      if (index >= 0 && index < _existingMediaUrls.length) {
        _existingMediaUrls.removeAt(index);
      }
      if (index >= 0 && index < _existingMediaIds.length) {
        _existingMediaIds.removeAt(index);
      }
    });
  }

  void _removeNewMedia(int index) {
    setState(() {
      _newMediaFiles.removeAt(index);
    });
  }

  // Extract media IDs from URLs
  List<String> _extractMediaIdsFromUrls(List<String> urls) {
    return urls
        .map((url) {
          var value = url.trim();
          if (value.isEmpty) return '';

          // Strip query/fragment first (common for signed URLs)
          value = value.split('?').first.split('#').first;

          // Extract ID from common URL patterns.
          // Examples:
          // - https://.../media/{id}
          // - https://.../media/download/{id}
          // - https://.../media/tweet-media/{id}
          final marker = '/media/';
          if (value.contains(marker)) {
            value = value.split(marker).last;
          }

          // If path still contains segments, keep the last segment.
          if (value.contains('/')) {
            value = value.split('/').last;
          }

          // At this point `value` might be:
          // - a raw UUID
          // - a UUID with extension (uuid.jpg)
          // - a generated filename like: <uuid>-<timestamp>-<name>.jpg
          final uuidMatch = RegExp(
            r'[0-9a-fA-F]{8}-'
            r'[0-9a-fA-F]{4}-'
            r'[0-9a-fA-F]{4}-'
            r'[0-9a-fA-F]{4}-'
            r'[0-9a-fA-F]{12}',
          ).firstMatch(value);
          if (uuidMatch != null) {
            return uuidMatch.group(0) ?? '';
          }

          // If we couldn't find a UUID, treat as unknown token.
          // For edits we should not send random filenames; we fetch IDs from
          // `api/media/tweet-media/{tweetId}` instead.
          return '';
        })
        .where((id) => id.isNotEmpty)
        .toList();
  }

  Future<void> _updateTweet() async {
    final content = _textController.text.trim();

    if (content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tweet content cannot be empty'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isUpdating = true;
    });

    try {
      final repository = ref.read(homeRepositoryProvider);

      // Important: existing tweet media might be represented as resolved URLs
      // for display, so we must fetch the real IDs to avoid accidentally
      // dropping them when adding new media.
      await _ensureExistingMediaIdsLoaded();

      // Upload new media files if any
      List<String> newMediaIds = [];
      if (_newMediaFiles.isNotEmpty) {
        final uploadedMedia = await upload_media(_newMediaFiles);
        newMediaIds = uploadedMedia;
      }

      // `upload_media` returns "" for failed uploads. Filter those out and
      // avoid sending invalid IDs to the backend.
      final normalizedNewMediaIds = _extractMediaIdsFromUrls(newMediaIds);

      // Match the behavior used when creating tweets/replies:
      // - warn if some uploads failed
      // - fail only if all selected uploads failed
      if (_newMediaFiles.isNotEmpty && mounted) {
        if (normalizedNewMediaIds.length != _newMediaFiles.length) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Some media files failed to upload. Try again.'),
              behavior: SnackBarBehavior.floating,
              backgroundColor: Colors.orange,
            ),
          );
        }
      }

      if (_newMediaFiles.isNotEmpty && normalizedNewMediaIds.isEmpty) {
        throw Exception('Unable to upload selected media.');
      }

      // Keep the original tweet media IDs (do not delete existing media on edit)
      // Prefer fetched IDs (reliable), fall back to whatever we already have.
      final existingMediaIds = _existingMediaIds.isNotEmpty
          ? _existingMediaIds
          : _extractMediaIdsFromUrls(widget.tweet.images);

      // Combine existing media IDs with new ones
      final allMediaIds = <String>{
        ...existingMediaIds,
        ...normalizedNewMediaIds,
      }.toList();

      // Prepare update data
      final shouldSendTweetMedia =
          widget.tweet.images.isNotEmpty ||
          _newMediaFiles.isNotEmpty ||
          _existingMediaModified;

      final updateData = {
        'content': content,
        'replyControl': _selectedReplyControl,
        // Send only the currently wanted IDs.
        // If the user removed everything, we send an empty list to clear media
        // association for this tweet (media itself is not deleted).
        if (shouldSendTweetMedia) 'tweetMedia': allMediaIds,
      };

      print('🔄 Updating tweet with data: $updateData');

      // Update the tweet
      final updatedTweet = await repository.updateTweet(
        widget.tweet.id,
        updateData,
        mediaIds: allMediaIds,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tweet updated successfully'),
            backgroundColor: Colors.green,
          ),
        );

        // Return the updated tweet
        Navigator.of(context).pop(updatedTweet);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update tweet: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUpdating = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalMediaCount = _existingMediaUrls.length + _newMediaFiles.length;
    final canAddMore = totalMediaCount < 4;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Edit Tweet',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: ElevatedButton(
              onPressed: _isUpdating ? null : _updateTweet,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1DA1F2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20),
              ),
              child: _isUpdating
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text(
                      'Save',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Text field
              TextField(
                controller: _textController,
                focusNode: _focusNode,
                maxLines: null,
                maxLength: 280,
                style: const TextStyle(color: Colors.white, fontSize: 18),
                decoration: InputDecoration(
                  hintText: 'What\'s happening?',
                  hintStyle: TextStyle(color: Colors.grey[600]),
                  border: InputBorder.none,
                  counterStyle: TextStyle(color: Colors.grey[600]),
                ),
              ),

              const SizedBox(height: 16),

              // Media grid (existing + new)
              if (totalMediaCount > 0) ...[
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: totalMediaCount == 1 ? 1 : 2,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                    childAspectRatio: 16 / 9,
                  ),
                  itemCount: totalMediaCount,
                  itemBuilder: (context, index) {
                    // Show existing media first
                    if (index < _existingMediaUrls.length) {
                      final url = _existingMediaUrls[index];
                      return Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              url,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: Colors.grey[800],
                                  child: Icon(
                                    Icons.broken_image,
                                    color: Colors.grey[600],
                                    size: 48,
                                  ),
                                );
                              },
                            ),
                          ),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: GestureDetector(
                              onTap: () => _removeExistingMedia(index),
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: Colors.black54,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.close,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    }

                    // Show new media
                    final newMediaIndex = index - _existingMediaUrls.length;
                    final file = _newMediaFiles[newMediaIndex];
                    return Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            file,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                          ),
                        ),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: GestureDetector(
                            onTap: () => _removeNewMedia(newMediaIndex),
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Colors.black54,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 16),
              ],

              // Reply control dropdown
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: DropdownButton<String>(
                  value: _selectedReplyControl,
                  isExpanded: true,
                  underline: const SizedBox(),
                  dropdownColor: Colors.grey[900],
                  style: const TextStyle(color: Colors.white),
                  items: const [
                    DropdownMenuItem(
                      value: 'EVERYONE',
                      child: Row(
                        children: [
                          Icon(
                            Icons.public,
                            color: Color(0xFF1DA1F2),
                            size: 20,
                          ),
                          SizedBox(width: 8),
                          Text('Everyone can reply'),
                        ],
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'FOLLOWINGS',
                      child: Row(
                        children: [
                          Icon(
                            Icons.people,
                            color: Color(0xFF1DA1F2),
                            size: 20,
                          ),
                          SizedBox(width: 8),
                          Text('People you follow'),
                        ],
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'MENTIONED',
                      child: Row(
                        children: [
                          Icon(
                            Icons.alternate_email,
                            color: Color(0xFF1DA1F2),
                            size: 20,
                          ),
                          SizedBox(width: 8),
                          Text('Only mentioned users'),
                        ],
                      ),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedReplyControl = value;
                      });
                    }
                  },
                ),
              ),

              const SizedBox(height: 16),

              // Add media button
              if (canAddMore)
                OutlinedButton.icon(
                  onPressed: _pickImages,
                  icon: const Icon(Icons.image, color: Color(0xFF1DA1F2)),
                  label: const Text(
                    'Add photos',
                    style: TextStyle(color: Color(0xFF1DA1F2)),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF1DA1F2)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
