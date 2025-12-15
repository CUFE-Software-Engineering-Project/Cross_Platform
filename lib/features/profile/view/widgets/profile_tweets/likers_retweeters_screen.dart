import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lite_x/features/profile/models/shared.dart';
import 'package:lite_x/features/profile/models/user_model.dart';
import 'package:lite_x/features/profile/view/widgets/following_followers/follower_card.dart';
import 'package:lite_x/features/profile/view_model/providers.dart';

class LikersRetweetersScreen extends ConsumerStatefulWidget {
  final String tweetId;

  const LikersRetweetersScreen({super.key, required this.tweetId});

  @override
  ConsumerState<LikersRetweetersScreen> createState() =>
      _LikersRetweetersScreenState();
}

class _LikersRetweetersScreenState extends ConsumerState<LikersRetweetersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    ref.refresh(likersProvider(widget.tweetId));
    ref.refresh(retweetersProvider(widget.tweetId));
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            }
          },
        ),
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Interactions',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(width: 5),
            Icon(Icons.stacked_bar_chart_sharp),
          ],
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFF1DA1F2),
          indicatorSize: TabBarIndicatorSize.label,
          isScrollable: false,
          tabAlignment: TabAlignment.fill,
          dividerHeight: 0.25,
          labelColor: Colors.white,
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
          labelStyle: const TextStyle(fontWeight: FontWeight.bold),
          unselectedLabelColor: Colors.grey,
          tabs: const [
            Tab(text: 'Likers'),
            Tab(text: 'Retweeters'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _LikersTab(tweetId: widget.tweetId),
          _RetweetersTab(tweetId: widget.tweetId),
        ],
      ),
    );
  }
}

class _LikersTab extends ConsumerWidget {
  final String tweetId;

  const _LikersTab({required this.tweetId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final likersAsync = ref.watch(likersProvider(tweetId));

    return likersAsync.when(
      data: (res) => res.fold(
        (l) => _buildErrorWidget(l.message, likersProvider(tweetId), ref),
        (data) {
          if (data.isEmpty)
            return _buildEmptyWidget(likersProvider(tweetId), ref);
          return RefreshIndicator(
            onRefresh: () async {
              // ignore: unused_result
              ref.refresh(likersProvider(tweetId));
            },
            child: ListView.builder(
              itemBuilder: (context, index) =>
                  FollowerCard(user: data[index], isMe: true),
              itemCount: data.length,
            ),
          );
        },
      ),
      error: (err, _) => _buildErrorWidget(
        "can't get likers list for now...",
        likersProvider(tweetId),
        ref,
      ),
      loading: () => _buildLoadingWidget(),
    );
  }
}

class _RetweetersTab extends ConsumerWidget {
  final String tweetId;

  const _RetweetersTab({required this.tweetId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final retweetersAsync = ref.watch(retweetersProvider(tweetId));

    return retweetersAsync.when(
      data: (res) => res.fold(
        (l) => _buildErrorWidget(l.message, retweetersProvider(tweetId), ref),
        (data) {
          if (data.isEmpty)
            return _buildEmptyWidget(retweetersProvider(tweetId), ref);
          return RefreshIndicator(
            onRefresh: () async {
              // ignore: unused_result
              ref.refresh(likersProvider(tweetId));
            },
            child: ListView.builder(
              itemBuilder: (context, index) =>
                  FollowerCard(user: data[index], isMe: true),
              itemCount: data.length,
            ),
          );
        },
      ),
      error: (err, _) => _buildErrorWidget(
        "can't get likers list for now...",
        retweetersProvider(tweetId),
        ref,
      ),
      loading: () => _buildLoadingWidget(),
    );
  }
}

Widget _buildErrorWidget(String text, dynamic provider, WidgetRef ref) {
  return RefreshIndicator(
    child: ListView(
      children: [
        SizedBox(height: 100),
        Center(child: Text(text)),
      ],
    ),
    onRefresh: () async {
      // ignore: unused_result
      ref.refresh(provider);
    },
  );
}

Widget _buildLoadingWidget() {
  return Center(child: CircularProgressIndicator());
}

Widget _buildEmptyWidget(dynamic provider, WidgetRef ref) {
  return RefreshIndicator(
    child: ListView(
      children: [
        SizedBox(height: 20),
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
    ),
    onRefresh: () async {
      // ignore: unused_result
      ref.refresh(provider);
    },
  );
}
