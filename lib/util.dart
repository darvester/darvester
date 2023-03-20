import 'dart:math';
import 'dart:io';
import 'dart:developer' as developer;
import 'dart:convert';
import 'dart:collection';

import 'package:darvester/routes/Settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:sqflite/sqflite.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';

// Consts
NumberFormat enNumFormat = NumberFormat.decimalPattern('en_us');

// UDFs
/// Returns true if the image URL is valid
bool checkValidImage(String? uri) {
  return uri?.contains("http") ?? false;
}

/// Validates a Discord JWT token by taking the header of the JWT, decoding it from Base64
/// as a [BigInt], then validating if the timestamp is greater than the Discord epoch. Returns [true]
/// if the token is valid.
/// [Discord Snowflake documentation](https://discord.com/developers/docs/reference#snowflakes-snowflake-id-format-structure-left-to-right)
bool validateJwtDiscordToken(String token) {
  try {
    BigInt userId = BigInt.parse(base64
        .decode(token.split(".")[0])
        .map((el) {
          return String.fromCharCode(el);
        })
        .toList()
        .join());
    return BigInt.from(DateTime.now().microsecondsSinceEpoch) >= (BigInt.from(1420070400000) + (userId >> 22));
  } catch (err) {
    return false;
  }
  // 204778193311
  // 1420070400000
}

DateTime timestampToDateTime(int timestamp) {
  return DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
}

ImageProvider assetOrNetwork(String? uri, {String? fallbackUri}) {
  if (checkValidImage(uri) && uri != null) {
    return CachedNetworkImageProvider(uri, errorListener: () {});
  } else {
    return AssetImage(fallbackUri ?? "images/default_avatar.png");
  }
}

/* TODO: replace instances of showDialog with this */
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
  // i dont think this needs to be a singleton
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

  bool isOpen() {
    return (db?.isOpen ?? false);
  }

  Future<Database?> openDB(String path, BuildContext context, {bool tryToForce = false}) async {
    logger.debug("Attempting to open database: $path ...");

    this.path = path;
    if (tryToForce) {
      logger.warning("Closing database before open...");
      await db?.close();
    }

    if (db == null || !(db?.isOpen ?? false)) {
      if (!await File(path).exists()) {
        // TODO: remove this, figure out a better way of showing a dialog smh
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
                    onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => const Settings())),
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
      {int limit = 50, int offset = 0, List<String> columns = const ["data"], String sortColumn = "name", String sortBy = "asc"}) async {
    if (!["asc", "desc"].contains(sortBy)) sortBy = "asc";
    sortBy = sortBy.toUpperCase();

    logger.debug("Looking up guilds: (columns=$columns, limit=$limit, offset=$offset)");
    db = await openDB(await Preferences.instance.getString("databasePath"), context);
    String limitStr = limit > 0 ? " LIMIT $limit " : "";
    String offsetStr = offset > 0 ? " OFFSET $offset " : "";
    List<Map>? guilds = await db?.rawQuery('SELECT ${columns.join(", ")}, id FROM guilds ORDER BY LOWER(?) ASC $limitStr $offsetStr', [sortColumn]);
    logger.debug("Found ${guilds?.length ?? 0} guilds:");
    logger.debug(guilds.toString());
    return guilds;
  }

  Future<int> getGuildsCount({String? searchTerm}) async {
    String whereQuery = "";
    if (searchTerm != null) {
      whereQuery = "WHERE data LIKE \"%$searchTerm%\"";
    }
    List<Map>? count = await db?.rawQuery("SELECT COUNT(1) FROM guilds $whereQuery");
    return count?[0]["COUNT(1)"] ?? 0;
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
    BuildContext context, {
    List<String> columns = const ["data"],
    String sortBy = "asc",
    int limit = 20,
    int offset = 0,
  }) async {
    db = await openDB(await Preferences.instance.getString("databasePath"), context);
    if (!["asc", "desc"].contains(sortBy)) sortBy = "asc";
    sortBy = sortBy.toUpperCase();

    logger.debug("Grabbing members for guild $id...");
    List<Map>? members = await db?.query(
      "users",
      columns: ["data", "id"],
      where: "data LIKE '%$id%'",
      orderBy: "LOWER(name) $sortBy",
      limit: limit,
      offset: offset,
    );
    List<Map> newMembers = [];

    /* TODO: Fix this piece of crap try catch loop */
    try {
      if (members != null || (members?.isNotEmpty ?? false)) {
        logger.debug("Got ${members?.length ?? 0} members for guild $id");
        for (var e in members!) {
          try {
            Map member;
            member = jsonDecode(e["data"]);
            newMembers.add({...member, "id": e["id"]});
          } catch (_) {
            logger.warning("Could not parse member ${e['id']}");
            continue;
          }
        }
      } else {
        logger.warning("No members for guild $id");
        return [];
      }
    } catch (_) {
      return [];
    } // this try catch loop is rabies

    return newMembers;
  }

  Future<List<Map>?> getUsers(
    BuildContext context, {
    List<String> columns = const ["data", "id"],
    String sortBy = "asc",
    String sortColumn = "name",
    String? searchTerm,
    int limit = 40,
    int offset = 0,
  }) async {
    db = await openDB(await Preferences.instance.getString("databasePath"), context);
    if (!["asc", "desc"].contains(sortBy)) sortBy = "asc";
    sortBy = sortBy.toUpperCase();

    List<Map>? users = await db?.query(
      "users",
      columns: columns,
      where: "LOWER(data) LIKE \"%?%\"",
      whereArgs: [searchTerm],
      orderBy: "$sortColumn $sortBy",
      limit: limit,
      offset: offset,
    );
    List<Map> newUsers = [];

    try {
      if (users != null || (users?.isNotEmpty ?? false)) {
        logger.debug("Got ${users?.length ?? 0} users");
        users?.asMap().forEach((idx, user) {
          // logger.debug("Got user ${user['id']}: ${user['data']}");
          try {
            newUsers.add({
              ...user,
              'data': jsonDecode(user["data"]),
            });
          } catch (_) {
            logger.error("Could not parse user ${user["id"]}: $_");
          }
        });
        return newUsers;
      } else {
        return [];
      }
    } catch (_) {
      logger.error("Exception occurred trying to fetch users");
      return [];
    }
  }

  Future<int> getUsersCount({String? searchTerm}) async {
    String whereQuery = "";
    if (searchTerm != null) {
      whereQuery = "WHERE data LIKE \"%$searchTerm%\"";
    }
    List<Map>? count = await db?.rawQuery("SELECT COUNT(1) FROM users $whereQuery");
    return count?[0]["COUNT(1)"] ?? 0;
  }

  Future<Map?> getUser(String id, BuildContext context, {List<String> columns = const ["data"]}) async {
    logger.debug("Looking up user: (id=$id, columns=$columns)");
    db = await openDB(await Preferences.instance.getString("databasePath"), context);
    List<Map>? user = await db?.query(
      "users",
      columns: columns,
      where: "id = ?",
      whereArgs: [id],
    );
    if (user != null) {
      logger.debug("Found user $id:");
      logger.debug(user[0].toString());
    } else {
      logger.warning("User $id not found");
      return null;
    }

    return user[0];
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

class EvictingQueue<E> extends DoubleLinkedQueue<E> {
  final int limit;

  EvictingQueue(this.limit);

  @override
  void add(E value) {
    super.add(value);
    while (super.length > limit) {
      super.removeFirst();
    }
  }
}
