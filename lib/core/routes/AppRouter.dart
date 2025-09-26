import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lite_x/core/routes/Route_Constants.dart';
import 'package:lite_x/features/auth/view/widgets/test.dart';
import 'package:lite_x/features/auth/view/widgets/test_2.dart';

class Approuter {
  static final GoRouter router = GoRouter(
    routes: [
      GoRoute(
        name: RouteConstants.test,
        path: "/",
        pageBuilder: (context, state) => CustomTransitionPage(
          child: const Test(),
          transitionsBuilder: _slideRightTransitionBuilder,
        ),
      ),
      GoRoute(
        name: RouteConstants.test2,
        path: "/test2",
        pageBuilder: (context, state) => CustomTransitionPage(
          child: const Test2(),
          transitionsBuilder: _slideRightTransitionBuilder,
        ),
      ),
    ],
    redirect: (context, state) {
      return null;
    },
    errorPageBuilder: (context, state) {
      return MaterialPage(child: Text("Error 404"));
    },
  );
  static Widget _slideRightTransitionBuilder(
    context,
    animation,
    secondaryAnimation,
    child,
  ) {
    const curve = Curves.ease;
    final tween = Tween(
      begin: Offset(1, 0),
      end: Offset.zero,
    ).chain(CurveTween(curve: curve));
    final offsetAnimation = animation.drive(tween);

    return SlideTransition(position: offsetAnimation, child: child);
  }
}
