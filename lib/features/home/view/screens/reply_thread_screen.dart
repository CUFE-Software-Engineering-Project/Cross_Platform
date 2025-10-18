import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lite_x/data/mock_tweets.dart';
import 'package:lite_x/features/home/models/tweet_model.dart';
import 'package:lite_x/features/home/view/screens/reply_composer_screen.dart';
import 'package:timeago/timeago.dart' as timeago;

/// ReplyThreadScreen
///
/// Renders a thread path given by [pathTweetIds]. The list should contain
/// all tweet ids the user clicked through to reach the current reply.
/// Layout:
/// - First id (index 0): main post (timeline-style card)
/// - Middle ids (1..n-2): compact reply cards
/// - Last id (n-1): current reply shown in full detail (as in screenshot)
/// - Optional: children replies of the current reply under "Most relevant replies"
class ReplyThreadScreen extends StatefulWidget {
  final List<String> pathTweetIds;

  const ReplyThreadScreen({super.key, required this.pathTweetIds});

  @override
  State<ReplyThreadScreen> createState() => _ReplyThreadScreenState();
}

class _ReplyThreadScreenState extends State<ReplyThreadScreen> {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _currentReplyKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    // Scroll to current reply after the frame is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToCurrentReply();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToCurrentReply() {
    final context = _currentReplyKey.currentContext;
    if (context != null) {
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        alignment: 0.2, // Position reply at 20% from top of screen
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final tweets = widget.pathTweetIds
        .map((id) => mockTweets[id])
        .where((t) => t != null)
        .cast<TweetModel>()
        .toList();

    if (tweets.isEmpty) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Text(
            'Thread not found',
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }

    final mainTweet = tweets.first;
    final currentReply = tweets.last;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Post',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.ios_share, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: ListView(
        controller: _scrollController,
        children: [
          // Main post
          _buildTimelineTweetCard(mainTweet),
          const Divider(color: Color(0xFF2F3336), height: 1),

          // Middle ancestors (excluding first and last)
          for (int i = 1; i < tweets.length - 1; i++) ...[
            _buildCompactReply(
              context,
              tweets[i],
              replyingTo: tweets[i - 1].authorUsername,
              pathSoFar: widget.pathTweetIds.sublist(0, i + 1),
            ),
            const Divider(color: Color(0xFF2F3336), height: 1),
          ],

          // Current reply in full detail (with key for auto-scroll)
          Container(
            key: _currentReplyKey,
            child: _buildCurrentReplyDetail(
              currentReply,
              replyingTo: tweets.length > 1
                  ? tweets[tweets.length - 2].authorUsername
                  : null,
            ),
          ),
          const Divider(color: Color(0xFF2F3336), height: 1),

          // Children replies header
          if (currentReply.replyIds.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Text(
                'Most relevant replies',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ),

          // Children replies (compact)
          ...currentReply.replyIds
              .map((id) => mockTweets[id])
              .where((t) => t != null)
              .cast<TweetModel>()
              .map(
                (r) => Column(
                  children: [
                    _buildCompactReply(
                      context,
                      r,
                      replyingTo: currentReply.authorUsername,
                      pathSoFar: [...widget.pathTweetIds, r.id],
                    ),
                    const Divider(color: Color(0xFF2F3336), height: 1),
                  ],
                ),
              ),
          const SizedBox(height: 60),
        ],
      ),
      bottomNavigationBar: _buildReplyBar(),
    );
  }

  // Timeline-style main tweet card (with large media support)
  Widget _buildTimelineTweetCard(TweetModel tweet) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 20,
                backgroundImage: NetworkImage(tweet.authorAvatar),
                backgroundColor: Colors.grey[800],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            tweet.authorName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.verified,
                          color: Colors.blue,
                          size: 18,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          tweet.authorUsername,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '· ${timeago.format(tweet.createdAt, locale: 'en_short')}',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      tweet.content,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.more_horiz, color: Colors.grey[600], size: 18),
            ],
          ),
          if (tweet.images.isNotEmpty) ...[
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                tweet.images.first,
                width: double.infinity,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    height: 200,
                    color: Colors.grey[900],
                    child: const Center(
                      child: CircularProgressIndicator(color: Colors.blue),
                    ),
                  );
                },
              ),
            ),
          ],
          const SizedBox(height: 12),
          _inlineActions(tweet),
        ],
      ),
    );
  }

  // Compact reply used for ancestors and children
  Widget _buildCompactReply(
    BuildContext context,
    TweetModel reply, {
    required String replyingTo,
    required List<String> pathSoFar,
  }) {
    return InkWell(
      onTap: () {
        // Drill-down: open a new thread screen with extended path
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ReplyThreadScreen(pathTweetIds: pathSoFar),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 20,
              backgroundImage: NetworkImage(reply.authorAvatar),
              backgroundColor: Colors.grey[800],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          reply.authorName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        reply.authorUsername,
                        style: TextStyle(color: Colors.grey[600], fontSize: 15),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '· ${timeago.format(reply.createdAt, locale: 'en_short')}',
                        style: TextStyle(color: Colors.grey[600], fontSize: 15),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Text(
                        'Replying to ',
                        style: TextStyle(color: Colors.grey[600], fontSize: 15),
                      ),
                      Text(
                        replyingTo,
                        style: const TextStyle(
                          color: Colors.blue,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    reply.content,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      height: 1.4,
                    ),
                  ),
                  if (reply.images.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        reply.images.first,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  _inlineActions(reply),
                ],
              ),
            ),
            Icon(Icons.more_horiz, color: Colors.grey[600], size: 18),
          ],
        ),
      ),
    );
  }

  // Full-detail current reply
  Widget _buildCurrentReplyDetail(TweetModel tweet, {String? replyingTo}) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 24,
                backgroundImage: NetworkImage(tweet.authorAvatar),
                backgroundColor: Colors.grey[800],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            tweet.authorName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.verified,
                          color: Colors.blue,
                          size: 18,
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      tweet.authorUsername,
                      style: TextStyle(color: Colors.grey[600], fontSize: 15),
                    ),
                  ],
                ),
              ),
              _followPill(),
              const SizedBox(width: 6),
              Icon(Icons.more_horiz, color: Colors.grey[600], size: 18),
            ],
          ),
          if (replyingTo != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  'Replying to ',
                  style: TextStyle(color: Colors.grey[600], fontSize: 15),
                ),
                Text(
                  replyingTo,
                  style: const TextStyle(color: Colors.blue, fontSize: 15),
                ),
              ],
            ),
          ],
          const SizedBox(height: 12),
          Text(
            tweet.content,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              height: 1.4,
            ),
          ),
          if (tweet.images.isNotEmpty) ...[
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                tweet.images.first,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          ],
          const SizedBox(height: 16),
          _timestampWithViews(tweet),
          const Divider(color: Color(0xFF2F3336), height: 1),
          _replyStats(tweet),
          const Divider(color: Color(0xFF2F3336), height: 1),
          _actionButtons(tweet),
        ],
      ),
    );
  }

  Widget _inlineActions(TweetModel t) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _miniAction(
          Icons.chat_bubble_outline,
          t.replies > 0 ? t.replies.toString() : '',
        ),
        _miniAction(
          Icons.repeat,
          t.retweets > 0 ? _formatNumber(t.retweets) : '',
        ),
        _miniAction(
          t.isLiked ? Icons.favorite : Icons.favorite_border,
          t.likes > 0 ? _formatNumber(t.likes) : '',
          color: t.isLiked ? Colors.pink : null,
        ),
        _miniAction(Icons.bar_chart_outlined, ''),
        _miniAction(Icons.ios_share, ''),
      ],
    );
  }

  Widget _miniAction(IconData icon, String count, {Color? color}) {
    return Row(
      children: [
        Icon(icon, color: color ?? Colors.grey[600], size: 16),
        if (count.isNotEmpty) ...[
          const SizedBox(width: 4),
          Text(count, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
        ],
      ],
    );
  }

  Widget _followPill() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Text(
        'Follow',
        style: TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
          fontSize: 15,
        ),
      ),
    );
  }

  Widget _timestampWithViews(TweetModel t) {
    final formattedTime = DateFormat('h:mm a · d MMM yy').format(t.createdAt);
    final views = 598; // mock per screenshot

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Text(
            formattedTime,
            style: TextStyle(color: Colors.grey[600], fontSize: 15),
          ),
          const SizedBox(width: 4),
          Text('·', style: TextStyle(color: Colors.grey[600])),
          const SizedBox(width: 4),
          Text(
            '${_formatNumber(views)} Views',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _replyStats(TweetModel t) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _statItem(_formatStat(t.likes), 'Likes'),
              const SizedBox(width: 16),
              _statItem(_formatStat(3), 'Bookmarks'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statItem(String value, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
        const SizedBox(width: 4),
        Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 15)),
      ],
    );
  }

  Widget _actionButtons(TweetModel t) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _iconButton(
            icon: Icons.chat_bubble_outline,
            color: Colors.grey[600]!,
            onTap: () {},
          ),
          _iconButton(
            icon: Icons.repeat,
            color: t.isRetweeted ? Colors.green : Colors.grey[600]!,
            onTap: () {},
          ),
          _iconButton(
            icon: t.isLiked ? Icons.favorite : Icons.favorite_border,
            color: t.isLiked ? Colors.pink : Colors.grey[600]!,
            onTap: () {},
          ),
          _iconButton(
            icon: Icons.bookmark_border,
            color: Colors.grey[600]!,
            onTap: () {},
          ),
          _iconButton(
            icon: Icons.ios_share,
            color: Colors.grey[600]!,
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _iconButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Icon(icon, color: color, size: 20),
      ),
    );
  }

  Widget _buildReplyBar() {
    final currentReply = widget.pathTweetIds.isNotEmpty
        ? mockTweets[widget.pathTweetIds.last]
        : null;

    return SafeArea(
      child: GestureDetector(
        onTap: currentReply != null
            ? () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        ReplyComposerScreen(replyingToTweet: currentReply),
                  ),
                );
              }
            : null,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.black,
            border: Border(
              top: BorderSide(color: Colors.grey[900]!, width: 0.5),
            ),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: Colors.blue,
                child: const Icon(Icons.person, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Post your reply',
                  style: TextStyle(color: Colors.grey[600], fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }

  String _formatStat(int number) {
    if (number < 10000) {
      return NumberFormat.decimalPattern().format(number);
    }
    return _formatNumber(number);
  }
}
