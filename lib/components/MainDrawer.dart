import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../routes/Settings.dart';

class MainDrawer extends StatelessWidget {
  const MainDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
        child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              const DrawerHeader(
                  decoration: BoxDecoration(
                    color: Colors.grey,
                  ),
                  child: Text(
                      "Darvester",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 24
                      )
                  ),
              ),
              ListTile(
                leading: const Icon(Icons.home),
                title: const Text('Home'),
                onTap: () {
                  if (GoRouter.of(context).location != "/") {
                    context.go('/');
                  } else {
                    context.pop();
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.explore),
                title: const Text('Guilds'),
                onTap: () => context.go('/guilds'),
              ),
              ListTile(
                leading: const Icon(Icons.person),
                title: const Text('Users'),
                onTap: () => context.go('/users'),
              ),
              ListTile(
                leading: const Icon(Icons.storage),
                title: const Text('Manager'),
                onTap: () => context.go('/manager')
              ),
              ListTile(
                leading: const Icon(Icons.settings),
                title: const Text('Settings'),
                onTap: () {
                  Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => const Settings())
                  );
                }
              ),
            ],
        ),
    );
  }
}
