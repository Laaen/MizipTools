import 'dart:io';

import 'package:flutter/material.dart';

class DataDir with ChangeNotifier{

  final Directory dataDir;

  DataDir({required this.dataDir});

  Future<void> writeFile(String fileName, String content) async{
    final file = File("${dataDir.path}/$fileName").openWrite();
    file.write(content);
    file.close();
    notifyListeners();
  }

  String readFile(String fileName){
    return File("${dataDir.path}/$fileName").readAsStringSync();
  }

  List<FileSystemEntity> getFilesList(){
    return dataDir.listSync();
  }

  List<FileSystemEntity> getDumpsList(){
    return dataDir.listSync().where((file) => file.path.split("/").last != "uid_save").toList();
  }

}