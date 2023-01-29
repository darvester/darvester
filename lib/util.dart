import 'package:sqflite/sqflite.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class Preferences {
  Preferences._privateConstructor();

  static final Preferences instance = Preferences._privateConstructor();

  setBool(String key, bool value) async {
    SharedPreferences prefsInstance = await SharedPreferences.getInstance();
    prefsInstance.setBool(key, value);
  }

  setString(String key, String value, {bool isSecret = false}) async {
    SharedPreferences prefsInstance = await SharedPreferences.getInstance();
    prefsInstance.setString(key, isSecret ? base64.encode(utf8.encode(value)) : value);
  }

  Future<bool> getBool(String key) async {
    SharedPreferences prefsInstance = await SharedPreferences.getInstance();
    return prefsInstance.getBool(key) ?? false;
  }

  Future<String> getString(String key) async {
    SharedPreferences prefsInstance = await SharedPreferences.getInstance();
    return prefsInstance.getString(key) ?? "";
  }
}

class DarvesterDB {
  late Database db;

  DarvesterDB._privateConstructor();

  static final DarvesterDB instance = DarvesterDB._privateConstructor();

  Future<Database> openDB(String path, {bool tryToForce = false}) async {
    if (tryToForce) {
      await db.close();
    }
    db = await openDatabase(path, version: 1);
    return db;
  }

  Future<List<Map>> getGuilds({int limit = 50, int offset = 0, List<String> columns = const ["data"]}) async {
    String limitStr = limit > 0 ? " LIMIT $limit " : "";
    String offsetStr = offset > 0 ? " OFFSET $offset " : "";
    List<Map> guilds = await db.rawQuery('SELECT ${columns.join(", ")}, id FROM guilds $limitStr $offsetStr');
    return guilds;
  }

  Future<Map> getGuild(int id, {List<String> columns = const ["data"]}) async {
    List<Map> guild = await db.rawQuery('SELECT ${columns.join(", ")}, id FROM guilds WHERE id = ?', [
      id,
    ]);
    return guild[0];
  }
}
