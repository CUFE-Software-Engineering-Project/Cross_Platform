import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:lite_x/core/theme/palette.dart';
import 'package:lite_x/features/chat/view/widgets/conversations_list.dart';
import 'package:lite_x/features/chat/view/widgets/conversion_app_bar.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class ConversationsScreen extends StatelessWidget {
  const ConversationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isWeb = kIsWeb;
    return Scaffold(
      backgroundColor: Palette.background,
      appBar: const ConversationAppBar(),
      body: isWeb ? _buildWebLayout(context) : _buildMobileLayout(),
      floatingActionButton: Container(
        child: FloatingActionButton(
          onPressed: () {},
          backgroundColor: Palette.primary,
          shape: const CircleBorder(),
          child: Icon(MdiIcons.emailPlusOutline, color: Colors.white, size: 28),
        ),
      ),
    );
  }

  Widget _buildMobileLayout() {
    return const ConversationsList();
  }

  Widget _buildWebLayout(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: MediaQuery.of(context).size.width,
          child: DecoratedBox(
            decoration: BoxDecoration(),
            child: ConversationsList(),
          ),
        ),
      ],
    );
  }
}
