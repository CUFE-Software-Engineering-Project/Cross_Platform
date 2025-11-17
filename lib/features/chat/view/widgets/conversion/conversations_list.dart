// ignore_for_file: dead_code

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lite_x/features/chat/view/widgets/conversion/conversation_tile.dart';
import 'package:lite_x/features/chat/view/widgets/conversion/empty_inbox.dart';

class ConversationsList extends ConsumerStatefulWidget {
  const ConversationsList({super.key});

  @override
  ConsumerState<ConversationsList> createState() => _ConversationsListState();
}

class _ConversationsListState extends ConsumerState<ConversationsList> {
  final ScrollController _scrollController = ScrollController();
  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasConversations = true;

    if (!hasConversations) {
      return const EmptyInbox();
    }

    return ListView.builder(
      controller: _scrollController,
      reverse: true,
      itemCount: 20,
      itemBuilder: (context, index) {
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
