import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lite_x/core/providers/current_user_provider.dart';
import 'package:lite_x/features/profile/view_model/providers.dart';
import 'package:lite_x/features/trends/view/widgets/explore_category_tab.dart';

class ExploreScreenBody extends ConsumerStatefulWidget {
  const ExploreScreenBody({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _ExploreScreenbodyState();
}

class _ExploreScreenbodyState extends ConsumerState<ExploreScreenBody> {
  @override
  Widget build(BuildContext context) {
    final currUser = ref.watch(currentUserProvider);
    final asyncPm = ref.watch(profileDataProvider(currUser?.username ?? ""));
    return asyncPm.when(
      data: (res) {
        return res.fold(
          (l) {
            return ListView(
              padding: EdgeInsets.only(top: 50),
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              children: [
                Center(child: Text("failed to load explore...")),
                Center(
                  child: IconButton(
                    onPressed: () async {
                      // ignore: unused_result
                      ref.refresh(
                        profileDataProvider(currUser?.username ?? ""),
                      );
                    },
                    icon: Icon(Icons.refresh),
                  ),
                ),
              ],
            );
          },
          (pm) {
            return DefaultTabController(
              length: _tabs.length,
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
                  tabs: _tabs.map((x) => Tab(text: x)).toList(),
                ),
                body: TabBarView(
                  children: _tabs
                      .map((x) => ExploreCategoryTab(categoryName: x, pm: pm))
                      .toList(),
                ),
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
            Center(child: Text("cannot get explore at this time...")),
            Center(
              child: IconButton(
                onPressed: () async {
                  // ignore: unused_result
                  ref.refresh(profileDataProvider(currUser?.username ?? ""));
                },
                icon: Icon(Icons.refresh),
              ),
            ),
          ],
        );
      },
      loading: () {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Center(child: CircularProgressIndicator()),
          ),
        );
      },
    );
  }
}

final List<String> _tabs = [
  "general",
  "food",
  "science",
  "music",
  "news",
  "sports",
  "finance",
  "fashion",
  "stocks",
  "business & finance",
  "basketball",
  "baseball",
  "movies & tv",
  "celebrity",
  "american football",
  "travel",
  "memes",
  "health & fitness",
  "entertainment",
  "cryptocurrency",
  "politics",
  "soccer",
  "gaming",
  "pets",
  "technology",
  "shopping",
];
