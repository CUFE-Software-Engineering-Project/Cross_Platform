import 'package:flutter/material.dart';
import '../../models/trend_model.dart';
import '../widgets/trend_tile.dart';

class TrendsScreen extends StatelessWidget {
  const TrendsScreen({super.key});

  List<TrendModel> _sampleTrends() {
    return const [
      TrendModel(
        id: "1",
        title: "#AI",
        postCount: 1234567,
        rank: 1,
        likesCount: 987654,
      ),
      TrendModel(
        id: "2",
        title: "#TechNews",
        postCount: 892345,
        rank: 2,
        likesCount: 756432,
      ),
      TrendModel(
        id: "3",
        title: "#CyberMonday",
        postCount: 678912,
        rank: 3,
        likesCount: 543210,
      ),
      TrendModel(
        id: "4",
        title: "#Flutter",
        postCount: 567890,
        rank: 4,
        likesCount: 456789,
      ),
      TrendModel(
        id: "5",
        title: "#ChatGPT",
        postCount: 489234,
        rank: 5,
        likesCount: 398765,
      ),
      TrendModel(
        id: "6",
        title: "#Gaming",
        postCount: 423567,
        rank: 6,
        likesCount: 345678,
      ),
      TrendModel(
        id: "7",
        title: "#ClimateAction",
        postCount: 398765,
        rank: 7,
        likesCount: 312456,
      ),
      TrendModel(
        id: "8",
        title: "#CryptoNews",
        postCount: 376543,
        rank: 8,
        likesCount: 289543,
      ),
      TrendModel(
        id: "9",
        title: "#NFT",
        postCount: 345678,
        rank: 9,
        likesCount: 267890,
      ),
      TrendModel(
        id: "10",
        title: "#Metaverse",
        postCount: 323456,
        rank: 10,
        likesCount: 245678,
      ),
      TrendModel(
        id: "11",
        title: "#WebDev",
        postCount: 298765,
        rank: 11,
        likesCount: 223456,
      ),
      TrendModel(
        id: "12",
        title: "#MachineLearning",
        postCount: 276543,
        rank: 12,
        likesCount: 201234,
      ),
      TrendModel(
        id: "13",
        title: "#SpaceX",
        postCount: 254321,
        rank: 13,
        likesCount: 189876,
      ),
      TrendModel(
        id: "14",
        title: "#ElectricVehicles",
        postCount: 232109,
        rank: 14,
        likesCount: 176543,
      ),
      TrendModel(
        id: "15",
        title: "#FitnessGoals",
        postCount: 209876,
        rank: 15,
        likesCount: 163210,
      ),
      TrendModel(
        id: "16",
        title: "#TravelTuesday",
        postCount: 187654,
        rank: 16,
        likesCount: 149876,
      ),
      TrendModel(
        id: "17",
        title: "#Photography",
        postCount: 165432,
        rank: 17,
        likesCount: 136543,
      ),
      TrendModel(
        id: "18",
        title: "#Foodie",
        postCount: 143210,
        rank: 18,
        likesCount: 123210,
      ),
      TrendModel(
        id: "19",
        title: "#SustainableLiving",
        postCount: 120987,
        rank: 19,
        likesCount: 109876,
      ),
      TrendModel(
        id: "20",
        title: "#MentalHealthMatters",
        postCount: 98765,
        rank: 20,
        likesCount: 96543,
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
        itemBuilder: (context, index) => TrendTile(
          trend: trends[index],
          trendCategory: "Sports",
          showRank: true,
        ),
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
