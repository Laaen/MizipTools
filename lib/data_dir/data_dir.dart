import "dart:io";
import "package:flutter/material.dart";

/// Class used for interacting with the data folder on the phone
/// It is used as a global object allowing operations on the data folder
/// All methods do their work in the dataDir folder
class DataDir with ChangeNotifier {
  /// Initializes a DataDir object, must be called with where you want to work
  /// In our case it's Android/data/com.laen.miziptools_v2/files/
  DataDir({required this.dataDir});

  /// Directory pointing to the "Android/data/com.laen.miziptools_v2/files/" folder
  final Directory dataDir;

  /// Writes the provided content to the file
  /// Triggers a listener notification in order to reload the UI
  Future<void> writeFile(String fileName, String content) async {
    final file = File("${dataDir.path}/$fileName").openWrite()..write(content);
    await file.close();
    notifyListeners();
  }

  /// Returns the content of the file
  String readFile(String fileName) {
    return File("${dataDir.path}/$fileName").readAsStringSync();
  }

  /// Returns a list of [FileSystemEntity] present in the folder
  List<FileSystemEntity> getFilesList() {
    return dataDir.listSync();
  }

  /// Returns a list of [FileSystemEntity] of the tag dumps
  List<FileSystemEntity> getDumpsList() {
    return dataDir
        .listSync()
        .where(
          (file) => file.path.split("/").last != "uid_save",
        )
        .toList();
  }
}
