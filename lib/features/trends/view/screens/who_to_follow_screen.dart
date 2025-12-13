import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lite_x/features/profile/view/widgets/following_followers/follower_card.dart';
import 'package:lite_x/features/profile/view_model/providers.dart';

class WhoToFollowScreen extends ConsumerWidget {
  const WhoToFollowScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncUsers = ref.watch(WhoToFollowProvider);
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          onPressed: () {
            if (context.canPop()) context.pop();
          },
        ),
        title: Text(
          "Connect",
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: asyncUsers.when(
        data: (res) {
          return res.fold(
            (l) {
              return ListView(
                padding: EdgeInsets.all(20),
                children: [
                  Center(child: Text(l.message)),
                  GestureDetector(
                    child: Icon(Icons.refresh),
                    onTap: () async {
                      // ignore: unused_result
                      await ref.refresh(WhoToFollowProvider);
                    },
                  ),
                ],
              );
            },
            (data) {
              return RefreshIndicator(
                onRefresh: () async {
                  // ignore: unused_result
                  await ref.refresh(WhoToFollowProvider);
                },
                child: ListView.builder(
                  itemBuilder: (context, index) =>
                      FollowerCard(user: data[index], isMe: true),
                  itemCount: data.length,
                ),
              );
            },
          );
        },
        error: (err, _) {
          return ListView(
            padding: EdgeInsets.all(20),
            children: [
              Text("some thing went wrong, try again later..."),
              GestureDetector(
                child: Icon(Icons.refresh),
                onTap: () async {
                  // ignore: unused_result
                  await ref.refresh(WhoToFollowProvider);
                },
              ),
            ],
          );
        },
        loading: () {
          return ListView(
            padding: EdgeInsets.all(20),
            children: [Center(child: CircularProgressIndicator())],
          );
        },
      ),
    );
  }
}
