import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:lite_x/core/theme/palette.dart';
import 'dart:async';
import 'package:lite_x/features/chat/view/widgets/message_input_bar.dart';

class PickedImage {
  final String path;
  PickedImage(this.path);
}

Future<PickedImage?> pickImage() async {
  print('--- [MOCK] User tapped Pick Image ---');
  return null;
}

class AudioRecorderState {
  final bool isRecording;
  final Duration recordingDuration;
  AudioRecorderState({
    this.isRecording = false,
    this.recordingDuration = Duration.zero,
  });
  AudioRecorderState copyWith({
    bool? isRecording,
    Duration? recordingDuration,
  }) {
    return AudioRecorderState(
      isRecording: isRecording ?? this.isRecording,
      recordingDuration: recordingDuration ?? this.recordingDuration,
    );
  }
}

class MediaModel {
  final String url;
  final String type;
  final String? name;
  final String? displaySize;
  MediaModel({
    required this.url,
    required this.type,
    this.name,
    this.displaySize,
  });
}

class MessageModel {
  final String id;
  final String? content;
  final DateTime createdAt;
  final List<MediaModel>? media;
  final String status;
  final String userId;
  final String? senderName;
  late final bool hasMedia;
  late final String messageType;

  MessageModel({
    required this.id,
    this.content,
    required this.createdAt,
    this.media,
    required this.status,
    required this.userId,
    this.senderName,
  }) {
    hasMedia = media != null && media!.isNotEmpty;
    if (hasMedia) {
      messageType = media!.first.type.toLowerCase();
    } else {
      messageType = 'text';
    }
  }
}

class TestChatScreen extends StatelessWidget {
  const TestChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const String currentUserId = 'me';
    final List<MessageModel> mockMessages = _getMockMessages();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Aser'),
        backgroundColor: Palette.chathim,
        elevation: 0.5,
      ),
      body: Column(
        children: [
          // 1. The Message List (takes all available space)
          Expanded(
            child: ListView.builder(
              reverse: true,
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              itemCount: mockMessages.length,
              itemBuilder: (context, index) {
                final message = mockMessages[index];
                final isMe = message.userId == currentUserId;

                MessageModel? replyTo;
                if (message.id == '7') {
                  replyTo = mockMessages.firstWhere((m) => m.id == '6');
                }
                if (message.id == '4') {
                  replyTo = mockMessages.firstWhere((m) => m.id == '3');
                }

                return MessageBubble(
                  message: message,
                  isMe: isMe,
                  replyTo: replyTo,
                  showSenderName: message.senderName != null && !isMe,
                  onLongPress: () =>
                      print('Long pressed message: ${message.id}'),
                  onTap: () => print('Tapped message: ${message.id}'),
                  onMediaTap: (mediaIndex) => print(
                    'Tapped media $mediaIndex in message ${message.id}',
                  ),
                );
              },
            ),
          ),

          // 2. The Message Input Bar (fixed at the bottom)
          MessageInputBar(
            onSendMessage: (text) {
              print('--- [MOCK] Send Text Tapped: $text ---');
            },
            onSendAudio: (path) {
              print('--- [MOCK] Send Audio Tapped: $path ---');
            },
            onSendImage: (image) {
              print('--- [MOCK] Send Image Tapped: ${image.path} ---');
            },
          ),
        ],
      ),
    );
  }
}

List<MessageModel> _getMockMessages() {
  final now = DateTime.now();
  return [
    MessageModel(
      id: '1',
      content: "Hey, how's it going?",
      createdAt: now.subtract(const Duration(minutes: 10)),
      status: 'READ',
      userId: 'them',
      senderName: 'John Doe',
    ),
    MessageModel(
      id: '2',
      content: 'Pretty good! Just working on this chat UI.',
      createdAt: now.subtract(const Duration(minutes: 9)),
      status: 'READ',
      userId: 'me',
    ),
    MessageModel(
      id: '3',
      content: "Nice! Here's that photo you asked for.",
      createdAt: now.subtract(const Duration(minutes: 8)),
      status: 'READ',
      userId: 'them',
      senderName: 'John Doe',
      media: [
        MediaModel(url: 'https://picsum.photos/seed/1/600/800', type: 'IMAGE'),
      ],
    ),
    MessageModel(
      id: '4',
      content: "Wow, that looks great!",
      createdAt: now.subtract(const Duration(minutes: 7)),
      status: 'READ',
      userId: 'me',
    ),
    MessageModel(
      id: '5',
      content:
          "Just wanted to show you these from my trip. It was an amazing experience with lots of beautiful scenery!",
      createdAt: now.subtract(const Duration(minutes: 6)),
      status: 'DELIVERED',
      userId: 'me',
      media: [
        MediaModel(url: 'https://picsum.photos/seed/2/400', type: 'IMAGE'),
        MediaModel(url: 'https://picsum.photos/seed/3/400', type: 'IMAGE'),
        MediaModel(url: 'https://picsum.photos/seed/4/400', type: 'IMAGE'),
        MediaModel(url: 'https://picsum.photos/seed/5/400', type: 'IMAGE'),
        MediaModel(url: 'https://picsum.photos/seed/6/400', type: 'IMAGE'),
      ],
    ),
    MessageModel(
      id: '6',
      content: "Amazing pictures! The third one is my favorite.",
      createdAt: now.subtract(const Duration(minutes: 5)),
      status: 'READ',
      userId: 'other_group_member',
      senderName: 'Jane Doe',
    ),
    MessageModel(
      id: '7',
      content: "Thanks! Glad you liked it.",
      createdAt: now.subtract(const Duration(minutes: 4)),
      status: 'SENT',
      userId: 'me',
    ),
    MessageModel(
      id: '8',
      content: "Here's the document you wanted.",
      createdAt: now.subtract(const Duration(minutes: 3)),
      status: 'READ',
      userId: 'them',
      senderName: 'John Doe',
      media: [
        MediaModel(
          url: '',
          type: 'FILE',
          name: 'Project_Proposal_Final_V2.pdf',
          displaySize: '1.2 MB',
        ),
      ],
    ),
    MessageModel(
      id: '9',
      content: 'Got it, thanks!',
      createdAt: now.subtract(const Duration(minutes: 1)),
      status: 'PENDING',
      userId: 'me',
    ),
  ].reversed.toList();
}

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
              _SenderName(senderName: message.senderName!),
            if (replyTo != null)
              _ReplyPreview(repliedMessage: replyTo!, isMe: isMe),
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
      padding: const EdgeInsets.only(left: 12, bottom: 4),
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
          topLeft: const Radius.circular(12),
          topRight: const Radius.circular(12),
          bottomLeft: isMe
              ? const Radius.circular(12)
              : const Radius.circular(3),
          bottomRight: isMe
              ? const Radius.circular(3)
              : const Radius.circular(12),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (message.hasMedia)
            _MediaContent(message: message, onMediaTap: onMediaTap),
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
      padding: EdgeInsets.fromLTRB(12, hasMedia ? 8 : 10, 12, 10),
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
  final Function(int index)? onMediaTap;

  const _MediaContent({required this.message, this.onMediaTap});

  @override
  Widget build(BuildContext context) {
    if (message.media?.isEmpty ?? true) {
      return const SizedBox.shrink();
    }
    final media = message.media!;
    if (media.length == 1) {
      return _buildSingleMedia(media.first, 0);
    }
    return _buildMediaGrid(media);
  }

  Widget _buildSingleMedia(MediaModel mediaItem, int index) {
    return GestureDetector(
      onTap: () => onMediaTap?.call(index),
      child: _buildMediaWidget(mediaItem),
    );
  }

  Widget _buildMediaGrid(List<MediaModel> mediaList) {
    final itemCount = mediaList.length;
    final displayCount = itemCount > 4 ? 4 : itemCount;
    final hasMore = itemCount > 4;

    return GridView.builder(
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
              _buildMediaWidget(mediaList[index]),
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
    );
  }

  Widget _buildMediaWidget(MediaModel mediaItem) {
    final type = (mediaItem.type).toUpperCase();

    switch (type) {
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
          ],
        );

      case 'FILE':
        return Container(
          padding: const EdgeInsets.all(16),
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
                      maxLines: 2,
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
            ? Palette.info.withOpacity(0.15)
            : Colors.grey.withOpacity(0.15),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
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
          Text(
            repliedMessage.senderName ?? 'You',
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
                  repliedMessage.hasMedia &&
                          (repliedMessage.content?.isEmpty ?? true)
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
      padding: EdgeInsets.only(left: isMe ? 0 : 12, right: isMe ? 12 : 0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: isMe
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
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
        return const Icon(Icons.done_all, color: Palette.info, size: 16);
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
