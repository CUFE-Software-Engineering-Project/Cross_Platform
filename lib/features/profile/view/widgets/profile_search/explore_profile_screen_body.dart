import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class Exploreprofilescreenbody extends ConsumerStatefulWidget {
  const Exploreprofilescreenbody({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _ExploreprofilescreenbodyState();
}

class _ExploreprofilescreenbodyState
    extends ConsumerState<Exploreprofilescreenbody> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        appBar: TabBar(
          indicatorColor: Color(0xFF1DA1F2),
          indicatorSize: TabBarIndicatorSize.label,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          dividerHeight: 0.25,
          labelColor: Colors.white,
          unselectedLabelStyle: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
          labelStyle: TextStyle(fontWeight: FontWeight.bold),
          unselectedLabelColor: Colors.grey,
          tabs: [
            Tab(text: 'For You'),
            Tab(text: 'Trending'),
            Tab(text: 'News'),
            Tab(text: 'Sports'),
            Tab(text: 'Entertainment'),
          ],
        ),
        body: TabBarView(
          children: [
            _BuildForYouTab(),
            _BuildTrendingTab(),
            _BuildNewsTab(),
            _BuildSportsTab(),
            _BuildEntertainmentTab(),
          ],
        ),
      ),
    );
  }
}

Widget _BuildForYouTab() {
  return ForYouProfileTab();
}

Widget _BuildTrendingTab() {
  return TrendingProfileTab();
}

Widget _BuildNewsTab() {
  return NewsProfileTab();
}

Widget _BuildSportsTab() {
  return SportsProfileTab();
}

Widget _BuildEntertainmentTab() {
  return EntertainmentProfileTab();
}

class ForYouProfileTab extends StatelessWidget {
  const ForYouProfileTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(0),
      children: [
        // Today's News Header
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            "Today's News",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),

        // News Card 1
        _buildNewsCard(
          title: "Ronaldo's Stunning Bicycle Kick Powers Al Nassr to 4-1 Win",
          timeAgo: "12 hours ago",
          category: "Sports",
          postsCount: "66K posts",
          avatars: 2,
        ),

        const Divider(height: 1, color: Color(0xFF2F3336)),

        // News Card 2
        _buildNewsCard(
          title: "Artistic Quranic Verses Shared in Gentle Daily Reminders",
          timeAgo: "3 hours ago",
          category: "Other",
          postsCount: "2K posts",
          avatars: 1,
        ),

        const Divider(height: 1, color: Color(0xFF2F3336)),

        // News Card 3
        _buildNewsCard(
          title: "Eze's Historic Hat-Trick Powers Arsenal to 4-1 Derby Rout",
          timeAgo: "Trending now",
          category: "Sports",
          postsCount: "3.8K posts",
          avatars: 3,
          isTrending: true,
        ),

        const Divider(height: 1, color: Color(0xFF2F3336)),

        // Trending in Egypt
        _buildTrendingSection(
          title: "Trending in Egypt",
          topic: "#صناعات",
          postsCount: null,
        ),

        const Divider(height: 1, color: Color(0xFF2F3336)),

        // Sports Trending
        _buildTrendingSection(
          title: "Sports · Trending",
          topic: "بيرنلي",
          postsCount: "9,953 posts",
        ),

        const Divider(height: 1, color: Color(0xFF2F3336)),

        // Business Trending
        _buildTrendingSection(
          title: "Trending in Business & finance",
          topic: "Substack",
          postsCount: "32.5K posts",
        ),

        const Divider(height: 1, color: Color(0xFF2F3336)),

        // Technology Trending
        _buildTrendingSection(
          title: "Trending in Technology",
          topic: "OpenAI",
          postsCount: "125K posts",
        ),

        const SizedBox(height: 80),
      ],
    );
  }

  Widget _buildNewsCard({
    required String title,
    required String timeAgo,
    required String category,
    required String postsCount,
    required int avatars,
    bool isTrending = false,
  }) {
    return Container(
      color: Colors.black,
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 12),

          // Bottom row with avatars and info
          Row(
            children: [
              // Avatar Stack
              SizedBox(
                width: avatars * 20.0 + 10,
                height: 24,
                child: Stack(
                  children: List.generate(
                    avatars,
                    (index) => Positioned(
                      left: index * 20.0,
                      child: Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.grey[800],
                          border: Border.all(color: Colors.black, width: 1.5),
                        ),
                        child: Center(
                          child: Icon(
                            Icons.person,
                            size: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Time and category info
              Expanded(
                child: Text(
                  isTrending
                      ? "$timeAgo · $category · $postsCount"
                      : "$timeAgo · $category · $postsCount",
                  style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTrendingSection({
    required String title,
    required String topic,
    String? postsCount,
  }) {
    return Container(
      color: Colors.black,
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                ),
                const SizedBox(height: 4),
                Text(
                  topic,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                if (postsCount != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    postsCount,
                    style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                  ),
                ],
              ],
            ),
          ),
          Icon(Icons.more_horiz, color: Colors.grey[600], size: 20),
        ],
      ),
    );
  }
}

class TrendingProfileTab extends StatelessWidget {
  const TrendingProfileTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(0),
      children: [
        // Trending Item 1
        _buildTrendingItem(
          position: 1,
          category: "Trending in Egypt",
          topic: "#انزل_شارك_صوتك_امانه",
          postsCount: null,
        ),

        const Divider(height: 1, color: Color(0xFF2F3336)),

        // Trending Item 2
        _buildTrendingItem(
          position: 2,
          category: "Trending in Egypt",
          topic: "#صوتك_مهم",
          postsCount: null,
        ),

        const Divider(height: 1, color: Color(0xFF2F3336)),

        // Trending Item 3
        _buildTrendingItem(
          position: 3,
          category: "Trending in Egypt",
          topic: "#صوتك_لحماه_الوطن",
          postsCount: null,
        ),

        const Divider(height: 1, color: Color(0xFF2F3336)),

        // Trending Item 4
        _buildTrendingItem(
          position: 4,
          category: "Trending in Egypt",
          topic: "#افضح_المرتزقه",
          postsCount: "3,587 posts",
        ),

        const Divider(height: 1, color: Color(0xFF2F3336)),

        // Trending Item 5
        _buildTrendingItem(
          position: 5,
          category: "Trending in Egypt",
          topic: "#في_حضوك_ياريس_انزل_وشارك",
          postsCount: null,
        ),

        const Divider(height: 1, color: Color(0xFF2F3336)),

        // Trending Item 6
        _buildTrendingItem(
          position: 6,
          category: "Trending in Egypt",
          topic: "اليوم الاتنين",
          postsCount: "5,905 posts",
        ),

        const Divider(height: 1, color: Color(0xFF2F3336)),

        // Trending Item 7
        _buildTrendingItem(
          position: 7,
          category: "Sports · Trending",
          topic: "الونسو",
          postsCount: "8,966 posts",
          trendingWith: "تشابي",
        ),

        const Divider(height: 1, color: Color(0xFF2F3336)),

        // Trending Item 8
        _buildTrendingItem(
          position: 8,
          category: "Trending in Egypt",
          topic: "رضا عبد العال",
          postsCount: null,
        ),

        const Divider(height: 1, color: Color(0xFF2F3336)),

        // Trending Item 9
        _buildTrendingItem(
          position: 9,
          category: "Trending in Egypt",
          topic: "الاهلي والزمالك",
          postsCount: "12.3K posts",
        ),

        const Divider(height: 1, color: Color(0xFF2F3336)),

        // Trending Item 10
        _buildTrendingItem(
          position: 10,
          category: "Sports · Trending",
          topic: "محمد صلاح",
          postsCount: "45.2K posts",
          trendingWith: "ليفربول",
        ),

        const SizedBox(height: 80),
      ],
    );
  }

  Widget _buildTrendingItem({
    required int position,
    required String category,
    required String topic,
    String? postsCount,
    String? trendingWith,
  }) {
    return Container(
      color: Colors.black,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Position number
          SizedBox(
            width: 30,
            child: Text(
              "$position · ",
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Category
                Text(
                  category,
                  style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                ),
                const SizedBox(height: 2),

                // Topic
                Text(
                  topic,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),

                // Posts count
                if (postsCount != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    postsCount,
                    style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                  ),
                ],

                // Trending with
                if (trendingWith != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    "Trending with $trendingWith",
                    style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                  ),
                ],
              ],
            ),
          ),

          // More options icon
          Icon(Icons.more_horiz, color: Colors.grey[600], size: 20),
        ],
      ),
    );
  }
}

class NewsProfileTab extends StatelessWidget {
  const NewsProfileTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(0),
      children: [
        // News Item 1
        _buildNewsItem(
          category: "Trending in Politics",
          topic: "Ivanka Trump",
          postsCount: "2,421 posts",
        ),

        const Divider(height: 1, color: Color(0xFF2F3336)),

        // News Item 2
        _buildNewsItem(
          category: "Trending in Business & finance",
          topic: "Substack",
          postsCount: "31.1K posts",
        ),

        const Divider(height: 1, color: Color(0xFF2F3336)),

        // News Item 3
        _buildNewsItem(
          category: "Trending in Politics",
          topic: "Taiwan to China",
          postsCount: "11.9K posts",
        ),

        const Divider(height: 1, color: Color(0xFF2F3336)),

        // News Item 4
        _buildNewsItem(
          category: "Trending in Technology",
          topic: "Grok 4.1 Fast",
          postsCount: "2,217 posts",
        ),

        const Divider(height: 1, color: Color(0xFF2F3336)),

        // News Item 5
        _buildNewsItem(
          category: "Trending in Business & finance",
          topic: "Grayscale",
          postsCount: "15.7K posts",
        ),

        const Divider(height: 1, color: Color(0xFF2F3336)),

        // News Item 6
        _buildNewsItem(
          category: "Trending in Business & finance",
          topic: "Dogecoin ETF",
          postsCount: "2,773 posts",
        ),

        const Divider(height: 1, color: Color(0xFF2F3336)),

        // News Item 7
        _buildNewsItem(
          category: "Trending in Business & finance",
          topic: "DOGE ETF",
          postsCount: "2,898 posts",
        ),

        const Divider(height: 1, color: Color(0xFF2F3336)),

        // News Item 8
        _buildNewsItem(
          category: "Trending in Politics",
          topic: "Senate Republicans",
          postsCount: "8,542 posts",
        ),

        const Divider(height: 1, color: Color(0xFF2F3336)),

        // News Item 9
        _buildNewsItem(
          category: "Trending in Technology",
          topic: "ChatGPT Plus",
          postsCount: "4,156 posts",
        ),

        const Divider(height: 1, color: Color(0xFF2F3336)),

        // News Item 10
        _buildNewsItem(
          category: "Trending in Business & finance",
          topic: "Federal Reserve",
          postsCount: "18.3K posts",
        ),

        const SizedBox(height: 80),
      ],
    );
  }

  Widget _buildNewsItem({
    required String category,
    required String topic,
    required String postsCount,
  }) {
    return Container(
      color: Colors.black,
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Category
                Text(
                  category,
                  style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                ),
                const SizedBox(height: 4),

                // Topic
                Text(
                  topic,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),

                // Posts count
                Text(
                  postsCount,
                  style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                ),
              ],
            ),
          ),

          // More options icon
          Icon(Icons.more_horiz, color: Colors.grey[600], size: 20),
        ],
      ),
    );
  }
}

class SportsProfileTab extends StatelessWidget {
  const SportsProfileTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(0),
      children: [
        // News Card 1
        _buildNewsCard(
          title: "Ronaldo's Stunning Bicycle Kick Seals Al Nassr Win at 40",
          timeAgo: "21 hours ago",
          category: "Sports",
          postsCount: "303K posts",
          avatars: 3,
        ),

        const Divider(height: 1, color: Color(0xFF2F3336)),

        // News Card 2
        _buildNewsCard(
          title: "Ronaldo's Stunning Bicycle Kick Powers Al Nassr to 4-1 Win",
          timeAgo: "13 hours ago",
          category: "Sports",
          postsCount: "66K posts",
          avatars: 3,
        ),

        const Divider(height: 1, color: Color(0xFF2F3336)),

        // News Card 3
        _buildNewsCard(
          title:
              "Messi's Masterclass Sends Inter Miami to Eastern Conference Final",
          timeAgo: "17 hours ago",
          category: "Sports",
          postsCount: "97K posts",
          avatars: 3,
        ),

        const Divider(height: 1, color: Color(0xFF2F3336)),

        // News Card 4
        _buildNewsCard(
          title: "Eze's Historic Hat-Trick Powers Arsenal to 4-1 Derby Rout",
          timeAgo: "Trending now",
          category: "Sports",
          postsCount: "4.7K posts",
          avatars: 3,
          isTrending: true,
        ),

        const Divider(height: 1, color: Color(0xFF2F3336)),

        // News Card 5
        _buildNewsCard(
          title: "Real Madrid Draw at Elche Fuels Dressing Room Tension Rumors",
          timeAgo: "4 hours ago",
          category: "Other",
          postsCount: "5.5K posts",
          avatars: 3,
        ),

        const Divider(height: 1, color: Color(0xFF2F3336)),

        // Trending Section 1
        _buildTrendingSection(
          title: "Trending in Sports",
          topic: "#IndianCricket",
          postsCount: "5,789 posts",
        ),

        const Divider(height: 1, color: Color(0xFF2F3336)),

        // Trending Section 2
        _buildTrendingSection(
          title: "Trending in Sports",
          topic: "#Champions League",
          postsCount: "12.4K posts",
        ),

        const Divider(height: 1, color: Color(0xFF2F3336)),

        // Trending Section 3
        _buildTrendingSection(
          title: "Trending in Sports",
          topic: "Lakers",
          postsCount: "8.2K posts",
        ),

        const Divider(height: 1, color: Color(0xFF2F3336)),

        // Trending Section 4
        _buildTrendingSection(
          title: "Trending in Sports",
          topic: "NBA Playoffs",
          postsCount: "15.6K posts",
        ),

        const SizedBox(height: 80),
      ],
    );
  }

  Widget _buildNewsCard({
    required String title,
    required String timeAgo,
    required String category,
    required String postsCount,
    required int avatars,
    bool isTrending = false,
  }) {
    return Container(
      color: Colors.black,
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 12),

          // Bottom row with avatars and info
          Row(
            children: [
              // Avatar Stack
              SizedBox(
                width: avatars * 20.0 + 10,
                height: 24,
                child: Stack(
                  children: List.generate(
                    avatars,
                    (index) => Positioned(
                      left: index * 20.0,
                      child: Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _getAvatarColor(index),
                          border: Border.all(color: Colors.black, width: 1.5),
                        ),
                        child: Center(
                          child: Icon(
                            Icons.person,
                            size: 14,
                            color: Colors.grey[300],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Time and category info
              Expanded(
                child: Text(
                  "$timeAgo · $category · $postsCount",
                  style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTrendingSection({
    required String title,
    required String topic,
    required String postsCount,
  }) {
    return Container(
      color: Colors.black,
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                ),
                const SizedBox(height: 4),
                Text(
                  topic,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  postsCount,
                  style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          Icon(Icons.more_horiz, color: Colors.grey[600], size: 20),
        ],
      ),
    );
  }

  Color _getAvatarColor(int index) {
    final colors = [
      Colors.blue[800]!,
      Colors.red[800]!,
      Colors.yellow[700]!,
      Colors.green[800]!,
    ];
    return colors[index % colors.length];
  }
}

class EntertainmentProfileTab extends StatelessWidget {
  const EntertainmentProfileTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(0),
      children: [
        // News Card 1
        _buildNewsCard(
          title: "New Season of Stranger Things Breaks Netflix Records",
          timeAgo: "5 hours ago",
          category: "Entertainment",
          postsCount: "156K posts",
          avatars: 3,
        ),

        const Divider(height: 1, color: Color(0xFF2F3336)),

        // News Card 2
        _buildNewsCard(
          title: "Taylor Swift Announces Surprise Album Drop at Midnight",
          timeAgo: "2 hours ago",
          category: "Music",
          postsCount: "412K posts",
          avatars: 3,
          isTrending: true,
        ),

        const Divider(height: 1, color: Color(0xFF2F3336)),

        // News Card 3
        _buildNewsCard(
          title: "Marvel Studios Reveals Phase 6 Movie Lineup",
          timeAgo: "8 hours ago",
          category: "Movies",
          postsCount: "89K posts",
          avatars: 3,
        ),

        const Divider(height: 1, color: Color(0xFF2F3336)),

        // News Card 4
        _buildNewsCard(
          title: "Grammy Awards 2025: Complete Winners List",
          timeAgo: "Trending now",
          category: "Music",
          postsCount: "287K posts",
          avatars: 3,
          isTrending: true,
        ),

        const Divider(height: 1, color: Color(0xFF2F3336)),

        // News Card 5
        _buildNewsCard(
          title: "HBO's New Drama Series Gets Renewed for Season 2",
          timeAgo: "12 hours ago",
          category: "TV Shows",
          postsCount: "34K posts",
          avatars: 3,
        ),

        const Divider(height: 1, color: Color(0xFF2F3336)),

        // Trending Section 1
        _buildTrendingSection(
          title: "Trending in Entertainment",
          topic: "#Oscars2025",
          postsCount: "178K posts",
        ),

        const Divider(height: 1, color: Color(0xFF2F336)),

        // Trending Section 2
        _buildTrendingSection(
          title: "Trending in Music",
          topic: "Beyoncé",
          postsCount: "94.3K posts",
        ),

        const Divider(height: 1, color: Color(0xFF2F3336)),

        // Trending Section 3
        _buildTrendingSection(
          title: "Trending in Entertainment",
          topic: "#TheLastOfUs",
          postsCount: "67.8K posts",
        ),

        const Divider(height: 1, color: Color(0xFF2F3336)),

        // Trending Section 4
        _buildTrendingSection(
          title: "Trending in Movies",
          topic: "Dune Part 3",
          postsCount: "45.2K posts",
        ),

        const SizedBox(height: 80),
      ],
    );
  }

  Widget _buildNewsCard({
    required String title,
    required String timeAgo,
    required String category,
    required String postsCount,
    required int avatars,
    bool isTrending = false,
  }) {
    return Container(
      color: Colors.black,
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 12),

          // Bottom row with avatars and info
          Row(
            children: [
              // Avatar Stack
              SizedBox(
                width: avatars * 20.0 + 10,
                height: 24,
                child: Stack(
                  children: List.generate(
                    avatars,
                    (index) => Positioned(
                      left: index * 20.0,
                      child: Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _getAvatarColor(index),
                          border: Border.all(color: Colors.black, width: 1.5),
                        ),
                        child: Center(
                          child: Icon(
                            Icons.person,
                            size: 14,
                            color: Colors.grey[300],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Time and category info
              Expanded(
                child: Text(
                  "$timeAgo · $category · $postsCount",
                  style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTrendingSection({
    required String title,
    required String topic,
    required String postsCount,
  }) {
    return Container(
      color: Colors.black,
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                ),
                const SizedBox(height: 4),
                Text(
                  topic,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  postsCount,
                  style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          Icon(Icons.more_horiz, color: Colors.grey[600], size: 20),
        ],
      ),
    );
  }

  Color _getAvatarColor(int index) {
    final colors = [
      Colors.purple[800]!,
      Colors.pink[800]!,
      Colors.orange[700]!,
      Colors.teal[800]!,
    ];
    return colors[index % colors.length];
  }
}
