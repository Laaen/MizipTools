import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:miziptools/extensions/uint8list_extensions.dart';
import 'package:miziptools/nfc/currentnfctag.dart';
import 'package:miziptools/misc/snackbar.dart';
import 'package:miziptools/tags/mifare_keys.dart';
import 'package:miziptools/widgets/basic/container_with_border.dart';
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
    final fileName = tag.getUid().toHexString().toUpperCase();

    showSnackBar(context, "Dumping tag's data");
    try{
      final rawDump = await tag.dumpTagData();
      final stringDump = toStringDump(rawDump);
      final dumpWithKeys = addKeysToDump(stringDump, keys);
      writeDumpToFile(context, fileName, dumpWithKeys);
      if(context.mounted){
        showSnackBar(context, "Dump done file : $fileName.dump");
      }
    } catch (err){
      if(context.mounted){
        showSnackBar(context, "Error while dumping tag : ${err.toString()}");
      }
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
      final keyA = keys.a[sectorNb].toHexString().toUpperCase();
      final keyB = keys.b[sectorNb].toHexString().toUpperCase();
      final permissions = modifiedDump[blockNb].substring(12, 20);
      modifiedDump[blockNb] = keyA + permissions + keyB;
    }
    return modifiedDump;
  }

  void writeDumpToFile(BuildContext context, String fileName, List<String> content) async {
    final dir = context.read<Directory>();
    final fileFullPath = "${dir.path}/$fileName.dump";

    final file = File(fileFullPath).openWrite();
    file.writeAll(content, "\n");
    file.close();
  }

}