import 'dart:io';
import 'dart:typed_data';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:miziptools/nfc/currentnfctag.dart';
import 'package:miziptools/misc/snackbar.dart';
import 'package:miziptools/tags/mifare_keys.dart';
import 'package:miziptools/widgets/basic/containerWithBorder.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

class DumpTag extends StatelessWidget{

  const DumpTag({super.key});

  @override
  Widget build(BuildContext context) {
    return ContainerWithBorder(
      child: OutlinedButton(onPressed: () async => await dumpTag(context), child: Text("Dump Tag"),),
    );
  }

  Future<void> dumpTag(BuildContext context) async{

    final tag = context.read<CurrentNFCTag>();
    final keys = tag.getKeys();
    final fileName = tag.getUid();

    showSnackBar(context, "Dumping tag's data");
    try{
      final rawDump = await tag.dumpTagData();
      final stringDump = toStringDump(rawDump);
      final dumpWithKeys = addKeysToDump(stringDump, keys);
      writeDumpToFile(fileName, dumpWithKeys);
      showSnackBar(context, "Dump done file : $fileName");
    } catch (err){
      showSnackBar(context, "Error while dumping tag : ${err.toString()}");
    }
  }

  List<String> toStringDump(List<Uint8List> rawDump){
    List<String> result = [];
    for(final block in rawDump){
      result.add(formatLineData(block));
    }
    return result;
  }

  String formatLineData(Uint8List lineData){
    return lineData.map((byte) => byte.toRadixString(16).padLeft(2, '0').toUpperCase())
    .join("");
  }

  List<String> addKeysToDump(List<String> dump, MifareKeys keys){
    var modifiedDump = dump.toList();
    for (final (sectorNb, blockNb) in [3, 7, 11, 15, 19].indexed){
      final keyA = formatKey(keys.a[sectorNb]);
      final keyB = formatKey(keys.b[sectorNb]);
      final permissions = modifiedDump[blockNb].substring(12, 20);
      modifiedDump[blockNb] = keyA + permissions + keyB;
    }
    return modifiedDump;
  }

  String formatKey(String key) {
    return key.characters.slices(2)
    .map((x) => x.join("").toUpperCase())
    .join("");
  }

  void writeDumpToFile(String fileName, List<String> content) async {
    final dir = await getExternalStorageDirectory();
    final fileFullPath = "${dir!.path}/$fileName.dump";

    final file = File(fileFullPath).openWrite();
    file.writeAll(content, "\n");
    file.close();
  }

}