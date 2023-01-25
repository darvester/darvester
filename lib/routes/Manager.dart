import 'package:flutter/material.dart';

// Components
import '../components/MainDrawer.dart';

class Manager extends StatelessWidget {
  const Manager({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manager'),
      ),
      drawer: const MainDrawer(),
      body: const Placeholder(),
    );
  }
}
