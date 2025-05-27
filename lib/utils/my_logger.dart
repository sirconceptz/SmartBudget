import 'dart:async';
import 'dart:io';

import 'package:intl/intl.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';

class MyLogger {
  MyLogger();

  static bool isTestMode = false;

  static Future<void> write(String tag, String message) async {
    if (isTestMode) return;
    var parsedDate = DateTime.now();
    final String filenamePrefix = "SMART_BUDGET_LOG";
    final String extension = ".txt";
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String appVersion = packageInfo.version;
    Directory externalStorageDirectory =
        await getApplicationDocumentsDirectory();
    String path = externalStorageDirectory.path;
    String fileName = filenamePrefix + appVersion + extension;
    String date = DateFormat("dd.MM.yyyy HH.mm.ss.SSS").format(parsedDate);
    String newLog = "$date : $tag : $message\n";
    final file = File('$path/$fileName');
    await file.writeAsString(newLog, mode: FileMode.append);
  }

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<String?> getFileUri() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    final String filenamePrefix = "SMART_BUDGET_LOG";
    final String extension = ".txt";
    String appVersion = packageInfo.version;
    String directoryPath = await _localPath;
    String path = "$directoryPath/$filenamePrefix$appVersion$extension";
    if (await File(path).exists()) {
      return path;
    } else {
      return null;
    }
  }
}
