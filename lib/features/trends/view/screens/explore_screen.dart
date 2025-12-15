import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lite_x/features/trends/view/widgets/explore_screen_body.dart';

class RealExploreScreen extends ConsumerStatefulWidget {
  const RealExploreScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends ConsumerState<RealExploreScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            centerTitle: true,
            pinned: true,
            leading: BackButton(
              onPressed: () {
                if (context.canPop()) context.pop();
              },
            ),
            title: Text(
              "Explore",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
            actions: [Icon(Icons.settings_outlined)],
            actionsPadding: EdgeInsets.only(right: 20),
          ),
          SliverFillRemaining(child: ExploreScreenBody()),
        ],
      ),
    );
  }
}
