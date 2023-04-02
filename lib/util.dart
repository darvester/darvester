import 'dart:math';
import 'dart:developer' as developer;
import 'dart:convert';
import 'dart:collection';

import 'package:darvester/routes/Settings.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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
void showAlertDialog(BuildContext context, String title, String content) {
  showDialog<void>(
      context: context,
      builder: (BuildContext builder) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: <Widget>[
            TextButton(onPressed: () => context.go("/"), child: const Text("Go back")),
            TextButton(
              onPressed: () => Navigator.of(context).push(MaterialPageRoute<dynamic>(builder: (context) => const Settings())),
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

  Future<void> setBool(String key, bool value) async {
    logger.debug("Setting shared_prefs bool: $key=$value");
    SharedPreferences prefsInstance = await SharedPreferences.getInstance();
    prefsInstance.setBool(key, value);
  }

  Future<void> setString(String key, String value, {bool isSecret = false}) async {
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

class EvictingQueue<E> extends DoubleLinkedQueue<E> with ChangeNotifier {
  final int limit;

  EvictingQueue(this.limit);

  @override
  void add(E value) {
    super.add(value);
    notifyListeners();
    while (super.length > limit) {
      super.removeFirst();
    }
  }
}
