import 'package:flutter/material.dart';
import 'package:lite_x/features/chat/models/messagemodel.dart';
import 'package:lite_x/features/chat/view/widgets/MessageAppBar.dart';
import 'package:lite_x/features/chat/view/widgets/message_input_bar.dart';
import 'package:lite_x/core/classes/PickedImage.dart';
import 'package:lite_x/features/chat/view/widgets/MessageBubble.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class ChatScreen extends StatefulWidget {
  final String recipientName;
  final String recipientId;
  final String currentUserId;
  final List<MessageModel> messages;
  final Function(String text) onSendMessage;
  final Function(String path) onSendAudio;
  final Function(PickedImage image) onSendImage;
  final Function(String gifUrl) onSendGif;
  final Function(MessageModel message) onLongPressMessage;
  final Function(MessageModel message) onTapMessage;
  final Function(MessageModel message, int mediaIndex) onTapMedia;

  const ChatScreen({
    super.key,
    required this.recipientName,
    required this.recipientId,
    required this.currentUserId,
    required this.messages,

    required this.onSendMessage,
    required this.onSendAudio,
    required this.onSendImage,
    required this.onSendGif,
    required this.onLongPressMessage,
    required this.onTapMessage,
    required this.onTapMedia,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
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
                  itemCount: widget.messages.length,
                  itemBuilder: (context, index) {
                    final message = widget.messages[index];
                    final isMe = message.userId == widget.currentUserId;

                    return MessageBubble(
                      message: message,
                      isMe: isMe,
                      showSenderName: message.senderName != null && !isMe,
                      onLongPress: () => widget.onLongPressMessage(message),
                      onTap: () => widget.onTapMessage(message),
                      onMediaTap: (mediaIndex) =>
                          widget.onTapMedia(message, mediaIndex),
                    );
                  },
                ),

                _buildScrollToBottomButton(),
              ],
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: MessageInputBar(
                onSendMessage: widget.onSendMessage,
                onSendAudio: widget.onSendAudio,
                onSendImage: widget.onSendImage,
                onSendGif: widget.onSendGif,
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
