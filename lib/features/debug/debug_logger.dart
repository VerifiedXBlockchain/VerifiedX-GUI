import 'dart:io';

import 'package:flutter/foundation.dart';

import '../../utils/files.dart';

class DebugLogger {
  static const fileName = 'debug-gui.txt';

  /// Appends [error] and [stackTrace] to `debug-gui.txt` in the network's
  /// Databases folder. Never throws: a logging failure is printed and dropped
  /// so it cannot mask the error being logged.
  static Future<void> log(Object error, StackTrace stackTrace) async {
    if (kIsWeb) {
      return;
    }
    try {
      final folder = await databasesPath();
      await appendEntry(File("$folder${Platform.pathSeparator}$fileName"), error, stackTrace);
    } catch (e) {
      print("DebugLogger could not write the log entry: $e");
    }
  }

  /// Appends one timestamped entry to [file], creating it and its folders
  /// when missing.
  @visibleForTesting
  static Future<void> appendEntry(File file, Object error, StackTrace stackTrace) async {
    await file.parent.create(recursive: true);
    final entry = ["", "--${DateTime.now().toString()}--", "", error.toString(), stackTrace.toString()].join("\n");
    await file.writeAsString("$entry\n", mode: FileMode.append);
  }
}
