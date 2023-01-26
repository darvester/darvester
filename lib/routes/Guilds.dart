import 'package:flutter/material.dart';

// Util
import '../util.dart';

// Components
import '../components/MainDrawer.dart';

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
