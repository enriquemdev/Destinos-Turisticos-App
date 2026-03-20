import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/destinations/presentation/screens/detail_screen.dart';
import '../features/destinations/presentation/screens/list_screen.dart';

// Route names for navigation.
abstract final class RouteNames {
  static const String list = 'list';
  static const String detail = 'detail';
}

// Central GoRouter configuration.
final GoRouter appRouter = GoRouter(
  routes: <RouteBase>[
    GoRoute(
      path: '/',
      name: RouteNames.list,
      builder: (BuildContext context, GoRouterState state) =>
          const ListScreen(),
      routes: <RouteBase>[
        GoRoute(
          path: 'detail/:xid',
          name: RouteNames.detail,
          builder: (BuildContext context, GoRouterState state) {
            final xid = state.pathParameters['xid'] ?? '';
            return DetailScreen(xid: xid);
          },
        ),
      ],
    ),
  ],
);
