import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lite_x/core/routes/Route_Constants.dart';
import 'package:lite_x/core/theme/Palette.dart';
import 'package:lite_x/features/chat/view/widgets/conversion/conversations_list.dart';
import 'package:lite_x/features/chat/view/widgets/conversion/conversion_app_bar.dart';
import 'package:lite_x/features/home/view/widgets/profile_side_drawer.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class ConversationsScreen extends StatelessWidget {
  const ConversationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const ProfileSideDrawer(),
      backgroundColor: Palette.background,
      appBar: const ConversationAppBar(),
      body: const ConversationsList(),
      floatingActionButton: FloatingActionButton(
        heroTag: 'search-user',
        onPressed: () {},
        backgroundColor: Palette.primary,
        shape: const CircleBorder(),
        child: IconButton(
          onPressed: () {
            context.pushNamed(RouteConstants.SearchUserGroup);
          },
          icon: Icon(MdiIcons.emailPlusOutline, color: Colors.white, size: 28),
        ),
      ),
    );
  }
}
