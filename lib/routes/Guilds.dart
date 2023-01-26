import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// Util
import '../util.dart';

// Components
import '../components/MainDrawer.dart';

// Routes
import 'Settings.dart';

class Guilds extends StatefulWidget {
  const Guilds({Key? key}) : super(key: key);

  @override
  State<Guilds> createState() => _GuildsState();
}

class _GuildsState extends State<Guilds> {
  DarvesterDB? db;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    Preferences.instance.getString("databasePath").then((value) {
      if (value.isNotEmpty) {
        db = DarvesterDB(value);
      } else {
        showDialog(
            context: context,
            builder: (BuildContext builder) {
              return AlertDialog(
                  title: const Text("Database path empty"),
                  content: const Text(
                      "Database path is not set. Please set in Settings"),
                  actions: <Widget>[
                    TextButton(
                        onPressed: () => context.go("/"),
                        child: const Text("Go back")),
                    TextButton(
                        onPressed: () => Navigator.of(context).push(
                            MaterialPageRoute(builder: (context) => const Settings())
                        ),
                        child: const Text("Take me there")),
                  ]);
            });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Guilds'),
      ),
      drawer: const MainDrawer(),
      body: const Placeholder(),
    );
  }
}
