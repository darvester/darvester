import 'dart:async';
import 'dart:convert';
import 'dart:isolate';

import 'package:crypto/crypto.dart';
import 'package:nyxx_self/nyxx.dart';

import '../util.dart' show DarvesterDB, Logger;
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
    sendPort.send(HarvesterIsolateMessage(HarvesterIsolateMessageType.log, data: "DEBUG: $message"));
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
  final DarvesterDB db;
  late final Logger logger;
  final Set<int> userIDSet = {};
  final SendPort sendPort;
  late HarvesterIsolateMessage lastMessage;
  late final Digest _digest;

  bool _willStop = false;
  bool _willPause = false;

  Harvester(String token, this.db, this.sendPort) {
    _digest = md5.convert(utf8.encode(token));
    logger = IsolateLogger(sendPort, name: _digest.toString());
    bot = NyxxFactory.createNyxxWebsocket(token, GatewayIntents.allUnprivileged | GatewayIntents.guildMembers | GatewayIntents.messageContent)
      ..registerPlugin(Logging(logLevel: Level.ALL))
      ..connect();
    bot.eventsWs.onReady.listen((event) {
      logger.info("Bot ready. Starting the harvester loop...");
      loop();
    });
  }

  void loop() async {
    void stop(ReceivePort receivePort) async {
      sendPort.send(HarvesterIsolateMessage(HarvesterIsolateMessageType.state, state: HarvesterIsolateState.stopped));
      logger.info("Disposing bot...");
      await bot.dispose();

      // this may cause a crash btw if receivePort isn't open or instantiated
      receivePort.close();
    }

    if (!db.isOpen()) logger.critical("Database is not open");

    int requestNumber = 0;
    Set<int> guildIDs = {...bot.guilds.entries.map((guild) => guild.key.id)};
    logger.info("This isolate will work with ${guildIDs.length} guilds");
    Set<int> discoveredGuilds = {};

    ReceivePort receivePort = ReceivePort();
    sendPort.send(receivePort.sendPort);

    // Listen for events from Manager
    receivePort.listen((message) {
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
      IGuild guild = await bot.fetchGuild(Snowflake(guildID), withCounts: true);

      // TODO: implement IGNORE_GUILD / SWAP_IGNORE logic
      // TODO: implement extensive member chunking logic

      if (!guild.available) {
        logger.error("Guild ${guild.name} is not available. Skipping...");
        continue;
      }

      logger.info('Now working in guild: "${guild.name}"');
      Map guildData = {
        "name": guild.name,
        "icon": guild.iconUrl(), // TODO: implement animated check
        "owner": {
          "name": await guild.owner.getOrDownload()
            ..username,
          "id": await guild.owner.getOrDownload()
            ..id,
        },
        "splash_url": guild.splashUrl(),
        "member_count": guild.memberCount ?? guild.approxMemberCount,
        "description": guild.description,
        "features": guild.features.map((f) => f.toString()).toList(),
        "premium_tier": guild.premiumTier.value,
        "boosts": guild.premiumSubscriptionCount ?? 0,
      };
      // TODO: validate guild data

      // TODO: implement guild insert in utils.dart
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
          await Future.delayed(const Duration(seconds: 60));
          requestNumber = 0;
        }

        // TODO: implement db lookup for recent data, last_scanned logic

        Map<String, List> userMutualGuilds = {
          "guilds": [],
        };

        // TODO: implement profile db insert

        userIDSet.add(userID.id);
        requestNumber++;
        await Future.delayed(const Duration(seconds: 1));
      }
      discoveredGuilds.add(guildID);
    }
    logger.info("Finished with all guilds.");
    stop(receivePort);
  }
}
