// Component packages
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:window_size/window_size.dart';

// Routes
import 'routes/Home.dart';
import 'routes/Guilds.dart';
import 'routes/Users.dart';
import 'routes/Manager.dart';

final _router = GoRouter(
  routes: <RouteBase>[
    GoRoute(
      path: '/',
      builder: (BuildContext context, GoRouterState state) => const Home(),
    ),
    GoRoute(
      path: '/guilds',
      builder: (BuildContext context, GoRouterState state) => const Guilds(),
    ),
    GoRoute(
      path: '/users',
      builder: (BuildContext context, GoRouterState state) => const Users(),
    ),
    GoRoute(
      path: '/manager',
      builder: (BuildContext context, GoRouterState state) => const Manager(),
    )
  ],
  initialLocation: '/',
);

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..maxConnectionsPerHost = 5;
  }
}

void main() {
  HttpOverrides.global = MyHttpOverrides();
  WidgetsFlutterBinding.ensureInitialized();
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    setWindowTitle('Darvester');
    setWindowMinSize(const Size(800, 600));
    setWindowMaxSize(Size.infinite);
  }
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

