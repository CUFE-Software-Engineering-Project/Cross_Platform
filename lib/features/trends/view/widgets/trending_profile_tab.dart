import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lite_x/features/profile/view_model/providers.dart';
import 'package:lite_x/features/trends/view/widgets/trend_tile.dart';

class TrendingProfileTab extends ConsumerWidget {
  const TrendingProfileTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncTrends = ref.watch(profileTrendsProvider);
    return asyncTrends.when(
      data: (res) {
        return res.fold(
          (l) {
            return ListView(
              padding: EdgeInsets.only(top: 50),
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              children: [
                Center(child: Text(l.message)),
                Center(
                  child: IconButton(
                    onPressed: () async {
                      // ignore: unused_result
                      ref.refresh(profileTrendsProvider);
                    },
                    icon: Icon(Icons.refresh),
                  ),
                ),
              ],
            );
          },
          (data) {
            return RefreshIndicator(
              onRefresh: () async {
                // ignore: unused_result
                await ref.refresh(profileTrendsProvider);
              },
              child: ListView.builder(
                padding: EdgeInsets.only(left: 16),
                itemBuilder: (context, index) => TrendTile(
                  trend: data[index],
                  trendCategory: "Egypt",
                  showRank: true,
                ),
                itemCount: data.length,
              ),
            );
          },
        );
      },
      error: (err, _) {
        return ListView(
          padding: EdgeInsets.only(top: 50),
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          children: [
            Center(
              child: Text("Can't get Trends at this time, Try again Later..."),
            ),
            Center(
              child: IconButton(
                onPressed: () async {
                  // ignore: unused_result
                  ref.refresh(profileTrendsProvider);
                },
                icon: Icon(Icons.refresh),
              ),
            ),
          ],
        );
      },
      loading: () {
        return SingleChildScrollView(
          padding: EdgeInsets.all(20),
          child: Center(child: CircularProgressIndicator()),
        );
      },
    );
  }
}
