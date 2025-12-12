import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lite_x/core/providers/current_user_provider.dart';
import 'package:lite_x/features/home/view/widgets/profile_side_drawer.dart';
import 'package:lite_x/features/profile/models/shared.dart';
import 'package:lite_x/features/profile/view/widgets/profile_search/explore_profile_screen_body.dart';

class ExploreProfileScreen extends ConsumerStatefulWidget {
  const ExploreProfileScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _ExploreProfileScreenState();
}

class _ExploreProfileScreenState extends ConsumerState<ExploreProfileScreen> {
  @override
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserProvider);
    return Scaffold(
      key: _scaffoldKey,
      drawer: const ProfileSideDrawer(),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            centerTitle: true,
            pinned: true,
            leading: Padding(
              padding: EdgeInsets.all(5).copyWith(left: 10),
              child: GestureDetector(
                onTap: () {
                  _scaffoldKey.currentState?.openDrawer();
                },
                child: BuildSmallProfileImage(
                  username: currentUser?.username ?? "",
                  radius: 15,
                ),
              ),
            ),
            title: GestureDetector(
              onTap: () {
                context.push("/profileSearchScreen");
              },
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      width: 250,
                      height: 35,
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 29, 29, 31),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: EdgeInsets.only(left: 15, top: 5, bottom: 5),
                      alignment: AlignmentGeometry.centerLeft,
                      child: Text(
                        "Search X",
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [Icon(Icons.settings_outlined)],
            actionsPadding: EdgeInsets.only(right: 20),
          ),
          SliverFillRemaining(child: Exploreprofilescreenbody()),
        ],
      ),
    );
  }
}
