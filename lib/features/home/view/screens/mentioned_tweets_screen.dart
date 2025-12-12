import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../view_model/mentioned_tweets_state.dart';
import '../../view_model/mentioned_tweets_view_model.dart';
import '../widgets/tweet_widget.dart';

class MentionedTweetsScreen extends ConsumerStatefulWidget {
  final String username;

  const MentionedTweetsScreen({super.key, required this.username});

  @override
  ConsumerState<MentionedTweetsScreen> createState() =>
      _MentionedTweetsScreenState();
}

class _MentionedTweetsScreenState extends ConsumerState<MentionedTweetsScreen> {
  final ScrollController _scrollController = ScrollController();

  String get cleanUsername => widget.username.replaceFirst('@', '');

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      // Load more when user is 200px from bottom
      ref
          .read(mentionedTweetsViewModelProvider(cleanUsername).notifier)
          .loadMoreTweets();
    }
  }

  Future<void> _onRefresh() async {
    await ref
        .read(mentionedTweetsViewModelProvider(cleanUsername).notifier)
        .refresh();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(mentionedTweetsViewModelProvider(cleanUsername));

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '@$cleanUsername mentions',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (!state.isLoading && state.tweets.isNotEmpty)
              Text(
                '${state.tweets.length} ${state.tweets.length == 1 ? 'tweet' : 'tweets'}',
                style: TextStyle(color: Colors.grey[600], fontSize: 13),
              ),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        backgroundColor: const Color(0xFF1E1E1E),
        color: const Color(0xFF1DA1F2),
        child: _buildBody(state),
      ),
    );
  }

  Widget _buildBody(MentionedTweetsState state) {
    if (state.isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1DA1F2)),
        ),
      );
    }

    if (state.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.grey[600]),
            const SizedBox(height: 16),
            Text(
              'Failed to load mentions',
              style: TextStyle(color: Colors.grey[400], fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              state.error!,
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _onRefresh,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1DA1F2),
                foregroundColor: Colors.white,
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (state.tweets.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.alternate_email, size: 64, color: Colors.grey[800]),
            const SizedBox(height: 16),
            Text(
              'No mentions found',
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'There are no tweets mentioning @$cleanUsername',
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      itemCount: state.tweets.length + (state.isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == state.tweets.length) {
          return const Padding(
            padding: EdgeInsets.all(16.0),
            child: Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1DA1F2)),
              ),
            ),
          );
        }

        final tweet = state.tweets[index];
        return TweetWidget(
          tweetId: tweet.id,
          userDisplayName: tweet.authorName,
          username: tweet.authorUsername,
          timeAgo: _formatTimeAgo(tweet.createdAt),
          content: tweet.content,
          avatarUrl: tweet.authorAvatar,
          mediaUrls: tweet.images,
          retweetedByUsernames: tweet.retweetedByUsernames,
          replyCount: tweet.replies,
          retweetCount: tweet.retweets,
          likeCount: tweet.likes,
          shareCount: 0,
          reachCount: 0,
          isSaved: tweet.isBookmarked,
          isLiked: tweet.isLiked,
          isRetweeted: tweet.isRetweeted,
          onTap: () {
            // Navigate to tweet detail
          },
        );
      },
    );
  }

  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()}y';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()}mo';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m';
    } else {
      return 'now';
    }
  }
}
