// ignore_for_file: dead_code

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lite_x/features/chat/view/widgets/conversation_tile.dart';
import 'package:lite_x/features/chat/view/widgets/empty_inbox.dart';

class ConversationsList extends ConsumerWidget {
  const ConversationsList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // final conversationsAsync = ref.watch(conversationsProvider);
    final hasConversations = true;
    if (!hasConversations) {
      return const EmptyInbox();
    }
    return ListView.builder(
      itemCount: 2, //conversations.length
      itemBuilder: (context, index) {
        // final conversation = conversations[index];
        return ConversationTile(
          name: 'NORTH MAN',
          username: 'NORTHMAN750',
          message: 'Fine and you',
          time: '30s',
          isUnread: false,
        );
      },
    );
  }
}
