import 'dart:io';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lite_x/core/classes/PickedImage.dart';
import 'package:lite_x/core/providers/current_user_provider.dart';
import 'package:lite_x/features/home/models/tweet_model.dart';
import 'package:lite_x/features/home/view_model/home_view_model.dart';
import 'package:lite_x/features/media/upload_media.dart';
import 'package:lite_x/features/home/providers/user_profile_provider.dart';
import 'package:lite_x/features/home/services/hashtag_service.dart';
import 'package:lite_x/features/home/view/widgets/hashtag_suggestions_overlay.dart';
import 'package:lite_x/features/home/view/widgets/mention_suggestion_overlay.dart';
import 'package:lite_x/features/home/models/user_suggestion.dart';

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
        return 'FOLLOWINGS';
      case PostPrivacy.mentioned:
        return 'MENTIONED';
    }
  }
}

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
  final List<File> _selectedMedia = [];
  PostPrivacy _selectedPrivacy = PostPrivacy.everyone;

  // Hashtag suggestions state
  List<HashtagSuggestion> _hashtagSuggestions = [];
  String _currentHashtagQuery = '';
  int _hashtagStartPosition = -1;
  Timer? _debounceTimer;
  final LayerLink _layerLink = LayerLink();

  // Mention suggestions state
  final LayerLink _mentionLayerLink = LayerLink();

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
    _textController.addListener(() {
      _onTextChanged();
      setState(() {});
    });
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
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
            replyControl: _selectedPrivacy.apiValue,
            mediaIds: mediaIds,
          );

      if (mounted) {
        setState(() {
          _selectedMedia.clear();
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
    if (_selectedMedia.isEmpty) return [];
    final uploadedIds = await upload_media(_selectedMedia);
    final mediaIds = uploadedIds.where((id) => id.isNotEmpty).toList();

    if (mediaIds.length != _selectedMedia.length && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Some media files failed to upload. Try again.'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.orange,
        ),
      );
    }

    if (mediaIds.isEmpty) {
      throw Exception('Unable to upload selected media.');
    }
    return mediaIds;
  }

  void _showMediaPicker() {
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
            ListTile(
              leading: const Icon(Icons.image, color: Color(0xFF1D9BF0)),
              title: const Text('Photo', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                _pickImage();
              },
            ),
            ListTile(
              leading: const Icon(Icons.videocam, color: Color(0xFF1D9BF0)),
              title: const Text('Video', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                _pickVideo();
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage() async {
    final remainingSlots = 4 - _selectedMedia.length;
    if (remainingSlots <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Maximum 4 media files allowed per reply.'),
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
          _selectedMedia.add(picked.file!);
        }
      }
    });
  }

  void _onTextChanged() {
    final text = _textController.text;
    final cursorPosition = _textController.selection.baseOffset;

    if (cursorPosition < 0 || cursorPosition > text.length) return;

    // Check for @ mention first (priority over hashtags)
    int mentionStart = -1;
    for (int i = cursorPosition - 1; i >= 0; i--) {
      if (text[i] == '@') {
        mentionStart = i;
        break;
      }
      if (text[i] == ' ' || text[i] == '\n') {
        break;
      }
    }

    // If @ mention is found and valid, don't check for hashtags
    if (mentionStart != -1) {
      // Check if @ is at start or after whitespace
      if (mentionStart > 0) {
        final charBeforeAt = text[mentionStart - 1];
        if (charBeforeAt != ' ' && charBeforeAt != '\n') {
          mentionStart = -1;
        }
      }
    }

    // If no valid mention found, check for hashtags
    if (mentionStart == -1) {
      int hashtagStart = -1;
      for (int i = cursorPosition - 1; i >= 0; i--) {
        if (text[i] == '#') {
          hashtagStart = i;
          break;
        }
        if (text[i] == ' ' || text[i] == '\n') {
          break;
        }
      }

      if (hashtagStart != -1) {
        // Extract the hashtag query (without the #)
        final query = text.substring(hashtagStart + 1, cursorPosition);

        // Only show suggestions if query is not empty and doesn't contain spaces
        if (query.isNotEmpty && !query.contains(' ') && !query.contains('\n')) {
          _currentHashtagQuery = query;
          _hashtagStartPosition = hashtagStart;
          _searchHashtags(query);
        } else if (query.isEmpty) {
          // Show trending hashtags when user just types #
          _currentHashtagQuery = '';
          _hashtagStartPosition = hashtagStart;
          _loadTrendingHashtags();
        } else {
          _clearSuggestions();
        }
      } else {
        _clearSuggestions();
      }
    } else {
      // Clear hashtag suggestions when showing mentions
      if (_hashtagSuggestions.isNotEmpty) {
        setState(() {
          _hashtagSuggestions = [];
        });
      }
    }
  }

  void _searchHashtags(String query) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () async {
      final hashtagService = ref.read(hashtagServiceProvider);
      final suggestions = await hashtagService.searchHashtags(query);
      if (mounted) {
        setState(() {
          _hashtagSuggestions = suggestions;
        });
      }
    });
  }

  void _loadTrendingHashtags() async {
    final hashtagService = ref.read(hashtagServiceProvider);
    final suggestions = await hashtagService.fetchTrendingHashtags(limit: 5);
    if (mounted) {
      setState(() {
        _hashtagSuggestions = suggestions;
      });
    }
  }

  void _clearSuggestions() {
    if (_hashtagSuggestions.isNotEmpty) {
      setState(() {
        _hashtagSuggestions = [];
        _currentHashtagQuery = '';
        _hashtagStartPosition = -1;
      });
    }
  }

  void _onHashtagSelected(String hashtag) {
    if (_hashtagStartPosition == -1) return;

    final text = _textController.text;
    final cursorPosition = _textController.selection.baseOffset;

    // Replace the partial hashtag with the selected one
    final newText =
        text.substring(0, _hashtagStartPosition + 1) +
        hashtag +
        ' ' +
        text.substring(cursorPosition);

    final newCursorPosition = _hashtagStartPosition + hashtag.length + 2;

    _textController.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newCursorPosition),
    );

    _clearSuggestions();
  }

  Future<void> _pickVideo() async {
    final remainingSlots = 4 - _selectedMedia.length;
    if (remainingSlots <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Maximum 4 media files allowed per reply.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final picked = await pickVideo();
    if (picked == null || picked.file == null) return;

    setState(() {
      _selectedMedia.add(picked.file!);
    });
  }

  void _removeMedia(int index) {
    if (index < 0 || index >= _selectedMedia.length) return;
    setState(() {
      _selectedMedia.removeAt(index);
    });
  }

  bool _isVideoFile(File file) {
    final extension = file.path.split('.').last.toLowerCase();
    return [
      'mp4',
      'mov',
      'avi',
      'webm',
      'mkv',
      'flv',
      'wmv',
      'mpeg',
      'mpg',
      '3gp',
      'm4v',
    ].contains(extension);
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

  Widget _buildSelectedImagesPreview() {
    if (_selectedMedia.isEmpty) return const SizedBox.shrink();
    final crossAxisCount = _selectedMedia.length == 1 ? 1 : 2;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${_selectedMedia.length} / 4 media files',
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
            childAspectRatio: _selectedMedia.length == 1 ? 16 / 9 : 1.0,
          ),
          itemCount: _selectedMedia.length,
          itemBuilder: (context, index) {
            final file = _selectedMedia[index];
            final isVideo = _isVideoFile(file);
            return Stack(
              children: [
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: isVideo
                        ? Container(
                            color: Colors.grey[900],
                            child: const Center(
                              child: Icon(
                                Icons.play_circle_outline,
                                color: Colors.white,
                                size: 48,
                              ),
                            ),
                          )
                        : Image.file(file, fit: BoxFit.cover),
                  ),
                ),
                if (isVideo)
                  Positioned(
                    bottom: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black87,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.videocam, color: Colors.white, size: 12),
                          SizedBox(width: 4),
                          Text(
                            'Video',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: InkWell(
                    onTap: () => _removeMedia(index),
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
      body: Stack(
        children: [
          Column(
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
                        if (_selectedMedia.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          Padding(
                            padding: const EdgeInsets.only(left: 52),
                            child: _buildSelectedImagesPreview(),
                          ),
                        ],
                        const SizedBox(height: 12),
                        Padding(
                          padding: const EdgeInsets.only(left: 52),
                          child: InkWell(
                            onTap: _showPrivacyOptions,
                            borderRadius: BorderRadius.circular(20),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  _selectedPrivacy.icon,
                                  color: const Color(0xFF1D9BF0),
                                  size: 16,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  _selectedPrivacy.label,
                                  style: const TextStyle(
                                    color: Color(0xFF1D9BF0),
                                    fontSize: 14,
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
                ),
              ),
              _buildBottomBar(),
            ],
          ),
          // Mention suggestions overlay
          Positioned(
            left: 16,
            right: 16,
            child: MentionSuggestionOverlay(
              textController: _textController,
              onUserSelected: (UserSuggestion user) {
                // User selection is handled inside the overlay widget
              },
              layerLink: _mentionLayerLink,
            ),
          ),
          // Hashtag suggestions overlay
          if (_hashtagSuggestions.isNotEmpty)
            Positioned(
              width: MediaQuery.of(context).size.width - 32,
              child: CompositedTransformFollower(
                link: _layerLink,
                showWhenUnlinked: false,
                offset: const Offset(0, 80),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: HashtagSuggestionsOverlay(
                    suggestions: _hashtagSuggestions,
                    onHashtagSelected: _onHashtagSelected,
                  ),
                ),
              ),
            ),
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
                      '@${widget.replyingToTweet.authorUsername}',
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
                      text: '@${widget.replyingToTweet.authorUsername}',
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
          child: CompositedTransformTarget(
            link: _layerLink,
            child: CompositedTransformTarget(
              link: _mentionLayerLink,
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
                  Icons.perm_media_outlined,
                  color: Color(0xFF1D9BF0),
                ),
                onPressed: _isPosting ? null : _showMediaPicker,
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
