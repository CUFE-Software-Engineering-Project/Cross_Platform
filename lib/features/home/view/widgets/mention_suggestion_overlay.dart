import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lite_x/features/home/models/user_suggestion.dart';
import 'package:lite_x/features/home/repositories/home_repository.dart';

class MentionSuggestionOverlay extends ConsumerStatefulWidget {
  final TextEditingController textController;
  final Function(UserSuggestion) onUserSelected;
  final LayerLink layerLink;

  const MentionSuggestionOverlay({
    super.key,
    required this.textController,
    required this.onUserSelected,
    required this.layerLink,
  });

  @override
  ConsumerState<MentionSuggestionOverlay> createState() =>
      _MentionSuggestionOverlayState();
}

class _MentionSuggestionOverlayState
    extends ConsumerState<MentionSuggestionOverlay> {
  List<UserSuggestion> _suggestions = [];
  bool _isLoading = false;
  String _currentMention = '';
  int _mentionStartIndex = -1;

  @override
  void initState() {
    super.initState();
    widget.textController.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    widget.textController.removeListener(_onTextChanged);
    super.dispose();
  }

  void _onTextChanged() {
    final text = widget.textController.text;
    final cursorPosition = widget.textController.selection.baseOffset;

    if (cursorPosition < 0) return;

    // Find the last @ before cursor
    int atIndex = -1;
    for (int i = cursorPosition - 1; i >= 0; i--) {
      if (text[i] == '@') {
        atIndex = i;
        break;
      }
      // Stop if we hit a space (not part of mention)
      if (text[i] == ' ' || text[i] == '\n') {
        break;
      }
    }

    if (atIndex == -1) {
      // No @ found, hide suggestions
      if (_suggestions.isNotEmpty) {
        setState(() {
          _suggestions = [];
          _currentMention = '';
          _mentionStartIndex = -1;
        });
      }
      return;
    }

    // Check if @ is at start or after whitespace
    if (atIndex > 0) {
      final charBeforeAt = text[atIndex - 1];
      if (charBeforeAt != ' ' && charBeforeAt != '\n') {
        // @ is not at a valid position
        if (_suggestions.isNotEmpty) {
          setState(() {
            _suggestions = [];
            _currentMention = '';
            _mentionStartIndex = -1;
          });
        }
        return;
      }
    }

    // Extract mention text (from @ to cursor)
    final mentionText = text.substring(atIndex + 1, cursorPosition);

    // Check if mention contains spaces (invalid)
    if (mentionText.contains(' ') || mentionText.contains('\n')) {
      if (_suggestions.isNotEmpty) {
        setState(() {
          _suggestions = [];
          _currentMention = '';
          _mentionStartIndex = -1;
        });
      }
      return;
    }

    // Search for users
    if (mentionText != _currentMention) {
      _currentMention = mentionText;
      _mentionStartIndex = atIndex;

      if (mentionText.isEmpty) {
        // Just typed @, clear suggestions but keep ready
        if (_suggestions.isNotEmpty) {
          setState(() {
            _suggestions = [];
          });
        }
      } else {
        // User is typing after @, search for users
        _searchUsers(mentionText);
      }
    }
  }

  Future<void> _searchUsers(String query) async {
    print('🔍 Searching users for: "$query"');
    setState(() {
      _isLoading = true;
    });

    try {
      final users = await ref.read(homeRepositoryProvider).searchUsers(query);
      print('✅ Found ${users.length} users');
      if (mounted && query == _currentMention) {
        setState(() {
          _suggestions = users;
          _isLoading = false;
        });
        print(
          '📋 Updated suggestions: ${_suggestions.length} users, isLoading: $_isLoading',
        );
      }
    } catch (e) {
      print('❌ Error searching users: $e');
      if (mounted) {
        setState(() {
          _suggestions = [];
          _isLoading = false;
        });
      }
    }
  }

  void _selectUser(UserSuggestion user) {
    final text = widget.textController.text;
    final cursorPosition = widget.textController.selection.baseOffset;

    // Replace from @ to cursor with @username
    final newText =
        text.substring(0, _mentionStartIndex) +
        '@${user.username} ' +
        text.substring(cursorPosition);

    widget.textController.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(
        offset:
            _mentionStartIndex +
            user.username.length +
            2, // @ + username + space
      ),
    );

    setState(() {
      _suggestions = [];
      _currentMention = '';
      _mentionStartIndex = -1;
    });

    widget.onUserSelected(user);
  }

  @override
  Widget build(BuildContext context) {
    print(
      '🎨 Building overlay - suggestions: ${_suggestions.length}, isLoading: $_isLoading',
    );

    if (_suggestions.isEmpty && !_isLoading) {
      print('⚠️ Returning empty widget');
      return const SizedBox.shrink();
    }

    print('✨ Rendering overlay with ${_suggestions.length} suggestions');
    return CompositedTransformFollower(
      link: widget.layerLink,
      showWhenUnlinked: false,
      offset: const Offset(0, 60),
      child: Material(
        elevation: 8,
        borderRadius: BorderRadius.circular(8),
        color: Colors.transparent,
        child: Container(
          constraints: const BoxConstraints(maxHeight: 200),
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.blue, width: 2),
          ),
          child: _isLoading
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: CircularProgressIndicator(),
                  ),
                )
              : ListView.builder(
                  shrinkWrap: true,
                  padding: EdgeInsets.zero,
                  itemCount: _suggestions.length,
                  itemBuilder: (context, index) {
                    final user = _suggestions[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage: user.profileImageUrl.isNotEmpty
                            ? NetworkImage(user.profileImageUrl)
                            : null,
                        child: user.profileImageUrl.isEmpty
                            ? Text(user.name[0].toUpperCase())
                            : null,
                      ),
                      title: Row(
                        children: [
                          Flexible(
                            child: Text(
                              user.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (user.verified) ...[
                            const SizedBox(width: 4),
                            Icon(
                              Icons.verified,
                              size: 16,
                              color: Theme.of(context).primaryColor,
                            ),
                          ],
                        ],
                      ),
                      subtitle: Text(
                        '@${user.username}',
                        style: TextStyle(
                          color: Theme.of(
                            context,
                          ).textTheme.bodySmall?.color?.withOpacity(0.6),
                        ),
                      ),
                      trailing: user.isFollowing
                          ? Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Theme.of(
                                  context,
                                ).primaryColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'Following',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                            )
                          : null,
                      onTap: () => _selectUser(user),
                    );
                  },
                ),
        ),
      ),
    );
  }
}
