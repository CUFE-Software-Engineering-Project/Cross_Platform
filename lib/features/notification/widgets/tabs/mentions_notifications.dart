import 'package:flutter/material.dart';
import '../../models/notification.dart';
import 'mock_data.dart';
import 'package:lite_x/core/theme/palette.dart';
import '../empty/mention_empty.dart';
import '../card/mentions_tweet_card.dart'; // Import our MentionTweetCard

class MentionsTab extends StatefulWidget {
  const MentionsTab({super.key});

  @override
  State<MentionsTab> createState() => _MentionsTabState();
}

class _MentionsTabState extends State<MentionsTab>
    with AutomaticKeepAliveClientMixin {
  final List<AppNotification> _mentions = mentionsNotifications;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Container(
      color: Palette.background,
      child: _mentions.isEmpty
          ? const MentionsEmptyStateWidget()
          : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              itemCount: _mentions.length,
              itemBuilder: (context, index) {
                return MentionTweetCard(notification: _mentions[index]);
              },
            ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
