// Component packages
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// Routes
import 'routes/Home.dart';
import 'routes/Guilds.dart';
import 'routes/Users.dart';
import 'routes/Manager.dart';

// Components
// import 'components/MainDrawer.dart';

final _router = GoRouter(
  routes: <RouteBase>[
    GoRoute(
      path: '/',
      builder: (BuildContext context, GoRouterState state) => const Home(),
    ),
    GoRoute(
      path: '/guilds',
      builder: (BuildContext context, GoRouterState state) => const Guilds(),
      routes: <RouteBase>[
        GoRoute(
          path: ':id',
          // TODO: Guild.dart
          builder: (BuildContext context, GoRouterState state) => const Placeholder(),
        )
      ]
    ),
    GoRoute(
      path: '/users',
      builder: (BuildContext context, GoRouterState state) => const Users(),
      routes: <RouteBase>[
        GoRoute(
          path: ':id',
          // TODO: User.dart
          builder: (BuildContext context, GoRouterState state) => const Placeholder(),
        )
      ]
    ),
    GoRoute(
      path: '/manager',
      builder: (BuildContext context, GoRouterState state) => const Manager(),
    )
  ],
  initialLocation: '/',
);

void main() {
  runApp(const Darvester());
}

class Darvester extends StatelessWidget {
  const Darvester({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: "Darvester",
      theme: ThemeData(
        brightness: Brightness.dark,
        fontFamily: "Unbounded"
      ),
      routerConfig: _router,
    );
  }
}
