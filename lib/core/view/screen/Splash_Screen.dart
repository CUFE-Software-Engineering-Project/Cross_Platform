import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lite_x/core/providers/current_user_provider.dart';
import 'package:lite_x/core/routes/Route_Constants.dart';
import 'package:lite_x/core/theme/Palette.dart';
import 'package:lite_x/features/auth/view/widgets/buildXLogo.dart';
import 'package:lite_x/features/auth/view_model/auth_state.dart';
import 'package:lite_x/features/auth/view_model/auth_view_model.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(authViewModelProvider, (previousState, nextState) {
      if (nextState.type != AuthStateType.loading) {
        if (nextState.type == AuthStateType.authenticated) {
          final currentUser = ref.read(currentUserProvider);
          final bool hasInterests = currentUser?.interests.isNotEmpty ?? false;
          if (hasInterests) {
            context.goNamed(RouteConstants.homescreen);
          } else {
            context.goNamed(RouteConstants.Interests);
          }
        } else if (nextState.type == AuthStateType.unauthenticated) {
          context.goNamed(RouteConstants.introscreen);
        }
      }
    });
    return Scaffold(
      backgroundColor: Palette.background,
      body: Center(child: buildXLogo(size: 100)),
    );
  }
}
