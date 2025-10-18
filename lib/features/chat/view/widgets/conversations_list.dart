// ignore_for_file: dead_code

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lite_x/features/chat/view/widgets/conversation_tile.dart';
import 'package:lite_x/features/chat/view/widgets/empty_inbox.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class ConversationsList extends ConsumerWidget {
  const ConversationsList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasConversations = true;
    if (!hasConversations) {
      return const EmptyInbox();
    }

    final itemScrollController = ItemScrollController();
    final itemPositionsListener = ItemPositionsListener.create();

    return ScrollablePositionedList.builder(
      itemScrollController: itemScrollController,
      itemPositionsListener: itemPositionsListener,
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
