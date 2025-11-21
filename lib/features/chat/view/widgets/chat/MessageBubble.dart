import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lite_x/core/theme/palette.dart';
import 'package:lite_x/features/chat/models/messagemodel.dart';
import 'package:lite_x/features/chat/models/mediamodel.dart';

class MessageBubble extends StatelessWidget {
  final MessageModel message;
  final bool isMe;
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
            if (showSenderName && message.senderName != null)
              _SenderName(senderName: message.senderName!),

            _MessageContentBubble(
              message: message,
              isMe: isMe,
              bubbleColor: bubbleColor,
              onMediaTap: onMediaTap,
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
  final Function(int index)? onMediaTap;

  const _MessageContentBubble({
    required this.message,
    required this.isMe,
    required this.bubbleColor,
    this.onMediaTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.75,
      ),
      clipBehavior: Clip.antiAlias,
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
          if (message.hasMedia)
            _MediaContent(message: message, onMediaTap: onMediaTap, isMe: isMe),

          if (message.content?.isNotEmpty ?? false)
            _TextContent(content: message.content!, hasMedia: message.hasMedia),
        ],
      ),
    );
  }
}

class _TextContent extends StatelessWidget {
  final String content;
  final bool hasMedia;

  const _TextContent({required this.content, required this.hasMedia});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16, hasMedia ? 8 : 12, 16, 12),
      child: Text(
        content,
        style: const TextStyle(
          color: Palette.textWhite,
          fontSize: 15,
          height: 1.4,
        ),
      ),
    );
  }
}

class _MediaContent extends StatelessWidget {
  final MessageModel message;
  final bool isMe;
  final Function(int index)? onMediaTap;

  const _MediaContent({
    required this.message,
    this.onMediaTap,
    required this.isMe,
  });

  @override
  Widget build(BuildContext context) {
    if (message.media?.isEmpty ?? true) return const SizedBox.shrink();

    final media = message.media!;
    if (media.length == 1) {
      return _buildSingleMedia(media.first, 0, context);
    }
    return _buildMediaGrid(media);
  }

  Widget _buildSingleMedia(
    MediaModel mediaItem,
    int index,
    BuildContext context,
  ) {
    return GestureDetector(
      onTap: () => onMediaTap?.call(index),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 300),
        child: _buildMediaWidget(mediaItem, context),
      ),
    );
  }

  Widget _buildMediaGrid(List<MediaModel> mediaList) {
    final itemCount = mediaList.length;
    final displayCount = itemCount > 4 ? 4 : itemCount;
    final hasMore = itemCount > 4;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 2,
        mainAxisSpacing: 2,
        childAspectRatio: 1,
      ),
      itemCount: displayCount,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () => onMediaTap?.call(index),
          child: Stack(
            fit: StackFit.expand,
            children: [
              _buildMediaWidget(mediaList[index], context),
              if (hasMore && index == displayCount - 1)
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
    );
  }

  Widget _buildMediaWidget(MediaModel mediaItem, BuildContext context) {
    final type = mediaItem.type.toUpperCase();

    switch (type) {
      case 'IMAGE':
      case 'GIF':
        return _buildImageWidget(mediaItem, context);

      case 'VIDEO':
        return _buildVideoThumbnail(mediaItem);

      case 'FILE':
        return _buildFileWidget(mediaItem);

      default:
        return Container(
          color: Colors.grey[800],
          child: const Center(
            child: Icon(Icons.error_outline, color: Colors.grey, size: 48),
          ),
        );
    }
  }

  Widget _buildImageWidget(MediaModel mediaItem, BuildContext context) {
    print(
      "MEDIA DEBUG: Type: ${mediaItem.type}, LocalPath: ${mediaItem.localPath}, IsMe: $isMe",
    );

    if (mediaItem.localPath != null && mediaItem.localPath!.isNotEmpty) {
      final file = File(mediaItem.localPath!);

      return Stack(
        fit: StackFit.expand,
        children: [
          Image.file(
            file,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return _buildErrorPlaceholder();
            },
          ),

          if (message.status == 'PENDING')
            Container(
              color: Colors.black38,
              child: const Center(
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              ),
            ),
        ],
      );
    }

    return _buildDownloadingPlaceholder(mediaItem);
  }

  Widget _buildVideoThumbnail(MediaModel mediaItem) {
    if (mediaItem.localPath != null && mediaItem.localPath!.isNotEmpty) {
      return Stack(
        fit: StackFit.expand,
        children: [
          Container(
            color: Colors.black87,
            child: const Center(
              child: Icon(Icons.videocam, color: Colors.white54, size: 48),
            ),
          ),

          Center(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
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

          if (message.status == 'PENDING')
            Container(
              color: Colors.black38,
              child: const Center(
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              ),
            ),
        ],
      );
    }

    return _buildDownloadingPlaceholder(mediaItem);
  }

  Widget _buildDownloadingPlaceholder(MediaModel mediaItem) {
    return Container(
      height: 200,
      color: Colors.grey[800],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            color: Colors.white54,
            strokeWidth: 2,
          ),
          const SizedBox(height: 12),
          Text(
            'Downloading ${mediaItem.type.toLowerCase()}...',
            style: const TextStyle(color: Colors.white54, fontSize: 12),
          ),
          if (mediaItem.size != null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                mediaItem.displaySize,
                style: TextStyle(color: Colors.grey[500], fontSize: 11),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildErrorPlaceholder() {
    return Container(
      height: 200,
      color: Colors.grey[800],
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.broken_image, color: Colors.grey, size: 48),
          SizedBox(height: 8),
          Text(
            'Failed to load image',
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildFileWidget(MediaModel mediaItem) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.grey[800],
      child: Row(
        children: [
          const Icon(Icons.insert_drive_file, color: Palette.info, size: 40),
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
                  mediaItem.displaySize,
                  style: TextStyle(color: Colors.grey[400], fontSize: 12),
                ),
              ],
            ),
          ),
          if (mediaItem.localPath == null)
            const Icon(Icons.download, color: Colors.grey, size: 24)
          else
            const Icon(Icons.check_circle, color: Colors.green, size: 24),
        ],
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
