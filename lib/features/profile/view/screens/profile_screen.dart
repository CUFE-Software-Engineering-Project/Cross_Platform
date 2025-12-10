import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lite_x/features/profile/view/widgets/profile/profile_screen_body_draft.dart';
import 'package:lite_x/features/profile/view/widgets/profile/profile_screen_body.dart';
import 'package:lite_x/features/profile/view_model/providers.dart';

class ProfilePage extends ConsumerStatefulWidget {
  final String username;
  const ProfilePage({super.key, required this.username});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  bool isMe = false;
  @override
  Widget build(BuildContext context) {
    final String myUserName = ref.watch(myUserNameProvider);
    if (myUserName == widget.username) isMe = true;
    final asyncData = ref.watch(profileDataProvider(widget.username));
    return asyncData.when(
      data: (either) {
        return either.fold(
          (l) {
            return Scaffold(
              appBar: AppBar(
                leading: IconButton(
                  icon: Icon(Icons.arrow_back),
                  onPressed: () {
                    if (context.canPop()) context.pop();
                  },
                ),
              ),
              body: RefreshIndicator(
                onRefresh: () async {
                  // ignore: unused_result
                  await ref.refresh(profileDataProvider(widget.username));
                },
                child: ListView(children: [Center(child: Text(l.message))]),
              ),
            );
          },
          (data) {
            return DefaultTabController(
              length: 6,
              child: Scaffold(
                // body: ProfileScreenBody(profileData: profileData, isMe: isMe),
                body: ProfileScreenBody(profileData: data, isMe: isMe),
              ),
            );
          },
        );
      },
      error: (err, _) {
        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () {
                if (context.canPop()) context.pop();
              },
            ),
          ),
          body: RefreshIndicator(
            onRefresh: () async {
              // ignore: unused_result
              await ref.refresh(profileDataProvider(widget.username));
            },
            child: ListView(children: [Center(child: Text(err.toString()))]),
          ),
        );
      },
      loading: () => Scaffold(body: Center(child: CircularProgressIndicator())),
    );
  }
}
