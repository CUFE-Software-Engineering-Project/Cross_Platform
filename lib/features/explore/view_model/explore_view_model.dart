import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'explore_state.dart';
import '../models/trend_model.dart';
import '../models/suggested_tweet_model.dart';
import '../models/who_to_follow_model.dart';

part 'explore_view_model.g.dart';

@Riverpod(keepAlive: true)
class ExploreViewModel extends _$ExploreViewModel {
  @override
  ExploreState build() {
    // Load initial data
    _loadTrendingData();
    return const ExploreState();
  }

  Future<void> _loadTrendingData() async {
    state = state.copyWith(isLoading: true);
    
    // Simulate API call - replace with actual API call
    await Future.delayed(const Duration(milliseconds: 100));
    
    // Mock data - replace with actual API response
    final mockTrends = _getMockTrends();
    final mockSuggestedTweets = _getMockSuggestedTweets();
    
    if (state.selectedCategory == ExploreCategory.forYou) {
      // For "For You" tab, load special sections
      final todaysNews = _getTodaysNews();
      final trendingInCountry = _getTrendingInCountry();
      final whoToFollow = _getWhoToFollow();
      final categoryNews = _getCategoryNews();
      
      state = state.copyWith(
        isLoading: false,
        todaysNews: todaysNews,
        trendingInCountry: trendingInCountry,
        whoToFollow: whoToFollow,
        categoryNews: categoryNews,
      );
    } else {
      state = state.copyWith(
        isLoading: false,
        trends: mockTrends,
        suggestedTweets: mockSuggestedTweets,
      );
    }
  }

  void selectCategory(ExploreCategory category) {
    state = state.copyWith(selectedCategory: category);
    // Reload data based on category
    _loadTrendingData();
  }

  List<TrendModel> _getMockTrends() {
    final currentCategory = state.selectedCategory;
    
    // Return enhanced cards for Entertainment, Sports, and News
    if (currentCategory == ExploreCategory.entertainment ||
        currentCategory == ExploreCategory.sports ||
        currentCategory == ExploreCategory.news) {
      if (currentCategory == ExploreCategory.entertainment) {
        return [
          TrendModel(
            id: '1',
            title: 'Halloween',
            category: 'Entertainment',
            postCount: 165000,
            isHashtag: true,
            headline: 'X Platform Hits 1.1 Million Engagements in Global Halloween Festivities',
            avatarUrls: const ['', '', ''],
            timestamp: '7 hours ago',
            imageUrl: null,
          ),
          TrendModel(
            id: '2',
            title: 'TaylorSwift',
            category: 'Entertainment',
            postCount: 52100,
            isHashtag: true,
            headline: 'Taylor Swift Breaks Record with Latest Album Release',
            avatarUrls: const ['', '', ''],
            timestamp: '3 hours ago',
            imageUrl: null,
          ),
          const TrendModel(
            id: '3',
            title: 'Movie Premiere',
            category: 'Entertainment',
            postCount: 89300,
            isHashtag: false,
            headline: 'New Blockbuster Movie Premiere Creates Social Media Buzz',
            avatarUrls: ['', '', ''],
            timestamp: '5 hours ago',
          ),
        ];
      } else if (currentCategory == ExploreCategory.sports) {
        return [
          TrendModel(
            id: '1',
            title: 'World Cup',
            category: 'Sports',
            postCount: 523000,
            isHashtag: true,
            headline: 'World Cup Final Breaks Viewership Records Across the Globe',
            avatarUrls: const ['', '', ''],
            timestamp: '2 hours ago',
            imageUrl: null,
          ),
          TrendModel(
            id: '2',
            title: 'Football',
            category: 'Sports',
            postCount: 234500,
            isHashtag: true,
            headline: 'Major League Match Results Spark Intense Discussions',
            avatarUrls: const ['', '', ''],
            timestamp: '1 hour ago',
            imageUrl: null,
          ),
          const TrendModel(
            id: '3',
            title: 'Basketball',
            category: 'Sports',
            postCount: 178900,
            isHashtag: false,
            headline: 'NBA Championship Game Draws Millions of Viewers',
            avatarUrls: ['', '', ''],
            timestamp: '4 hours ago',
          ),
        ];
      } else if (currentCategory == ExploreCategory.news) {
        return [
          TrendModel(
            id: '1',
            title: 'Breaking News',
            category: 'News',
            postCount: 892000,
            isHashtag: false,
            headline: 'Global Summit Addresses Climate Change Crisis',
            avatarUrls: const ['', '', ''],
            timestamp: '30 minutes ago',
            imageUrl: null,
          ),
          TrendModel(
            id: '2',
            title: 'Technology',
            category: 'News',
            postCount: 234000,
            isHashtag: false,
            headline: 'New Tech Innovation Revolutionizes Industry Standards',
            avatarUrls: const ['', '', ''],
            timestamp: '6 hours ago',
            imageUrl: null,
          ),
          const TrendModel(
            id: '3',
            title: 'Climate Change',
            category: 'News',
            postCount: 45300,
            isHashtag: false,
            headline: 'Scientists Warn of Accelerating Environmental Changes',
            avatarUrls: ['', '', ''],
            timestamp: '8 hours ago',
          ),
        ];
      }
    }
    
    // Default trends for For You and Trending
    return [
      const TrendModel(
        id: '1',
        title: 'TaylorSwift',
        category: 'Music',
        postCount: 52100,
        isHashtag: true,
      ),
      const TrendModel(
        id: '2',
        title: 'Bitcoin',
        category: 'Finance',
        postCount: 29300,
        isHashtag: true,
      ),
      const TrendModel(
        id: '3',
        title: 'Flutter',
        category: 'Technology',
        location: 'United States',
        postCount: 15420,
        isHashtag: true,
      ),
      const TrendModel(
        id: '4',
        title: 'AI Development',
        category: 'Technology',
        postCount: 87600,
        isHashtag: false,
      ),
      const TrendModel(
        id: '5',
        title: 'Football',
        category: 'Sports',
        location: 'Worldwide',
        postCount: 234500,
        isHashtag: true,
      ),
      const TrendModel(
        id: '6',
        title: 'Climate Change',
        category: 'News',
        postCount: 45300,
        isHashtag: false,
      ),
    ];
  }

  List<SuggestedTweetModel> _getMockSuggestedTweets() {
    return [
      const SuggestedTweetModel(
        id: '1',
        username: 'Tech News',
        handle: '@technews',
        avatarUrl: '',
        isVerified: true,
        content: 'Breaking: New Flutter 3.0 update brings exciting features to mobile development! 🚀',
        imageUrl: null,
        replyCount: 124,
        repostCount: 456,
        likeCount: 2340,
        shareCount: 89,
        timestamp: '2h',
        trendContext: 'People also tweeting about this',
      ),
      const SuggestedTweetModel(
        id: '2',
        username: 'Music Daily',
        handle: '@musicdaily',
        avatarUrl: '',
        content: 'Taylor Swift\'s latest album breaking all records! 🎵',
        replyCount: 89,
        repostCount: 234,
        likeCount: 5670,
        shareCount: 123,
        timestamp: '3h',
      ),
    ];
  }

  // For "For You" tab sections
  List<TrendModel> _getTodaysNews() {
    return [
      TrendModel(
        id: 'tn1',
        title: 'Breaking News',
        category: 'News',
        postCount: 892000,
        isHashtag: false,
        headline: 'Global Summit Addresses Climate Change Crisis with New Agreements',
        avatarUrls: const ['', '', ''],
        timestamp: '30 minutes ago',
        imageUrl: null,
      ),
      TrendModel(
        id: 'tn2',
        title: 'Technology',
        category: 'News',
        postCount: 234000,
        isHashtag: false,
        headline: 'New Tech Innovation Revolutionizes Industry Standards Worldwide',
        avatarUrls: const ['', '', ''],
        timestamp: '2 hours ago',
        imageUrl: null,
      ),
    ];
  }

  List<TrendModel> _getTrendingInCountry() {
    return [
      const TrendModel(
        id: 'tc1',
        title: 'TaylorSwift',
        category: 'Music',
        location: 'United States',
        postCount: 52100,
        isHashtag: true,
      ),
      const TrendModel(
        id: 'tc2',
        title: 'Bitcoin',
        category: 'Finance',
        location: 'United States',
        postCount: 29300,
        isHashtag: true,
      ),
      const TrendModel(
        id: 'tc3',
        title: 'Flutter',
        category: 'Technology',
        location: 'United States',
        postCount: 15420,
        isHashtag: true,
      ),
    ];
  }

  List<WhoToFollowModel> _getWhoToFollow() {
    return [
      const WhoToFollowModel(
        id: 'wtf1',
        displayName: 'Tech Innovations',
        username: 'techinnovations',
        bio: 'Latest technology news and innovations • Follow for daily tech updates',
        avatarUrl: '',
        isVerified: true,
        isFollowing: false,
      ),
      const WhoToFollowModel(
        id: 'wtf2',
        displayName: 'Design Daily',
        username: 'designdaily',
        bio: 'UI/UX design inspiration and tips • Designer community',
        avatarUrl: '',
        isVerified: false,
        isFollowing: false,
      ),
      const WhoToFollowModel(
        id: 'wtf3',
        displayName: 'Code Master',
        username: 'codemaster',
        bio: 'Programming tips and tutorials • Helping developers grow',
        avatarUrl: '',
        isVerified: true,
        isFollowing: true,
      ),
    ];
  }

  Map<String, List<SuggestedTweetModel>> _getCategoryNews() {
    return {
      'Business': [
        const SuggestedTweetModel(
          id: 'cn1',
          username: 'Business Insider',
          handle: '@businessinsider',
          avatarUrl: '',
          isVerified: true,
          content: 'Stock markets reach all-time high as investors gain confidence in economic recovery 📈',
          imageUrl: null,
          replyCount: 456,
          repostCount: 1234,
          likeCount: 8900,
          shareCount: 234,
          timestamp: '1h',
        ),
        const SuggestedTweetModel(
          id: 'cn2',
          username: 'Financial Times',
          handle: '@financialtimes',
          avatarUrl: '',
          content: 'Major merger announced between tech giants, reshaping the industry landscape',
          imageUrl: null,
          replyCount: 234,
          repostCount: 567,
          likeCount: 3450,
          shareCount: 123,
          timestamp: '3h',
        ),
      ],
      'Sports': [
        const SuggestedTweetModel(
          id: 'cn3',
          username: 'ESPN',
          handle: '@espn',
          avatarUrl: '',
          isVerified: true,
          content: 'Incredible comeback victory in the championship game! 🏆 One for the history books!',
          imageUrl: null,
          replyCount: 1234,
          repostCount: 5678,
          likeCount: 45600,
          shareCount: 890,
          timestamp: '30m',
        ),
        const SuggestedTweetModel(
          id: 'cn4',
          username: 'Sports Central',
          handle: '@sportscentral',
          avatarUrl: '',
          content: 'Breaking: Record-breaking performance at the Olympics today! 🥇',
          imageUrl: null,
          replyCount: 789,
          repostCount: 2345,
          likeCount: 12300,
          shareCount: 456,
          timestamp: '2h',
        ),
      ],
      'Entertainment': [
        const SuggestedTweetModel(
          id: 'cn5',
          username: 'Entertainment Weekly',
          handle: '@entertainmentweekly',
          avatarUrl: '',
          isVerified: true,
          content: 'New blockbuster movie breaks box office records on opening weekend! 🎬',
          imageUrl: null,
          replyCount: 567,
          repostCount: 1234,
          likeCount: 8900,
          shareCount: 345,
          timestamp: '4h',
        ),
        const SuggestedTweetModel(
          id: 'cn6',
          username: 'Music News',
          handle: '@musicnews',
          avatarUrl: '',
          content: 'Major artist announces world tour dates - tickets selling fast! 🎵',
          imageUrl: null,
          replyCount: 123,
          repostCount: 456,
          likeCount: 2340,
          shareCount: 89,
          timestamp: '5h',
        ),
      ],
    };
  }

  void toggleFollow(String userId) {
    final updatedWhoToFollow = state.whoToFollow.map((user) {
      if (user.id == userId) {
        return user.copyWith(isFollowing: !user.isFollowing);
      }
      return user;
    }).toList();

    state = state.copyWith(whoToFollow: updatedWhoToFollow);
  }
}

