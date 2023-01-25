import 'package:flutter/material.dart';

// Components
import '../components/MainDrawer.dart';

class Guilds extends StatelessWidget {
  const Guilds({Key? key}) : super(key: key);

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
