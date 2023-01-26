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
  Database? db;
  String path;

  DarvesterDB(this.path);

  Future<void> openDB(String? path, {bool tryToForce = false}) async {
    // Database safety:
    // Check if it isn't already an instance of a Database
    if (db is !Database && db == null) {
      // Create an instance of a new Database with is-null safety
      db ??= await openDatabase(path ?? this.path);
    // else try to force a Database close and assign a new instance
    } else if (db is Database && tryToForce) {
      await db?.close();
      db = await openDatabase(path ?? this.path);
    }
  }
}
