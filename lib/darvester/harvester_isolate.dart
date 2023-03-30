import 'dart:async';
import 'dart:convert';
import 'dart:isolate';
import 'package:crypto/crypto.dart';
import 'package:darvester/darvester/isolate_message.dart';
import 'package:flutter/material.dart';

import './core.dart';
import '../util.dart';

/// Represents a [HarvesterIsolate] struct which runs the [Harvester] loop.
class HarvesterIsolate {
  /// This is a user token in md5. This is used for comparison purposes to ensure that there are no two
  /// [HarvesterIsolate] instances using the same token.
  late final Digest hash;

  /// The [Isolate] running the [Harvester] loop.
  late final Isolate isolate;

  /// The [SendPort] instance to send messages to the isolate.
  late final SendPort sendPort;

  bool sendPortInitialized = false;

  /// The current state of the isolate.
  late HarvesterIsolateState state;

  /// A queue of [HarvesterIsolateMessage]s. Size constrained to 500.
  late final messageQueue = EvictingQueue<HarvesterIsolateMessage>(500);

  /// Callback that is run in the [isolate]. List of args is token, [DarvesterDB], and a [SendPort]
  /// to communicate with the main isolate.
  void _spawnHarvester(List args) {
    Harvester(
      args[0] as String,
      args[1] as DarvesterDB,
      args[2] as SendPort,
    );
  }

  /// Instantiates a [HarvesterIsolate] struct which runs the [Harvester] loop.
  HarvesterIsolate(String token, DarvesterDB db, BuildContext context) {
    // Set this.hash for comparison
    hash = md5.convert(utf8.encode(token));
    // Call _init to spawn the isolate
    _init(token, db);
  }

  /// Spawns the [Isolate].
  Future<void> _init(String token, DarvesterDB db) async {
    ReceivePort receivePort = ReceivePort();
    receivePort.listen((message) {
      if (message is SendPort && !sendPortInitialized) {
        sendPort = message;
        sendPortInitialized = true;
      } else if (message is HarvesterIsolateMessage) {
        switch (message.type) {
          case HarvesterIsolateMessageType.state:
            if (message.state != null) {
              state = message.state!;
            }
            messageQueue.add(message);
            break;
          default:
            messageQueue.add(message);
            break;
        }
      }
    });

    state = HarvesterIsolateState.starting;
    isolate = await Isolate.spawn(_spawnHarvester, [token, db, receivePort.sendPort]);
  }

  /// Alias of [this.hash.hashCode]
  @override
  int get hashCode => hash.hashCode;

  /// Overrides comparator operator to compare the [Digest] or [HarvesterIsolate]
  @override
  bool operator ==(Object other) {
    return (other is HarvesterIsolate && other.hash == hash) || (other is Digest && other == hash);
  }
}
