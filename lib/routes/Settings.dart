import 'dart:io';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

// Util
import '../util.dart';

class _Settings extends StatefulWidget {
  const _Settings({Key? key}) : super(key: key);

  @override
  State<_Settings> createState() => _SettingsState();
}

class _SettingsState extends State<_Settings> {
  Map prefs = {};

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    Map _prefs = {
      "databasePath": await Preferences.instance.getString("databasePath"),
    };
    setState(() {
      prefs = _prefs;
    });
  }

  Future<String> setKey(String key, String value) async {
    Map _prefs = prefs..addAll({key: value});
    setState(() {
      prefs = _prefs;
    });
    return prefs[key];
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          flex: 2,
          child: Container(),
        ),
        Expanded(
          flex: 6,
          child: Container(
            margin: const EdgeInsets.all(36),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: const Color(0xff333333),
                boxShadow: const <BoxShadow>[
                  BoxShadow(
                      color: Color(0x66000000),
                      offset: Offset(6, 6),
                      blurRadius: 6),
                ],
                border: Border.all(
                  width: 0,
                ),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Container(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Database",
                          textAlign: TextAlign.left,
                          style: TextStyle(
                              fontFamily: "UnboundedBold", fontSize: 24),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            FilePicker.platform.pickFiles(
                              type: FileType.custom,
                              allowedExtensions: <String>["db"],
                              dialogTitle: "Pick your harvested.db"
                            ).then((pathToDB) => {
                                prefs["databasePath"] = pathToDB?.files.single.path ?? ""
                            });
                          },
                          child: const Icon(Icons.folder)
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        Expanded(flex: 2, child: Container()),
      ],
    );
  }
}

class Settings extends StatelessWidget {
  const Settings({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: const _Settings(),
    );
  }
}
