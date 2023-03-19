import 'dart:async';
import 'dart:isolate';

import 'package:nyxx_self/nyxx.dart';

import '../util.dart' show DarvesterDB, Logger;
import './isolate_message.dart';

class Harvester {
  late INyxxWebsocket bot;
  final DarvesterDB db;
  final Logger logger = Logger(name: "harvester");
  final Set<int> userIDSet = {};
  final SendPort sendPort;
  late HarvesterIsolateMessage lastMessage;
  bool _willStop = false;
  bool _willPause = false;

  Harvester(String token, this.db, this.sendPort) {
    bot = NyxxFactory.createNyxxWebsocket(token, GatewayIntents.allUnprivileged | GatewayIntents.guildMembers | GatewayIntents.messageContent);
  }

  void loop() async {
    if (!db.isOpen()) return;
    int requestNumber = 0;
    Set<int> guildIDs = {...bot.guilds.entries.map((guild) => guild.key.id)};
    Set<int> discoveredGuilds = {};

    ReceivePort receivePort = ReceivePort();
    sendPort.send(receivePort.sendPort);

    // Listen for events from Manager
    receivePort.listen((message) {
      if (message is HarvesterIsolateMessage) {
        switch (message.type) {
          case HarvesterIsolateMessageType.stop:
            sendPort.send(HarvesterIsolateMessage(HarvesterIsolateMessageType.log, data: "Stopping harvester..."));
            sendPort.send(HarvesterIsolateMessage(HarvesterIsolateMessageType.state, state: HarvesterIsolateState.stopping));
            _willStop = true;
            break;
          case HarvesterIsolateMessageType.start:
            sendPort.send(HarvesterIsolateMessage(HarvesterIsolateMessageType.log, data: "Starting harvester..."));
            _willStop = false;
            _willPause = false;
            break;
          case HarvesterIsolateMessageType.pause:
            sendPort.send(HarvesterIsolateMessage(HarvesterIsolateMessageType.log, data: "Pausing harvester..."));
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
        sendPort.send(HarvesterIsolateMessage(HarvesterIsolateMessageType.state, state: HarvesterIsolateState.stopped));

        // this may cause a crash btw if receiveport isn't open or instantiated
        receivePort.close();
        return;
      }
      while (_willPause) {
        sendPort.send(HarvesterIsolateMessage(HarvesterIsolateMessageType.state, state: HarvesterIsolateState.paused));
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
          sendPort.send(HarvesterIsolateMessage(HarvesterIsolateMessageType.state, state: HarvesterIsolateState.stopped));

          // this may cause a crash btw if receiveport isn't open or instantiated
          receivePort.close();
          return;
        }
        while (_willPause) {
          sendPort.send(HarvesterIsolateMessage(HarvesterIsolateMessageType.state, state: HarvesterIsolateState.paused));
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
      }
      discoveredGuilds.add(guildID);
    }
  }
}
