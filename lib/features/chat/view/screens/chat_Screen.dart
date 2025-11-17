import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lite_x/core/providers/current_user_provider.dart';
import 'package:lite_x/core/theme/Palette.dart';
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
  final String? recipientUsername;
  final String? recipientProfileImage;
  final int? recipientFollowersCount;

  const ChatScreen({
    super.key,
    required this.recipientName,
    required this.recipientId,
    this.recipientUsername,
    this.recipientProfileImage,
    this.recipientFollowersCount,
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
    final currentuser = ref.watch(currentUserProvider);
    List<MessageModel> messages = [];
    if (currentuser == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
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
                  itemCount: messages.length + 1,
                  itemBuilder: (context, index) {
                    if (index == messages.length) {
                      return _buildProfileHeader();
                    }

                    final message = messages[index];
                    final isMe = message.userId == currentuser.id;

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

  Widget _buildProfileHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 45,
            backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
            backgroundImage: widget.recipientProfileImage != null
                ? NetworkImage(widget.recipientProfileImage!)
                : null,
            child: widget.recipientProfileImage == null
                ? Text(
                    widget.recipientName[0].toUpperCase(),
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
            widget.recipientName,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Palette.textPrimary,
            ),
          ),
          if (widget.recipientUsername != null)
            Text(
              '@${widget.recipientUsername}',
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
            'Today', // mock
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
