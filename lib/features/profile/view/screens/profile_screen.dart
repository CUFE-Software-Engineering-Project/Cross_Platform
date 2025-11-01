import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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
    final state = ref.watch(profileBasicDataNotifierProvider(widget.username));
    if (state.isLoading) {
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    } else if (state.errorMessage != null) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              if (context.canPop()) context.pop();
            },
          ),
        ),
        body: Center(child: Text(state.errorMessage!)),
      );
    }

    final profileData = state.profileData!;

    return DefaultTabController(
      length: 6,
      child: Scaffold(
        body: ProfileScreenBody(profileData: profileData, isMe: isMe),
      ),
    );
  }
}
