import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lite_x/core/providers/current_user_provider.dart';
import 'package:lite_x/features/profile/models/profile_model.dart';
import 'package:lite_x/features/profile/models/shared.dart';
import 'package:lite_x/features/profile/view_model/providers.dart';
import 'package:lite_x/features/trends/view/widgets/category_profile_trend_tab.dart';
import 'package:lite_x/features/trends/view/widgets/for_you_profile_tab.dart';
import 'package:lite_x/features/trends/view/widgets/trending_profile_tab.dart';

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
                Center(child: Text("failed to load trends...")),
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
              length: 6,
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
                    Tab(text: 'Global'),
                    Tab(text: 'News'),
                    Tab(text: 'Sports'),
                    Tab(text: 'Entertainment'),
                  ],
                ),
                body: TabBarView(
                  children: [
                    _BuildForYouTab(pm),
                    _BuildTrendingTab(pm),
                    _BuildGlobalTab(pm),
                    _BuildNewsTab(pm),
                    _BuildSportsTab(pm),
                    _BuildEntertainmentTab(pm),
                  ],
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
            Center(child: Text("cannot get trends at this time...")),
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

Widget _BuildForYouTab(ProfileModel pm) {
  return ForYouProfileTab(pm: pm);
}

Widget _BuildTrendingTab(ProfileModel pm) {
  return TrendingProfileTab(pm: pm);
}

Widget _BuildGlobalTab(ProfileModel pm) {
  return CategoryProfileTrendTab(
    pm: pm,
    categoryName: TrendsCategoriesTabs.Global,
  );
}

Widget _BuildNewsTab(ProfileModel pm) {
  return CategoryProfileTrendTab(
    pm: pm,
    categoryName: TrendsCategoriesTabs.News,
  );
}

Widget _BuildSportsTab(ProfileModel pm) {
  return CategoryProfileTrendTab(
    pm: pm,
    categoryName: TrendsCategoriesTabs.Sports,
  );
}

Widget _BuildEntertainmentTab(ProfileModel pm) {
  return CategoryProfileTrendTab(
    pm: pm,
    categoryName: TrendsCategoriesTabs.Entertainment,
  );
}
