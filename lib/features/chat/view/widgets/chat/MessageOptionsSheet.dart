import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lite_x/core/theme/palette.dart';
import 'package:lite_x/features/chat/models/messagemodel.dart';

class MessageOptionsSheet extends StatelessWidget {
  final MessageModel message;
  final bool isMe;
  final VoidCallback? onDeleteForMe;
  final VoidCallback? onDeleteForEveryone;
  final VoidCallback? onEdit;
  const MessageOptionsSheet({
    super.key,
    required this.message,
    required this.isMe,
    this.onDeleteForMe,
    this.onDeleteForEveryone,
    this.onEdit,
  });

  static Future<void> show({
    required BuildContext context,
    required MessageModel message,
    required bool isMe,
    VoidCallback? onDeleteForMe,
    VoidCallback? onDeleteForEveryone,
    VoidCallback? onEdit,
  }) {
    return showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Palette.chathim,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: MessageOptionsSheet(
            message: message,
            isMe: isMe,
            onDeleteForMe: onDeleteForMe,
            onDeleteForEveryone: onDeleteForEveryone,
            onEdit: onEdit,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 8),
        if (isMe)
          _buildTextOption(
            context: context,
            label: 'Edit message',
            onTap: () {
              Navigator.pop(context);
              onEdit?.call();
            },
          ),

        if (message.content?.isNotEmpty ?? false)
          _buildTextOption(
            context: context,
            label: 'Copy message text',
            onTap: () {
              Clipboard.setData(ClipboardData(text: message.content!));
              Navigator.pop(context);
            },
          ),

        if (isMe)
          _buildTextOption(
            context: context,
            label: 'Delete message for everyone',
            color: Palette.textPrimary,
            onTap: () {
              Navigator.pop(context);
              _showDeleteConfirmation(
                context,
                'Delete for everyone?',
                'This message will be deleted for all participants in this chat.',
                onDeleteForEveryone,
              );
            },
          ),
        _buildTextOption(
          context: context,
          label: 'Delete message for you',
          color: Palette.textPrimary,
          onTap: () {
            Navigator.pop(context);
            _showDeleteConfirmation(
              context,
              'Delete message?',
              'This message will be deleted for you. Other people in the conversation will still be able to see it.',
              onDeleteForMe,
            );
          },
        ),
      ],
    );
  }

  Widget _buildTextOption({
    required BuildContext context,
    required String label,
    required VoidCallback onTap,
    Color? color,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Text(
          label,
          style: TextStyle(
            color: color ?? Palette.textWhite,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirmation(
    BuildContext context,
    String title,
    String content,
    VoidCallback? onConfirm,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color.fromARGB(255, 49, 55, 61),
        title: Text(title, style: const TextStyle(color: Palette.textPrimary)),
        content: Text(
          content,
          style: const TextStyle(color: Palette.textPrimary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Palette.textPrimary),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onConfirm?.call();
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: Palette.textPrimary),
            ),
          ),
        ],
      ),
    );
  }
}
