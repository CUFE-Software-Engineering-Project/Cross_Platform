import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lite_x/core/providers/current_user_provider.dart';
import 'package:lite_x/core/theme/Palette.dart';
import 'package:lite_x/features/chat/models/messagemodel.dart';
import 'package:lite_x/features/chat/providers/activeChatIdProvider.dart';

import 'package:lite_x/features/chat/view/widgets/chat/MessageAppBar.dart';
import 'package:lite_x/features/chat/view/widgets/chat/MessageBubble.dart';
import 'package:lite_x/features/chat/view/widgets/chat/MessageOptionsSheet.dart';
import 'package:lite_x/features/chat/view/widgets/chat/TypingIndicator.dart';
import 'package:lite_x/features/chat/view/widgets/chat/message_input_bar.dart';
import 'package:lite_x/features/chat/view_model/chat/Chat_view_model.dart';
import 'package:lite_x/features/chat/view_model/conversions/Conversations_view_model.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final String chatId;
  final String title; // name of user or group name
  final String? subtitle; // username or group count
  final String? profileImage;
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
  final ItemPositionsListener _itemPositionsListener =
      ItemPositionsListener.create();
  bool _isExiting = false;
  bool _showScrollToBottomButton = false;
  final ScrollController _scrollController = ScrollController();
  late ChatViewModel notifier;

  ProviderSubscription<ChatState>? _chatSub;

  @override
  void initState() {
    super.initState();
    _currentUserId = ref.read(currentUserProvider)!.id;
    notifier = ref.read(chatViewModelProvider.notifier);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      _setupChatSubscription();

      ref.read(chatViewModelProvider.notifier).loadChat(widget.chatId);
      ref.read(activeChatProvider.notifier).state = widget.chatId;
      ref
          .read(conversationsViewModelProvider.notifier)
          .markChatAsRead(widget.chatId);
    });

    _itemPositionsListener.itemPositions.addListener(_scrollListener);
  }

  void _setupChatSubscription() {
    _chatSub = ref.listenManual<ChatState>(chatViewModelProvider, (
      previous,
      next,
    ) {
      if (_isExiting || !mounted) return;

      final notifier = ref.read(chatViewModelProvider.notifier);
      if (!notifier.isActiveChat(widget.chatId)) return;

      final positions = _itemPositionsListener.itemPositions.value;
      final isAtBottom =
          positions.isEmpty ||
          positions.any((pos) => pos.index == 0 && pos.itemLeadingEdge < 0.1);

      final lastMsg = next.messages.lastOrNull;

      if (lastMsg != null && (lastMsg.userId == _currentUserId || isAtBottom)) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_isExiting || !mounted) return;
          _scrollToBottom();
        });
      }
    }, fireImmediately: false);
  }

  @override
  void dispose() {
    ref.read(activeChatProvider.notifier).state = null;

    _isExiting = true;

    _chatSub?.close();
    _chatSub = null;

    _itemPositionsListener.itemPositions.removeListener(_scrollListener);

    try {
      final savedNotifier = notifier;

      Future.microtask(() {
        savedNotifier.sendTyping(false);
        savedNotifier.exitChat();
      });
    } catch (e) {
      debugPrint("Error during dispose: $e");
    }

    super.dispose();
  }

  void _scrollListener() {
    if (_isExiting || !mounted) return;

    final positions = _itemPositionsListener.itemPositions.value;
    if (positions.isEmpty) return;

    final isBottomVisible = positions.any((pos) => pos.index == 0);
    final shouldShowButton = !isBottomVisible;

    if (shouldShowButton != _showScrollToBottomButton) {
      setState(() {
        _showScrollToBottomButton = shouldShowButton;
      });
    }
  }

  void _scrollToBottom() {
    if (!mounted || _isExiting) return;
    if (!_scrollController.hasClients) return;

    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
    );
  }

  void _handleSendMessage(String text) {
    if (_isExiting || !mounted) return;

    final currentUser = ref.read(currentUserProvider);
    if (currentUser == null || text.trim().isEmpty) return;

    final tempId = DateTime.now().millisecondsSinceEpoch.toString();
    final message = MessageModel(
      id: tempId,
      chatId: widget.chatId,
      userId: currentUser.id,
      content: text.trim(),
      createdAt: DateTime.now(),
      status: 'PENDING',
      messageType: 'text',
    );

    ref.read(chatViewModelProvider.notifier).sendMessage(message);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_isExiting || !mounted) return;
      _scrollToBottom();
    });
  }

  void _handleDeleteMessage(MessageModel message, bool forEveryone) {
    print(
      'Delete message ${message.id} for ${forEveryone ? "everyone" : "me"}',
    );
  }

  void _handleEditMessage(MessageModel message) {
    print('Edit message ${message.id}');
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(chatViewModelProvider);
    final currentUser = ref.watch(currentUserProvider);

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
                if (chatState.isLoading)
                  const Center(child: CircularProgressIndicator())
                else
                  ListView.separated(
                    controller: _scrollController,
                    reverse: true,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    itemCount: messages.length + 1,
                    separatorBuilder: (_, __) => const SizedBox(height: 6),
                    itemBuilder: (context, index) {
                      if (index == messages.length)
                        return _buildProfileHeader();

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
                            onDeleteForMe: () =>
                                _handleDeleteMessage(message, false),
                            onDeleteForEveryone: () =>
                                _handleDeleteMessage(message, true),
                            onEdit: () => _handleEditMessage(message),
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
                    child: TypingIndicator(userName: widget.title),
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

  Widget _buildProfileHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 45,
            backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
            // backgroundImage: widget.profileImage != null
            //     ? NetworkImage(widget.profileImage!)
            //     : null,
            child: widget.profileImage == null
                ? Text(
                    widget.title[0].toUpperCase(),
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  )
                : null,
          ),
          const SizedBox(height: 5),

          Text(
            widget.title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Palette.textPrimary,
            ),
          ),
          if (widget.subtitle != null)
            Text(
              '@${widget.subtitle}',
              style: TextStyle(
                fontSize: 16,
                color: Color.fromARGB(255, 133, 139, 145),
              ),
            ),
          const SizedBox(height: 12),

          if (widget.recipientFollowersCount != null)
            Text(
              '${widget.recipientFollowersCount} Followers',
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            ),

          const SizedBox(height: 20),

          Divider(
            thickness: 0.2,
            color: Colors.grey[500],
            indent: 10,
            endIndent: 10,
          ),
          const SizedBox(height: 4),

          Text(
            'Today',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Palette.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScrollToBottomButton() {
    return Positioned(
      bottom: 10.0,
      right: 10.0,
      child: AnimatedOpacity(
        opacity: _showScrollToBottomButton ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 300),
        child: IgnorePointer(
          ignoring: !_showScrollToBottomButton,
          child: FloatingActionButton.small(
            onPressed: _scrollToBottom,
            tooltip: 'Scroll to bottom',
            backgroundColor: Theme.of(context).primaryColor,
            child: const Icon(Icons.arrow_downward, color: Colors.white),
          ),
        ),
      ),
    );
  }
}
