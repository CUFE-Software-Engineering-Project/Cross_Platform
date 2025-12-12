import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lite_x/core/theme/Palette.dart';
import '../view_model/explore_view_model.dart';
import '../view_model/explore_state.dart';
import '../widgets/explore_nav_bar.dart';
import '../widgets/category_tabs.dart';
import '../widgets/trend_card.dart';
import '../widgets/enhanced_trend_card.dart';
import '../widgets/suggested_tweet_card.dart';
import '../widgets/who_to_follow_card.dart';
import '../models/trend_model.dart';
import '../models/suggested_tweet_model.dart';
import '../models/who_to_follow_model.dart';

enum _ForYouItemType {
  header,
  divider,
  todayNews,
  trendingCountry,
  whoToFollow,
  categoryTweet,
}

class _ForYouItem {
  final _ForYouItemType type;
  final String? title;
  final TrendModel? trend;
  final SuggestedTweetModel? tweet;
  final WhoToFollowModel? user;

  _ForYouItem._({
    required this.type,
    this.title,
    this.trend,
    this.tweet,
    this.user,
  });

  factory _ForYouItem.header(String title) =>
      _ForYouItem._(type: _ForYouItemType.header, title: title);
  factory _ForYouItem.divider() => _ForYouItem._(type: _ForYouItemType.divider);
  factory _ForYouItem.todayNews(TrendModel trend) =>
      _ForYouItem._(type: _ForYouItemType.todayNews, trend: trend);
  factory _ForYouItem.trendingCountry(TrendModel trend) =>
      _ForYouItem._(type: _ForYouItemType.trendingCountry, trend: trend);
  factory _ForYouItem.whoToFollow(WhoToFollowModel user) =>
      _ForYouItem._(type: _ForYouItemType.whoToFollow, user: user);
  factory _ForYouItem.categoryTweet(
    String category,
    SuggestedTweetModel tweet,
  ) => _ForYouItem._(type: _ForYouItemType.categoryTweet, tweet: tweet);
}

class ExploreScreen extends ConsumerWidget {
  const ExploreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(exploreViewModelProvider);
    final viewModel = ref.read(exploreViewModelProvider.notifier);

    return Scaffold(
      backgroundColor: Palette.background,
      body: Column(
        children: [
          // Top Navigation Bar - Sticky
          const ExploreNavBar(),
          // Category Tabs - Sticky
          CategoryTabs(
            selectedCategory: state.selectedCategory,
            onCategorySelected: (category) {
              viewModel.selectCategory(category);
            },
          ),
          // Content
          Expanded(
            child: state.isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Palette.primary),
                  )
                : state.error != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          color: Palette.error,
                          size: 48,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          state.error!,
                          style: const TextStyle(
                            color: Palette.textSecondary,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            // Retry loading
                          },
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  )
                : state.selectedCategory == ExploreCategory.forYou
                ? _buildForYouContent(state, viewModel)
                : _buildContent(state, viewModel),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(ExploreState state, ExploreViewModel viewModel) {
    // Trending tab should only show trend cards, no suggested tweets
    final isTrendingTab = state.selectedCategory == ExploreCategory.trending;

    // Show suggested tweets after 5-6 trend cards (but not for Trending tab)
    const int trendsBeforeTweets = 5;
    final showTweetsSection =
        !isTrendingTab &&
        state.trends.length >= trendsBeforeTweets &&
        state.suggestedTweets.isNotEmpty;

    return ListView.builder(
      cacheExtent: 500,
      addAutomaticKeepAlives: false,
      addRepaintBoundaries: true,
      itemCount:
          state.trends.length +
          (showTweetsSection
              ? state.suggestedTweets.length + 1
              : 0), // +1 for header
      itemBuilder: (context, index) {
        // Show trends first (up to trendsBeforeTweets)
        if (index < state.trends.length) {
          // Insert suggested tweets section after 5 trends
          if (index == trendsBeforeTweets && showTweetsSection) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Section header
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Palette.divider, width: 1),
                    ),
                  ),
                  child: const Text(
                    'You might like',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Palette.textPrimary,
                    ),
                  ),
                ),
                // First suggested tweet
                SuggestedTweetCard(tweet: state.suggestedTweets[0]),
              ],
            );
          }

          final trend = state.trends[index];
          // Use enhanced card only for Entertainment, Sports, and News categories
          // Trending tab should only show regular trend cards
          final useEnhancedCard =
              state.selectedCategory != ExploreCategory.trending &&
              (state.selectedCategory == ExploreCategory.entertainment ||
                  state.selectedCategory == ExploreCategory.sports ||
                  state.selectedCategory == ExploreCategory.news);

          if (useEnhancedCard &&
              (trend.headline != null || trend.avatarUrls != null)) {
            return EnhancedTrendCard(
              key: ValueKey('enhanced_trend_${trend.id}'),
              trend: trend,
              onTap: () {
                // Navigate to trend timeline
              },
            );
          }

          return TrendCard(
            key: ValueKey('trend_${trend.id}'),
            trend: trend,
            onTap: () {
              // Navigate to trend timeline
            },
          );
        }

        // Show remaining suggested tweets
        if (showTweetsSection) {
          final tweetIndex = index - state.trends.length - 1; // -1 for header
          if (tweetIndex >= 0 && tweetIndex < state.suggestedTweets.length) {
            return SuggestedTweetCard(
              key: ValueKey(
                'suggested_tweet_${state.suggestedTweets[tweetIndex].id}',
              ),
              tweet: state.suggestedTweets[tweetIndex],
            );
          }
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildForYouContent(ExploreState state, ExploreViewModel viewModel) {
    // Build list of all items with their types for efficient building
    // This is cached and only rebuilt when state changes
    final items = <_ForYouItem>[];

    // Section 1: Today's News
    if (state.todaysNews.isNotEmpty) {
      items.add(_ForYouItem.header('Today\'s News'));
      for (var trend in state.todaysNews) {
        items.add(_ForYouItem.todayNews(trend));
      }
      items.add(_ForYouItem.divider());
    }

    // Section 2: Trending in Country
    if (state.trendingInCountry.isNotEmpty) {
      items.add(_ForYouItem.header('Trending in United States'));
      for (var trend in state.trendingInCountry) {
        items.add(_ForYouItem.trendingCountry(trend));
      }
      items.add(_ForYouItem.divider());
    }

    // Section 3: Who to Follow
    if (state.whoToFollow.isNotEmpty) {
      items.add(_ForYouItem.header('Who to follow'));
      for (var user in state.whoToFollow) {
        items.add(_ForYouItem.whoToFollow(user));
      }
      items.add(_ForYouItem.divider());
    }

    // Section 4: Category News
    for (var entry in state.categoryNews.entries) {
      items.add(_ForYouItem.header('${entry.key} News'));
      for (var tweet in entry.value) {
        items.add(_ForYouItem.categoryTweet(entry.key, tweet));
      }
      items.add(_ForYouItem.divider());
    }

    return ListView.builder(
      cacheExtent: 500,
      addAutomaticKeepAlives: false,
      addRepaintBoundaries: true,
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        switch (item.type) {
          case _ForYouItemType.header:
            return _buildSectionHeader(item.title!);
          case _ForYouItemType.divider:
            return _buildSectionDivider();
          case _ForYouItemType.todayNews:
            return EnhancedTrendCard(
              key: ValueKey('today_news_${item.trend!.id}'),
              trend: item.trend!,
              onTap: () {},
            );
          case _ForYouItemType.trendingCountry:
            return TrendCard(
              key: ValueKey('trending_${item.trend!.id}'),
              trend: item.trend!,
              onTap: () {},
            );
          case _ForYouItemType.whoToFollow:
            return Container(
              key: ValueKey('who_follow_${item.user!.id}'),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Palette.divider, width: 1),
                ),
              ),
              child: WhoToFollowCard(
                user: item.user!,
                onTap: () {},
                onFollowTap: (userId) {
                  viewModel.toggleFollow(userId);
                },
              ),
            );
          case _ForYouItemType.categoryTweet:
            return SuggestedTweetCard(
              key: ValueKey('category_tweet_${item.tweet!.id}'),
              tweet: item.tweet!,
              onTap: () {},
            );
        }
      },
    );
  }

  Widget _buildSectionHeader(String title) {
    return RepaintBoundary(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: Palette.divider, width: 1)),
        ),
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Palette.textPrimary,
          ),
        ),
      ),
    );
  }

  Widget _buildSectionDivider() {
    return const SizedBox(height: 12);
  }
}
