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
  return ListView(
    children: [
      Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          "Nothing to see here -- yet.",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 35,
          ),
        ),
      ),
    ],
  );
}

Widget _BuildTrendingTab() {
  return ListView(
    children: [
      Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          "Nothing to see here -- yet.",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 35,
          ),
        ),
      ),
    ],
  );
}

Widget _BuildNewsTab() {
  return ListView(
    children: [
      Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          "Nothing to see here -- yet.",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 35,
          ),
        ),
      ),
    ],
  );
}

Widget _BuildSportsTab() {
  return ListView(
    children: [
      Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          "Nothing to see here -- yet.",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 35,
          ),
        ),
      ),
    ],
  );
}

Widget _BuildEntertainmentTab() {
  return ListView(
    children: [
      Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          "Nothing to see here -- yet.",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 35,
          ),
        ),
      ),
    ],
  );
}
