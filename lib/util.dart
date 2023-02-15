import 'dart:math';
import 'dart:io';
import 'dart:developer' as developer;
import 'dart:convert';

import 'package:darvester/routes/Settings.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sqflite/sqflite.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cached_network_image/cached_network_image.dart';

// UDFs
bool checkInvalidImage(String? uri) {
  return uri?.contains("http") ?? false;
}

DateTime timestampToDateTime(int timestamp) {
  return DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
}

ImageProvider assetOrNetwork(String? uri, {String? fallbackUri}) {
  if (checkInvalidImage(uri) && uri != null) {
    return CachedNetworkImageProvider(uri);
  } else {
    return AssetImage(fallbackUri ?? "images/default_avatar.png");
  }
}

showAlertDialog(BuildContext context, String title, String content) {
  showDialog(
      context: context,
      builder: (BuildContext builder) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: <Widget>[
            TextButton(onPressed: () => context.go("/"), child: const Text("Go back")),
            TextButton(
              onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => const Settings())),
              child: const Text("Settings"),
            ),
          ],
        );
      });
}

// Classes
class Preferences {
  final Logger logger = Logger(name: "prefs");
  Preferences._privateConstructor();

  static final Preferences instance = Preferences._privateConstructor();

  setBool(String key, bool value) async {
    logger.debug("Setting shared_prefs bool: $key=$value");
    SharedPreferences prefsInstance = await SharedPreferences.getInstance();
    prefsInstance.setBool(key, value);
  }

  setString(String key, String value, {bool isSecret = false}) async {
    logger.debug("Setting shared_prefs string: $key${isSecret ? '={secret}' : '=$value'}");
    SharedPreferences prefsInstance = await SharedPreferences.getInstance();
    prefsInstance.setString(key, isSecret ? base64.encode(utf8.encode(value)) : value);
  }

  Future<bool> getBool(String key) async {
    SharedPreferences prefsInstance = await SharedPreferences.getInstance();
    bool result = prefsInstance.getBool(key) ?? false;
    logger.debug("Getting shared_prefs bool: $key=$result");
    return result;
  }

  Future<String> getString(String key) async {
    SharedPreferences prefsInstance = await SharedPreferences.getInstance();
    String result = prefsInstance.getString(key) ?? "";
    logger.debug("Getting shared_prefs string: $key=$result");
    return result;
  }
}

class DarvesterDB {
  Database? db;
  String? path;
  final Logger logger = Logger(name: "db");

  DarvesterDB._privateConstructor();

  static final DarvesterDB instance = DarvesterDB._privateConstructor();

  Future<Database?> openDB(String path, BuildContext context, {bool tryToForce = false}) async {
    logger.debug("Attempting to open database: $path ...");

    this.path = path;
    if (tryToForce) {
      logger.warning("Closing database before open...");
      await db?.close();
    }

    if (db == null || !(db?.isOpen ?? false)) {
      if (!await File(path).exists()) {
        throw showDialog(
            context: context,
            builder: (BuildContext context) {
              logger.error("Database file does not exist at $path");
              return AlertDialog(
                title: const Text("Error"),
                content: const Text("Database file does not exist"),
                actions: <Widget>[
                  TextButton(onPressed: () => context.go("/"), child: const Text("Go back")),
                  TextButton(
                    onPressed: () =>
                        Navigator.of(context).push(MaterialPageRoute(builder: (context) => const Settings())),
                    child: const Text("Settings"),
                  ),
                ],
              );
            });
      } else {
        db = await openDatabase(
          path,
          version: 1,
        );
        logger.debug("Database opened: $path");
      }
    } else {
      logger.debug("Database already opened at: $path");
    }
    return db;
  }

  Future<List<Map>?> getGuilds(BuildContext context,
      {int limit = 50, int offset = 0, List<String> columns = const ["data"]}) async {
    logger.debug("Looking up guilds: (columns=$columns, limit=$limit, offset=$offset)");
    db = await openDB(await Preferences.instance.getString("databasePath"), context);
    String limitStr = limit > 0 ? " LIMIT $limit " : "";
    String offsetStr = offset > 0 ? " OFFSET $offset " : "";
    List<Map>? guilds = await db?.rawQuery('SELECT ${columns.join(", ")}, id FROM guilds $limitStr $offsetStr');
    logger.debug("Found ${guilds?.length ?? 0} guilds:");
    logger.debug(guilds.toString());
    return guilds;
  }

  Future<Map?> getGuild(String id, BuildContext context, {List<String> columns = const ["data"]}) async {
    logger.debug("Looking up guild: (id=$id, columns=$columns)");
    db = await openDB(await Preferences.instance.getString("databasePath"), context);
    List<Map>? guild = await db?.rawQuery('SELECT ${columns.join(", ")}, id FROM guilds WHERE id = ?', [
      id,
    ]);
    if (guild != null) {
      logger.debug("Found guild $id:");
      logger.debug(guild[0].toString());
    } else {
      logger.warning("Guild $id not found");
      return null;
    }

    return guild[0];
  }

  Future<List<Map>?> getGuildMembers(
      String id,
      BuildContext context,
      {
        List<String> columns = const ["data"],
        String sortBy = "asc",
        int limit = 20,
        int offset = 0,
      }) async {
    if (!["asc", "desc"].contains(sortBy)) sortBy = "asc";
    sortBy = sortBy.toUpperCase();

    logger.debug("Grabbing members for guild $id...");
    List<Map>? members = await db?.rawQuery('SELECT data, id FROM users WHERE data LIKE "%$id%" ORDER BY name $sortBy LIMIT $limit OFFSET $offset');
    List<Map> newMembers = [];

    try {
      if (members != null || (members?.isNotEmpty ?? false)) {
        logger.debug("Got ${members?.length ?? 0} members for guild $id");
        for (var member in members!) {
          try {
            member = jsonDecode(member["data"]);
            newMembers.add(member);
          } catch (_) {
            logger.warning("Could not parse member ${member['id']}");
            continue;
          }
        }
      } else {
        logger.warning("No members for guild $id");
        return [];
      }
    } catch (_) {
      return [];
    }

    return newMembers;
  }
}

class ScaleSize {
  static double textScaleFactor(BuildContext context, {double maxTextScaleFactor = 2}) {
    final width = MediaQuery.of(context).size.width;
    double val = (width / 1400) * maxTextScaleFactor;
    return max(0.5, min(val, maxTextScaleFactor));
  }
}

class Logger {
  final String name;

  Logger({this.name = "darvester"}) {
    info("Logger started for: $name");
  }

  void critical(String message) {
    developer.log(
      message,
      time: DateTime.now(),
      level: 1200,
      name: name,
    );
  }

  void error(String message) {
    developer.log(
      message,
      time: DateTime.now(),
      level: 1000,
      name: name,
    );
  }

  void warning(String message) {
    developer.log(
      message,
      time: DateTime.now(),
      level: 900,
      name: name,
    );
  }

  void info(String message) {
    developer.log(
      message,
      time: DateTime.now(),
      level: 800,
      name: name,
    );
  }

  void debug(String message) {
    developer.log(
      message,
      time: DateTime.now(),
      level: 500,
      name: name,
    );
  }
}
