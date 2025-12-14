// ignore_for_file: unused_result

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lite_x/core/providers/current_user_provider.dart';
import 'package:lite_x/core/theme/Palette.dart';
import 'package:lite_x/features/chat/providers/activeChatIdProvider.dart';
import 'package:lite_x/features/chat/view/widgets/chat/MessageAppBar.dart';
import 'package:lite_x/features/chat/view/widgets/chat/MessageBubble.dart';
import 'package:lite_x/features/chat/view/widgets/chat/MessageOptionsSheet.dart';
import 'package:lite_x/features/chat/view/widgets/chat/TypingIndicator.dart';
import 'package:lite_x/features/chat/view/widgets/chat/message_input_bar.dart';
import 'package:lite_x/features/chat/view_model/chat/Chat_view_model.dart';
import 'package:lite_x/features/chat/view_model/conversions/Conversations_view_model.dart';
import 'package:lite_x/features/profile/models/shared.dart';
import 'package:lite_x/features/profile/view_model/providers.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final String chatId;
  final String title; // name of user
  final String? subtitle; // username
  final String? profileImage; // media id of receiver
  final bool isGroup;
  final int? recipientFollowersCount;
  const ChatScreen({
    super.key,
    required this.chatId,
    required this.title,
    this.subtitle,
    this.profileImage,
    this.isGroup = false,
    this.recipientFollowersCount,
  });

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  late String _currentUserId;
  bool _isExiting = false;
  bool _showScrollToBottomButton = false;
  final ScrollController _scrollController = ScrollController();
  bool _isLoadingMore = false;
  ProviderSubscription<ChatState>? _chatSub;

  @override
  void initState() {
    super.initState();
    _currentUserId = ref.read(currentUserProvider)!.id;
    _scrollController.addListener(_onScroll);
    _scrollController.addListener(_onScroll);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _setupChatSubscription();
      ref.refresh(followersProvider(widget.subtitle ?? ""));
      ref.read(chatViewModelProvider.notifier).loadChat(widget.chatId);
      ref.read(activeChatProvider.notifier).setActive(widget.chatId);
      ref
          .read(conversationsViewModelProvider.notifier)
          .markChatAsRead(widget.chatId);
    });
  }

  @override
  void dispose() {
    _chatSub?.close();
    _chatSub = null;
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();

    super.dispose();
  }

  void _setupChatSubscription() {
    _chatSub = ref.listenManual<ChatState>(chatViewModelProvider, (
      previous,
      next,
    ) {
      if (!mounted || _isExiting) return;

      final notifier = ref.read(chatViewModelProvider.notifier);
      if (!notifier.isActiveChat(widget.chatId)) return;

      final shouldAutoScroll = _shouldAutoScrollToBottom(previous, next);

      if (shouldAutoScroll) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_isExiting || !mounted) return;
          _scrollToBottom(animate: true);
        });
      }
    }, fireImmediately: false);
  }

  bool _shouldAutoScrollToBottom(ChatState? previous, ChatState next) {
    if (previous == null || previous.messages.isEmpty) return true;

    if (previous.messages.length == next.messages.length) return false;

    final lastMsg = next.messages.lastOrNull;
    if (lastMsg == null) return false;

    final isMine = lastMsg.userId == _currentUserId;
    final isNearBottom = _isScrolledToBottom();

    return isMine || isNearBottom;
  }

  bool _isScrolledToBottom() {
    if (!_scrollController.hasClients) return true;

    const threshold = 100.0;
    final position = _scrollController.position;

    return position.pixels <= threshold;
  }

  void _onScroll() {
    if (_isExiting || !mounted) return;

    final shouldShowButton = !_isScrolledToBottom();
    if (shouldShowButton != _showScrollToBottomButton) {
      setState(() {
        _showScrollToBottomButton = shouldShowButton;
      });
    }

    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !_isLoadingMore) {
      _loadMoreMessages();
    }
  }

  Future<void> _loadMoreMessages() async {
    if (_isLoadingMore) return;

    final chatState = ref.read(chatViewModelProvider);
    if (chatState.isLoadingHistory) return;

    setState(() {
      _isLoadingMore = true;
    });

    await ref.read(chatViewModelProvider.notifier).loadOlderMessages();

    setState(() {
      _isLoadingMore = false;
    });
  }

  void _scrollToBottom({bool animate = true}) {
    if (!mounted || _isExiting) return;
    if (!_scrollController.hasClients) return;

    if (animate) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    } else {
      _scrollController.jumpTo(0);
    }
  }

  void _handleSendMessage(String text) {
    if (_isExiting || !mounted) return;

    final currentUser = ref.read(currentUserProvider);
    if (currentUser == null || text.trim().isEmpty) return;

    ref
        .read(chatViewModelProvider.notifier)
        .sendMessage(content: text.trim(), messageType: 'text');

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_isExiting || !mounted) return;
      _scrollToBottom(animate: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(chatViewModelProvider);
    final currentUser = ref.watch(currentUserProvider);
    final followersAsync = ref.watch(followersProvider(widget.subtitle ?? ""));
    int latestFollowersCount = widget.recipientFollowersCount ?? 0;
    followersAsync.when(
      data: (either) {
        latestFollowersCount = either.fold(
          (_) => latestFollowersCount,
          (users) => users.length,
        );
      },
      loading: () {},
      error: (_, __) {},
    );
    if (currentUser == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final messages = chatState.messages;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: MessageAppBar(
        title: widget.title,
        subtitle: widget.subtitle ?? '',
      ),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                if (chatState.isLoading && messages.isEmpty)
                  const Center(child: CircularProgressIndicator())
                else
                  ListView.separated(
                    controller: _scrollController,
                    reverse: true,
                    padding: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 8,
                    ),
                    itemCount:
                        messages.length + (chatState.isLoadingHistory ? 2 : 1),
                    separatorBuilder: (_, __) => const SizedBox(height: 6),
                    itemBuilder: (context, index) {
                      if (chatState.isLoadingHistory &&
                          index == messages.length + 1) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }

                      if (index == messages.length) {
                        return _buildProfileHeader(latestFollowersCount);
                      }

                      final message = messages[messages.length - index - 1];
                      final isMe = message.userId == currentUser.id;

                      return MessageBubble(
                        message: message,
                        isMe: isMe,
                        showSenderName: message.senderName != null && !isMe,
                        onLongPress: () {
                          MessageOptionsSheet.show(
                            context: context,
                            message: message,
                            isMe: isMe,
                          );
                        },
                      );
                    },
                  ),

                if (chatState.isRecipientTyping)
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Theme.of(context).scaffoldBackgroundColor,
                          ],
                        ),
                      ),
                      child: TypingIndicator(userName: widget.title),
                    ),
                  ),

                _buildScrollToBottomButton(),
              ],
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: MessageInputBar(
                onSendMessage: _handleSendMessage,
                onTypingChanged: (isTyping) {
                  ref.read(chatViewModelProvider.notifier).sendTyping(isTyping);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(int followersCount) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          BuildSmallProfileImage(radius: 48, username: widget.subtitle),
          const SizedBox(height: 8),
          Text(
            widget.title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Palette.textPrimary,
            ),
          ),

          if (widget.subtitle != null) ...[
            Text(
              '@${widget.subtitle}',
              style: const TextStyle(fontSize: 15, color: Color(0xFF858B91)),
            ),
          ],

          const SizedBox(height: 8),
          Text(
            '${followersCount} Followers',
            style: TextStyle(fontSize: 14, color: Color(0xFF858B91)),
          ),

          const SizedBox(height: 20),

          Divider(
            thickness: 0.5,
            color: Colors.grey[300],
            indent: 20,
            endIndent: 20,
          ),

          const SizedBox(height: 4),

          Text(
            _getConversationStartDate(),
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  String _getConversationStartDate() {
    final chatState = ref.read(chatViewModelProvider);
    if (chatState.messages.isEmpty) return 'Today';

    final oldestMessage = chatState.messages.first;
    final now = DateTime.now();
    final messageDate = oldestMessage.createdAt;

    final difference = now.difference(messageDate);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${messageDate.day},${messageDate.month},${messageDate.year}';
    }
  }

  Widget _buildScrollToBottomButton() {
    return Positioned(
      bottom: 16.0,
      right: 16.0,
      child: AnimatedScale(
        scale: _showScrollToBottomButton ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        child: AnimatedOpacity(
          opacity: _showScrollToBottomButton ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 200),
          child: IgnorePointer(
            ignoring: !_showScrollToBottomButton,
            child: FloatingActionButton.small(
              onPressed: () => _scrollToBottom(animate: true),
              tooltip: 'Scroll to bottom',
              backgroundColor: Theme.of(context).primaryColor,
              elevation: 4,
              child: const Icon(
                Icons.keyboard_arrow_down_rounded,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
