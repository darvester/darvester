import 'package:flutter/material.dart';

void showSnackbar(BuildContext context, SnackBar snackbar) {
  ScaffoldMessenger.of(context).showSnackBar(snackbar);
}

class SettingsSnackbars {
  static SnackBar settingSaved(String key) {
    return SnackBar(
      content: Text("Setting $key saved"),
    );
  }

  static const settingsSaved = SnackBar(content: Text("Settings saved"));
}

class ErrorsSnackbars {
  static SnackBar genericError(String msg) {
    return SnackBar(content: Text("Error: $msg"));
  }
}
