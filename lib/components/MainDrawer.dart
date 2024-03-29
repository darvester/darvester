import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../routes/Settings.dart';

class MainDrawer extends StatelessWidget {
  const MainDrawer({Key? key}) : super(key: key);

  static bool checkLocation(BuildContext context, String route) {
    return GoRouter.of(context).location == route;
  }

  static const List<Map<String, dynamic>> menuItems = [
    {
      "icon": Icons.home,
      "title": 'Home',
      "route": '/',
    },
    {
      "icon": Icons.explore,
      "title": 'Guilds',
      "route": '/guilds',
    },
    {
      "icon": Icons.person,
      "title": 'Users',
      "route": '/users',
    },
    {
      "icon": Icons.storage,
      "title": 'Isolates',
      "route": '/manager',
    },
  ];

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
            child: Text("Darvester", style: TextStyle(color: Colors.white, fontSize: 24)),
          ),
          ...menuItems
              .map((e) => ListTile(
                  leading: Icon(e["icon"] as IconData),
                  title: Text(e["title"] as String),
                  onTap: () {
                    if (checkLocation(context, e["route"] as String)) {
                      context.pop();
                    } else {
                      context.go(e["route"] as String);
                    }
                  }))
              .toList(),
          ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute<dynamic>(builder: (BuildContext context) => const Settings()));
              }),
        ],
      ),
    );
  }
}
