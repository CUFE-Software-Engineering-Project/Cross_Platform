import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lite_x/core/providers/current_user_provider.dart';
import 'package:lite_x/core/routes/Route_Constants.dart';
import 'package:lite_x/features/profile/models/shared.dart';
import 'package:lite_x/features/profile/view/widgets/profile_search/explore_profile_screen_body.dart';
import 'package:lite_x/features/profile/view_model/providers.dart';

class ExploreProfileScreen extends ConsumerStatefulWidget {
  const ExploreProfileScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _ExploreProfileScreenState();
}

class _ExploreProfileScreenState extends ConsumerState<ExploreProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserProvider);
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            centerTitle: true,
            pinned: true,
            leading: Padding(
              padding: EdgeInsets.all(5).copyWith(left: 10),
              child: BuildSmallProfileImage(
                userId: currentUser?.username ?? "",
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
