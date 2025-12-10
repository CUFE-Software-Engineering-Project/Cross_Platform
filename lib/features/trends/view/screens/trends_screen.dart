import 'package:flutter/material.dart';
import '../../models/trend_model.dart';
import '../widgets/trend_tile.dart';

class TrendsScreen extends StatelessWidget {
  const TrendsScreen({super.key});

  List<TrendModel> _sampleTrends() {
    return const [
      TrendModel(
        rank: 1,
        contextLabel: 'Trending in Egypt',
        title: '#براءة_البطل_احمد_عبدالقادر',
      ),
      TrendModel(
        rank: 2,
        contextLabel: 'Only on X • Trending',
        title: 'ياسر ابو شاب',
        postsCountLabel: '17.4K posts',
      ),
      TrendModel(
        rank: 3,
        contextLabel: 'Trending in Egypt',
        title: '#الناس_تحكي_علاحداث',
      ),
      TrendModel(
        rank: 4,
        contextLabel: 'Trending in Egypt',
        title: '#عمودياب_توب_انغامي',
      ),
      TrendModel(
        rank: 5,
        contextLabel: 'Trending in Egypt',
        title: '#المسلماني_يصلح_المنظومه',
      ),
      TrendModel(
        rank: 6,
        contextLabel: 'Trending in Egypt',
        title: 'خالد بن الوليد',
        postsCountLabel: '2,508 posts',
      ),
      TrendModel(
        rank: 7,
        contextLabel: 'Trending in Egypt',
        title: 'اليوم الخميس',
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final trends = _sampleTrends();
    return Scaffold(
      appBar: AppBar(title: const Text('Trends')),
      body: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        itemCount: trends.length,
        itemBuilder: (context, index) => TrendTile(trend: trends[index]),
        separatorBuilder: (context, index) => Divider(
          height: 1,
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.1),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.add),
      ),
    );
  }
}
