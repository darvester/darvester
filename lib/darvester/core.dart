import 'dart:async';
import 'dart:convert';
import 'dart:isolate';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:darvester/database.dart';
import 'package:drift/drift.dart';
import 'package:drift/isolate.dart';
import 'package:nyxx_self/nyxx.dart';

import '../util.dart' show Logger;
import './isolate_message.dart';

class IsolateLogger extends Logger {
  final SendPort sendPort;

  IsolateLogger(this.sendPort, {super.name});

  @override
  void critical(String message) {
    sendPort.send(HarvesterIsolateMessage(HarvesterIsolateMessageType.log, data: "CRITICAL: $message"));
    super.critical(message);
  }

  @override
  void debug(String message) {
    // TODO: implement debug logging flag
    // sendPort.send(HarvesterIsolateMessage(HarvesterIsolateMessageType.log, data: "DEBUG: $message"));
    super.debug(message);
  }

  @override
  void error(String message) {
    sendPort.send(HarvesterIsolateMessage(HarvesterIsolateMessageType.log, data: "ERROR: $message"));
    super.error(message);
  }

  @override
  void info(String message) {
    sendPort.send(HarvesterIsolateMessage(HarvesterIsolateMessageType.log, data: message));
    super.info(message);
  }

  @override
  void warning(String message) {
    sendPort.send(HarvesterIsolateMessage(HarvesterIsolateMessageType.log, data: "WARN: $message"));
    super.warning(message);
  }
}

class Harvester {
  late INyxxWebsocket bot;
  late final DarvesterDatabase db;
  late final Logger logger;
  final Set<int> userIDSet = {};
  final SendPort sendPort;
  late HarvesterIsolateMessage lastMessage;
  late final Digest _digest;
  final Random _rng = Random();
  final ReceivePort receivePort = ReceivePort();

  bool _willStop = false;
  bool _willPause = false;

  Harvester(String token, DriftIsolate driftIsolate, this.sendPort) {
    _digest = md5.convert(utf8.encode(token));
    logger = IsolateLogger(sendPort, name: _digest.toString());

    // Initialize a Drift database instance
    db = DarvesterDatabase(DatabaseConnection.delayed(Future.sync(() async {
      return driftIsolate.connect();
    })));

    // Initialize the bot
    bot = NyxxFactory.createNyxxWebsocket(token, GatewayIntents.allUnprivileged | GatewayIntents.guildMembers | GatewayIntents.messageContent)
      // ..registerPlugin(Logging(logLevel: Level.ALL))
      // ..registerPlugin(IgnoreExceptions())
      ..connect().catchError((dynamic err) {
        sendPort.send(HarvesterIsolateMessage(HarvesterIsolateMessageType.state, state: HarvesterIsolateState.crashed));
        logger.critical("Bot crashed while connecting: $err");
      });

    // Register onReady listener that will start the loop
    bot.eventsWs.onReady.listen((event) {
      logger.info("Bot ready. Starting the harvester loop...");
      sendPort.send(HarvesterIsolateMessage(HarvesterIsolateMessageType.state, state: HarvesterIsolateState.started));
      sendPort.send(receivePort.sendPort);
      loop();
    });

    // Listen for events from Manager
    receivePort.listen((message) async {
      if (message is HarvesterIsolateMessage) {
        switch (message.type) {
          case HarvesterIsolateMessageType.stop:
            logger.info("Stopping harvester: ${_digest.toString()}...");
            sendPort.send(HarvesterIsolateMessage(HarvesterIsolateMessageType.state, state: HarvesterIsolateState.stopping));
            _willStop = true;
            break;
          case HarvesterIsolateMessageType.start:
            logger.info("Starting harvester: ${_digest.toString()}...");
            sendPort.send(HarvesterIsolateMessage(HarvesterIsolateMessageType.state, state: HarvesterIsolateState.starting));
            _willStop = false;
            _willPause = false;
            // Initialize the bot
            bot = NyxxFactory.createNyxxWebsocket(token, GatewayIntents.allUnprivileged | GatewayIntents.guildMembers | GatewayIntents.messageContent)
              // ..registerPlugin(Logging(logLevel: Level.ALL))
              // ..registerPlugin(IgnoreExceptions())
              ..connect().catchError((dynamic err) {
                sendPort.send(HarvesterIsolateMessage(HarvesterIsolateMessageType.state, state: HarvesterIsolateState.crashed));
                logger.critical("Bot crashed while connecting: $err");
              });
            bot.eventsWs.onReady.listen((event) {
              logger.info("Bot ready. Starting the harvester loop...");
              sendPort.send(HarvesterIsolateMessage(HarvesterIsolateMessageType.state, state: HarvesterIsolateState.started));
              sendPort.send(receivePort.sendPort);
              loop();
            });
            break;
          case HarvesterIsolateMessageType.pause:
            logger.info("Pausing harvester: ${_digest.toString()}...");
            sendPort.send(HarvesterIsolateMessage(HarvesterIsolateMessageType.state, state: HarvesterIsolateState.pausing));
            _willPause = true;
            break;
          default:
            lastMessage = message;
            break;
        }
      }
    });
  }

  /// A Future that will delay for a random amount of milliseconds from 1000 to 2500
  Future<void> _loopDelay() async {
    final int delay = 1000 + _rng.nextInt(1500);
    logger.debug("Sleeping for $delay milliseconds");
    await Future<void>.delayed(Duration(milliseconds: delay));
  }

  void loop() async {
    void stop(ReceivePort receivePort) async {
      sendPort.send(HarvesterIsolateMessage(HarvesterIsolateMessageType.state, state: HarvesterIsolateState.stopped));
      logger.info("Disposing bot...");
      await bot.dispose();
    }

    int requestNumber = 0;
    Set<int> guildIDs = {...bot.guilds.entries.map((guild) => guild.key.id)};
    logger.info("This isolate will work with ${guildIDs.length} guilds");
    Set<int> discoveredGuilds = {};

    for (var guildID in guildIDs) {
      if (_willStop) {
        stop(receivePort);
        return;
      }
      if (_willPause) {
        sendPort.send(HarvesterIsolateMessage(HarvesterIsolateMessageType.state, state: HarvesterIsolateState.paused));
        while (_willPause) {
          if (lastMessage.type == HarvesterIsolateMessageType.start) _willPause = false;
        }
      }
      IGuild guild = bot.guilds[Snowflake(guildID)] ?? await bot.fetchGuild(Snowflake(guildID), withCounts: true);

      // TODO: implement IGNORE_GUILD / SWAP_IGNORE logic
      // TODO: implement extensive member chunking logic

      if (!guild.available) {
        logger.error("Guild ${guild.name} is not available. Skipping...");
        continue;
      }

      logger.info('Now working in guild: "${guild.name}"');
      db.upsertGuild(await NyxxToDB.toGuild(guild));

      requestNumber++;
      // TODO: implement guild.ack

      for (Snowflake userID in guild.members.keys.toList()) {
        if (_willStop) {
          stop(receivePort);
          return;
        }
        if (_willPause) {
          sendPort.send(HarvesterIsolateMessage(HarvesterIsolateMessageType.state, state: HarvesterIsolateState.paused));
          while (_willPause) {
            if (lastMessage.type == HarvesterIsolateMessageType.start) _willPause = false;
          }
        }

        IProfile profile = await bot.fetchProfile(userID);
        IUser user = profile.user;

        if (user.bot || user.system) {
          logger.info('User "${user.username}" is a bot. Skipping...');
          continue;
        }

        if (userIDSet.contains(userID.id)) {
          logger.info('Already checked "${user.username}"');
          continue;
        }

        if (requestNumber >= 40) {
          logger.info("On cooldown");
          await Future<void>.delayed(const Duration(seconds: 60));
          requestNumber = 0;
        }

        // TODO: implement db lookup for recent data, last_scanned logic

        // TODO: implement profile db insert

        userIDSet.add(userID.id);
        requestNumber++;
        await _loopDelay();
      }
      await _loopDelay();
      discoveredGuilds.add(guildID);
    }
    logger.info("Finished with all guilds.");
    stop(receivePort);
  }
}
