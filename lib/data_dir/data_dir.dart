import "dart:io";
import "package:flutter/material.dart";

/// Class used for interacting with the data folder on the phone
/// It is used as a global object allowing operations on the data folder
class DataDir with ChangeNotifier {
  /// Initializes a DataDir object, must be called with where you want to do stuff
  /// In our case it's Android/data/com.laen.miziptools_v2/files/
  DataDir({required this.dataDir});

  /// Directory pointing to the "Android/data/com.laen.miziptools_v2/files/" folder
  final Directory dataDir;

  /// Writes the provided content to the file
  Future<void> writeFile(final String fileName, final String content) async {
    final IOSink file = File("${dataDir.path}/$fileName").openWrite();
    file.write(content);
    await file.close();
    notifyListeners();
  }

  String readFile(String fileName) {
    return File("${dataDir.path}/$fileName").readAsStringSync();
  }

  List<FileSystemEntity> getFilesList() {
    return dataDir.listSync();
  }

  List<FileSystemEntity> getDumpsList() {
    return dataDir
        .listSync()
        .where((file) => file.path.split("/").last != "uid_save")
        .toList();
  }
}
