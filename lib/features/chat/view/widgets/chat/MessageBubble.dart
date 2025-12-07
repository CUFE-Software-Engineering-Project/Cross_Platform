import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lite_x/core/theme/palette.dart';
import 'package:lite_x/features/chat/models/messagemodel.dart';

class MessageBubble extends StatelessWidget {
  final MessageModel message;
  final bool isMe;
  final VoidCallback? onLongPress;
  final VoidCallback? onTap;
  final bool showSenderName;
  final Color? sentBubbleColor;
  final Color? receivedBubbleColor;

  const MessageBubble({
    super.key,
    required this.message,
    required this.isMe,
    this.onLongPress,
    this.onTap,
    this.showSenderName = false,
    this.sentBubbleColor,
    this.receivedBubbleColor,
  });

  @override
  Widget build(BuildContext context) {
    final alignment = isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final bubbleColor = isMe
        ? (sentBubbleColor ?? Palette.chatme)
        : (receivedBubbleColor ?? Palette.chathim);

    return GestureDetector(
      onLongPress: onLongPress,
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 10),
        child: Column(
          crossAxisAlignment: alignment,
          children: [
            if (showSenderName && message.senderName != null)
              _SenderName(senderName: message.senderName!),
            _MessageContentBubble(
              message: message,
              isMe: isMe,
              bubbleColor: bubbleColor,
            ),
            const SizedBox(height: 3),
            _MessageStatusAndTime(message: message, isMe: isMe),
          ],
        ),
      ),
    );
  }
}

class _SenderName extends StatelessWidget {
  final String senderName;
  const _SenderName({required this.senderName});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, bottom: 4),
      child: Text(
        senderName,
        style: TextStyle(
          color: Colors.grey[400],
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _MessageContentBubble extends StatelessWidget {
  final MessageModel message;
  final bool isMe;
  final Color bubbleColor;

  const _MessageContentBubble({
    required this.message,
    required this.isMe,
    required this.bubbleColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.75,
      ),
      decoration: BoxDecoration(
        color: bubbleColor,
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(20),
          topRight: const Radius.circular(20),
          bottomLeft: isMe
              ? const Radius.circular(20)
              : const Radius.circular(4),
          bottomRight: isMe
              ? const Radius.circular(4)
              : const Radius.circular(20),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Text(
          message.content ?? '',
          style: const TextStyle(
            color: Palette.textWhite,
            fontSize: 15,
            height: 1.4,
          ),
        ),
      ),
    );
  }
}

class _MessageStatusAndTime extends StatelessWidget {
  final MessageModel message;
  final bool isMe;

  const _MessageStatusAndTime({required this.message, required this.isMe});

  @override
  Widget build(BuildContext context) {
    final formattedTime = DateFormat.jm()
        .format(message.createdAt)
        .toLowerCase();
    return Padding(
      padding: EdgeInsets.only(left: isMe ? 0 : 16, right: isMe ? 16 : 0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            formattedTime,
            style: const TextStyle(color: Palette.greycolor, fontSize: 12),
          ),
          if (isMe) ...[const SizedBox(width: 6), _buildStatusIcon()],
        ],
      ),
    );
  }

  Widget _buildStatusIcon() {
    switch (message.status.toUpperCase()) {
      case 'READ':
        return const Text(
          'Seen',
          style: TextStyle(color: Palette.greycolor, fontSize: 12),
        );
      case 'SENT':
        return const Icon(Icons.check, color: Palette.greycolor, size: 16);
      case 'PENDING':
      default:
        return const Icon(
          Icons.access_time,
          color: Palette.greycolor,
          size: 14,
        );
    }
  }
}
