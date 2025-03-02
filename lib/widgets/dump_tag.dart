import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:miziptools/misc/mizip_tag.dart';

class DumpTagWidget extends StatelessWidget{

  const DumpTagWidget({super.key, required this.currentTag});

  final MizipTag currentTag;

  Future<void> dumpTag(MizipTag tag) async{
    String dump = "";
    for (int i = 1 ; i < 5; i++){
      final sectorData = await tag.readSector(i, retries: 5);
      for (final elt in sectorData.slices(16)){
        dump += "${elt.map((x) => x.toRadixString(16).padLeft(2, '0')).join(" ")}\n";
      }
    }

    // Add keys to the dump
    

    print(dump);
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