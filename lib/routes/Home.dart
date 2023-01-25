import 'package:flutter/material.dart';

import '../components/MainDrawer.dart';

class Home extends StatelessWidget {
  const Home({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey.shade900,
        title: const Text('Darvester'),
      ),
      drawer: const MainDrawer(),
      body: const Placeholder(),
    );
  }
}


