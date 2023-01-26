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

  void openDB(String path) {}
}
