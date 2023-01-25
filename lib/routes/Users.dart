import 'package:flutter/material.dart';

// Components
import '../components/MainDrawer.dart';

class Users extends StatelessWidget {
  const Users({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Users'),
      ),
      drawer: const MainDrawer(),
      body: const Placeholder(),
    );
  }
}
