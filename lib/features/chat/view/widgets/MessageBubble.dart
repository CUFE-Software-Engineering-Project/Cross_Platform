import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lite_x/core/theme/palette.dart';
import 'package:lite_x/features/chat/models/messagemodel.dart';
import 'package:cached_network_image/cached_network_image.dart';

class MessageBubble extends StatelessWidget {
  final MessageModel message;
  final bool isMe;
  final MessageModel? replyTo;
  final VoidCallback? onLongPress;
  final VoidCallback? onTap;
  final Function(int index)? onMediaTap;
  final bool showSenderName;
  final Color? sentBubbleColor;
  final Color? receivedBubbleColor;

  const MessageBubble({
    super.key,
    required this.message,
    required this.isMe,
    this.replyTo,
    this.onLongPress,
    this.onTap,
    this.onMediaTap,
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
            if (showSenderName && !isMe && message.senderName != null)
              Padding(
                padding: const EdgeInsets.only(left: 16, bottom: 4),
                child: Text(
                  message.senderName!,
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            if (replyTo != null)
              _ReplyPreview(repliedMessage: replyTo!, isMe: isMe),
            Container(
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (message.hasMedia) _buildMediaContent(),
                  if (message.content != null && message.content!.isNotEmpty)
                    Padding(
                      padding: EdgeInsets.fromLTRB(
                        16,
                        message.hasMedia ? 8 : 12,
                        16,
                        12,
                      ),
                      child: Text(
                        message.content!,
                        style: const TextStyle(
                          color: Palette.textWhite,
                          fontSize: 15,
                          height: 1.4,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 3),
            _MessageStatusAndTime(message: message, isMe: isMe),
          ],
        ),
      ),
    );
  }

  Widget _buildMediaContent() {
    if (message.media == null || message.media!.isEmpty) {
      return const SizedBox.shrink();
    }
    final media = message.media!;
    if (media.length == 1) {
      return _buildSingleMedia(media.first, 0);
    }
    return _buildMediaGrid(media);
  }

  Widget _buildSingleMedia(dynamic mediaItem, int index) {
    final type = mediaItem.type as String;
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(20),
        topRight: Radius.circular(20),
        bottomLeft: Radius.circular(20),
        bottomRight: Radius.circular(20),
      ),
      child: GestureDetector(
        onTap: () => onMediaTap?.call(index),
        child: _buildMediaWidget(mediaItem, type),
      ),
    );
  }

  Widget _buildMediaGrid(List<dynamic> mediaList) {
    final itemCount = mediaList.length;
    final displayCount = itemCount > 4 ? 4 : itemCount;
    final hasMore = itemCount > 4;

    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(20),
        topRight: Radius.circular(20),
      ),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: displayCount == 1 ? 1 : 2,
          crossAxisSpacing: 2,
          mainAxisSpacing: 2,
        ),
        itemCount: displayCount,
        itemBuilder: (context, index) {
          final isLast = index == displayCount - 1;
          return GestureDetector(
            onTap: () => onMediaTap?.call(index),
            child: Stack(
              fit: StackFit.expand,
              children: [
                _buildMediaWidget(mediaList[index], mediaList[index].type),
                if (hasMore && isLast)
                  Container(
                    color: Colors.black54,
                    child: Center(
                      child: Text(
                        '+${itemCount - 4}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildMediaWidget(dynamic mediaItem, String type) {
    switch (type.toUpperCase()) {
      case 'IMAGE':
      case 'GIF':
        return CachedNetworkImage(
          imageUrl: mediaItem.url,
          fit: BoxFit.cover,
          placeholder: (context, url) => Container(
            color: Colors.grey[800],
            child: const Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation(Palette.info),
              ),
            ),
          ),
          errorWidget: (context, url, error) => Container(
            color: Colors.grey[800],
            child: const Icon(Icons.broken_image, color: Colors.grey, size: 48),
          ),
        );

      case 'VIDEO':
        return Stack(
          fit: StackFit.expand,
          children: [
            CachedNetworkImage(
              imageUrl: mediaItem.url,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(color: Colors.grey[800]),
              errorWidget: (context, url, error) => Container(
                color: Colors.grey[800],
                child: const Icon(Icons.videocam, color: Colors.grey, size: 48),
              ),
            ),
            Center(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.play_arrow,
                  color: Colors.white,
                  size: 32,
                ),
              ),
            ),
          ],
        );

      case 'FILE':
        return Container(
          padding: const EdgeInsets.all(16),
          color: Colors.grey[800],
          child: Row(
            children: [
              const Icon(
                Icons.insert_drive_file,
                color: Palette.info,
                size: 40,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      mediaItem.name ?? 'File',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      mediaItem.displaySize ?? 'Unknown size',
                      style: TextStyle(color: Colors.grey[400], fontSize: 12),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.download, color: Colors.grey, size: 24),
            ],
          ),
        );

      default:
        return Container(
          color: Colors.grey[800],
          child: const Center(
            child: Icon(Icons.error_outline, color: Colors.grey, size: 48),
          ),
        );
    }
  }
}

class _ReplyPreview extends StatelessWidget {
  final MessageModel repliedMessage;
  final bool isMe;

  const _ReplyPreview({required this.repliedMessage, required this.isMe});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(
        bottom: 6,
        left: isMe ? 40 : 0,
        right: isMe ? 0 : 40,
      ),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isMe
            ? Palette.info.withOpacity(0.25)
            : Colors.grey.withOpacity(0.25),
        borderRadius: BorderRadius.circular(12),
        border: Border(
          left: BorderSide(
            color: isMe ? Palette.info : Palette.border,
            width: 3,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (repliedMessage.senderName != null)
            Text(
              repliedMessage.senderName!,
              style: TextStyle(
                color: isMe ? Palette.info : Palette.border,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),

          const SizedBox(height: 2),
          Row(
            children: [
              if (repliedMessage.hasMedia)
                Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: Icon(
                    _getMediaIcon(repliedMessage.messageType),
                    color: Palette.textSecondary,
                    size: 16,
                  ),
                ),
              Expanded(
                child: Text(
                  repliedMessage.hasMedia && repliedMessage.content == null
                      ? _getMediaLabel(repliedMessage.messageType)
                      : repliedMessage.content ?? '',
                  style: const TextStyle(
                    color: Palette.textSecondary,
                    fontSize: 13,
                    fontStyle: FontStyle.italic,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  IconData _getMediaIcon(String messageType) {
    switch (messageType) {
      case 'image':
        return Icons.image;
      case 'video':
        return Icons.videocam;
      case 'gif':
        return Icons.gif;
      case 'file':
        return Icons.insert_drive_file;
      default:
        return Icons.attach_file;
    }
  }

  String _getMediaLabel(String messageType) {
    switch (messageType) {
      case 'image':
        return 'Photo';
      case 'video':
        return 'Video';
      case 'gif':
        return 'GIF';
      case 'file':
        return 'File';
      default:
        return 'Media';
    }
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
            "$formattedTime.",
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
        return const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Seen',
              style: TextStyle(color: Palette.greycolor, fontSize: 12),
            ),
          ],
        );

      case 'DELIVERED':
        return const Icon(Icons.done_all, color: Palette.greycolor, size: 16);

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
