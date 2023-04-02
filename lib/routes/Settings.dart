import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart' show getApplicationSupportDirectory;
import 'package:path/path.dart' as p;

// Util
import '../util.dart';

// Components
import '../components/Snackbars.dart';

class _Settings extends StatefulWidget {
  const _Settings({Key? key}) : super(key: key);

  @override
  State<_Settings> createState() => _SettingsState();
}

/// Contains the state and methods available to modify the state of settings
///
/// - [Map] [prefs]: contains a key-value pair for each preference entry needed
class _SettingsState extends State<_Settings> {
  Map<String, dynamic> prefs = {};

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  /// Loads needed settings entries into the state. This is usually only needed
  /// on first load of the widget.
  /// Will first build a local [Map] of keys and values that we need to populate
  /// the settings page with, getting the values from the [Preferences] store,
  /// then will update the state with this [Map].
  Future<void> _loadPrefs() async {
    Map<String, dynamic> prefs = {
      "databasePath": await Preferences.instance.getString("databasePath"),
    };
    setState(() {
      this.prefs = prefs;
    });
  }

  /// Sets a key and value in the state's [prefs].
  Future<String> setKey(String key, String value) async {
    Map<String, dynamic> prefs = this.prefs;
    prefs.update(key, (_) => value, ifAbsent: () => value);
    await Preferences.instance.setString(key, value);
    setState(() {
      this.prefs = prefs;
    });
    return prefs[key] as String;
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
            margin: const EdgeInsets.all(24),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: const Color(0xff333333),
                boxShadow: const <BoxShadow>[
                  BoxShadow(color: Color(0x66000000), offset: Offset(6, 6), blurRadius: 6),
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
                          "Database:",
                          textAlign: TextAlign.left,
                          style: TextStyle(fontFamily: "UnboundedBold", fontSize: 24),
                        ),
                        const SizedBox(width: 36),
                        Expanded(
                            child: Text(
                          (prefs["databasePath"] == null || prefs["databasePath"].toString().isEmpty) ? "Not set" : prefs["databasePath"] as String,
                          style: const TextStyle(
                            fontFamily: "Courier",
                          ),
                          overflow: TextOverflow.fade,
                          maxLines: 1,
                          softWrap: false,
                        )),
                        const SizedBox(width: 36),
                        ElevatedButton(
                            onPressed: () {
                              FilePicker.platform
                                  .pickFiles(type: FileType.custom, allowedExtensions: <String>["db"], dialogTitle: "Pick your harvested.db")
                                  .then((pathToDB) async {
                                if ((pathToDB?.files.single.path ?? "").isEmpty) {
                                  setKey("databasePath", p.join((await getApplicationSupportDirectory()).path, 'harvested.db')).then((_) async {
                                    showSnackbar(context,
                                        ErrorsSnackbars.genericError("Defaulting to ${p.join((await getApplicationSupportDirectory()).path, 'harvested.db')}"));
                                  }).catchError((dynamic err) {
                                    showSnackbar(context,
                                        ErrorsSnackbars.genericError(kDebugMode ? "Could not save database setting" : "Could not save database setting: $err"));
                                  });
                                } else {
                                  setKey("databasePath", pathToDB?.files.single.path ?? "").then((_) {
                                    showSnackbar(context, SettingsSnackbars.settingSaved("databasePath"));
                                  }).catchError((dynamic err) {
                                    showSnackbar(context,
                                        ErrorsSnackbars.genericError(kDebugMode ? "Could not save database setting" : "Could not save database setting: $err"));
                                  });
                                }
                              });
                            },
                            child: const Icon(Icons.folder))
                      ],
                    ),
                    const SizedBox(height: 36),
                    if (kDebugMode)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ElevatedButton(
                              onPressed: () async {
                                Preferences.instance.setString("databasePath", "").then((_) {
                                  setKey("databasePath", "");
                                  showSnackbar(context, SettingsSnackbars.settingSaved("databasePath"));
                                });
                              },
                              child: const Text("Reset Database Path")),
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
