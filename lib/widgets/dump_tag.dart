import 'dart:io';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:miziptools/misc/mizip_tag.dart';
import 'package:path_provider/path_provider.dart';

class DumpTagWidget extends StatelessWidget{

  const DumpTagWidget({super.key, required this.currentTag});

  final MizipTag currentTag;

  Future<void> dumpTag(MizipTag tag) async{
    List<String> dump = [];
    for (int i = 1 ; i < 5; i++){
      final sectorData = await tag.readSector(i, retries: 5);
      for (final elt in sectorData.slices(16)){
        dump.add(elt.map((x) => x.toRadixString(16).padLeft(2, '0')).join(" "));
      }
    }

    // Add keys to the dump
    final keys = tag.getKeys();
    for (final (idx, elt) in [3, 7, 11, 15].indexed){
      dump[elt] = keys.a[idx].characters.slices(2).map((x) => x.join("")).join(" ") + dump[elt].substring(17, 30) + keys.b[idx].characters.slices(2).map((x) => x.join("")).join(" ");
    }

    // Write dump to a file
    final dir = await getExternalStorageDirectory();
    final fileName = "${dir!.path}/${tag.uid}.dump";

    final file = File(fileName).openWrite();
    file.writeAll(dump, "\n");
    file.close();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(color: Theme.of(context).colorScheme.onSecondary, 
        shape: BoxShape.rectangle,
        borderRadius: BorderRadius.all(Radius.circular(20))),
      child: OutlinedButton(onPressed: () async => await dumpTag(currentTag), child: Text("Dump Tag"),),
    );
  }
}