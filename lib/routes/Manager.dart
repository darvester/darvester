import 'dart:async';
import 'dart:convert';
import 'package:darvester/util.dart';
import 'package:flutter/material.dart';
import 'package:crypto/crypto.dart';

// Components
import '../components/MainDrawer.dart';

// Classes
import '../darvester/harvester_isolate.dart';
import '../darvester/isolate_set.dart';

class Manager extends StatefulWidget {
  const Manager({Key? key}) : super(key: key);

  @override
  State<Manager> createState() => _ManagerState();
}

class _ManagerState extends State<Manager> {
  HarvesterIsolateSet harvesterThreads = HarvesterIsolateSet();

  Future<Digest> spawnHarvesterThread(String token, DarvesterDB db) async {
    Digest hashedToken = md5.convert(utf8.encode(token));

    if (harvesterThreads.get(hashedToken) != null) {
      // TODO: check if context messenger logic needs to be a singleton across routes
      HarvesterIsolate hIsolate = HarvesterIsolate(token, db, context);
      harvesterThreads.add(hIsolate);
    }
    return hashedToken;
  }

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
