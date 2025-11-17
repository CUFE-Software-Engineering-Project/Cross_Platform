import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lite_x/features/chat/models/messagemodel.dart';

import 'package:lite_x/features/chat/view/widgets/chat/MessageAppBar.dart';
import 'package:lite_x/features/chat/view/widgets/chat/MessageBubble.dart';
import 'package:lite_x/features/chat/view/widgets/chat/TypingIndicator.dart';
import 'package:lite_x/features/chat/view/widgets/chat/message_input_bar.dart';
import 'package:lite_x/core/classes/PickedImage.dart';
import 'package:lite_x/features/chat/view_model/chat/Chat_view_model.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final String recipientName;
  final String recipientId;
  final String currentUserId;

  const ChatScreen({
    super.key,
    required this.recipientName,
    required this.recipientId,
    required this.currentUserId,
  });

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final ItemScrollController _itemScrollController = ItemScrollController();

  final ItemPositionsListener _itemPositionsListener =
      ItemPositionsListener.create();

  bool _showScrollToBottomButton = false;

  @override
  void initState() {
    super.initState();
    _itemPositionsListener.itemPositions.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _itemPositionsListener.itemPositions.removeListener(_scrollListener);
    super.dispose();
  }

  void _scrollListener() {
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
    _itemScrollController.scrollTo(
      index: 0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final chatviewmodel = ref.watch(chatViewModelProvider);
    List<MessageModel> messages = [];
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: MessageAppBar(
        recipientName: widget.recipientName,
        recipientId: widget.recipientId,
      ),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                ScrollablePositionedList.builder(
                  itemScrollController: _itemScrollController,
                  itemPositionsListener: _itemPositionsListener,
                  reverse: true,
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final isMe = message.userId == widget.currentUserId;

                    return MessageBubble(
                      message: message,
                      isMe: isMe,
                      showSenderName: message.senderName != null && !isMe,
                      onLongPress: () => {},
                      onTap: () => {},
                      onMediaTap: (mediaIndex) => {},
                    );
                  },
                ),
                if (chatviewmodel.isRecipientTyping)
                  TypingIndicator(userName: widget.recipientName),

                _buildScrollToBottomButton(),
              ],
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: MessageInputBar(
                onSendMessage: (text) {
                  //
                  _scrollToBottom();
                },
                onSendAudio: (audioPath) {
                  //
                },
                onSendImage: (PickedImage image) {
                  //
                },
                onSendGif: (gifUrl) {
                  //
                },
              ),
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
