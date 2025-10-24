import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:lite_x/features/profile/view/screens/edit_profile_screen.dart';
import 'package:lite_x/features/profile/view/widgets/profile_posts_list.dart';
import 'package:lite_x/features/profile/view/widgets/profile_screen_body.dart';
import 'package:lite_x/features/profile/view_model/providers.dart';
import '../../../../core/theme/app_theme.dart';
import '../../models/shared.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  Future<void> _refresh() async {
    await ref.read(profileBasicDataNotifierProvider.notifier)
      ..loadProfileData();
    print("refreshed");
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(profileBasicDataNotifierProvider);
    if (state.isLoading) {
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    } else if (state.errorMessage != null) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(icon: Icon(Icons.arrow_back), onPressed: () {}),
        ),
        body: Center(child: Text(state.errorMessage!)),
      );
    }

    final profileData = state.profileData!;

    return DefaultTabController(
      length: 6,
      child: Scaffold(
        body: RefreshIndicator(
          onRefresh: _refresh,
          child: ProfileScreenBody(profileData: profileData),
        ),
      ),
    );
  }
}

