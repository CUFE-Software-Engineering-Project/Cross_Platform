// ignore_for_file: dead_code, unused_local_variable

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lite_x/core/providers/current_user_provider.dart';
import 'package:lite_x/core/theme/Palette.dart';
import 'package:lite_x/features/chat/view/widgets/conversion/conversation_tile.dart';
import 'package:lite_x/features/chat/view/widgets/conversion/empty_inbox.dart';
import 'package:lite_x/features/chat/view_model/conversions/Conversations_view_model.dart';
import 'package:timeago/timeago.dart' as timeago;

class ConversationsList extends ConsumerStatefulWidget {
  const ConversationsList({super.key});

  @override
  ConsumerState<ConversationsList> createState() => _ConversationsListState();
}

class _ConversationsListState extends ConsumerState<ConversationsList> {
  final ScrollController _scrollController = ScrollController();
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(conversationsViewModelProvider.notifier).loadConversations();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  String _getDisplayMessage(String? content, String? messageType) {
    if (messageType == null || messageType == 'text') {
      return content ?? '';
    }

    switch (messageType.toLowerCase()) {
      case 'image':
        return 'Photo';
      case 'video':
        return 'Video';
      case 'gif':
        return 'GIF';
      case 'file':
        return 'File';
      default:
        return content ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final conversationsAsync = ref.watch(conversationsViewModelProvider);
    final currentUser = ref.watch(currentUserProvider);

    return conversationsAsync.when(
      data: (conversations) {
        if (conversations.isEmpty) {
          return const EmptyInbox();
        }

        return RefreshIndicator(
          onRefresh: () async {
            await ref
                .read(conversationsViewModelProvider.notifier)
                .loadConversations();
          },
          child: ListView.builder(
            controller: _scrollController,
            itemCount: conversations.length,
            itemBuilder: (context, index) {
              final conversation = conversations[index];
              final displayName = conversation.getDisplayName();
              final displayImageKey = conversation.getDisplayImageKey();
              final isUnread = conversation.unseenCount > 0;

              final messageTime =
                  conversation.lastMessageTime ?? conversation.updatedAt;
              final timeAgo = timeago.format(messageTime, locale: 'en_short');

              final displayMessage = _getDisplayMessage(
                conversation.lastMessageContent,
                conversation.lastMessageType,
              );

              final username = conversation.isDMChat
                  ? (conversation.dmPartnerUsername ?? '')
                  : '';

              final recipientId = conversation.isDMChat
                  ? (conversation.dmPartnerUserId ?? '')
                  : conversation.id;

              return ConversationTile(
                recipientId: recipientId,
                chatId: conversation.id,
                name: displayName,
                username: username,
                message: displayMessage,
                time: timeAgo,
                avatarUrl: displayImageKey,
                isUnread: isUnread,
                unseenCount: conversation.unseenCount,
                isDMChat: conversation.isDMChat,
              );
            },
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 30, color: Palette.greycolor),
            const SizedBox(height: 16),
            Text(
              'Error loading conversations',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () {
                ref
                    .read(conversationsViewModelProvider.notifier)
                    .loadConversations();
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
