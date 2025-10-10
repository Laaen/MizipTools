import 'dart:io';
import 'dart:typed_data';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_nfc_kit/flutter_nfc_kit.dart';
import 'package:miziptools/misc/snackbar.dart';
import 'package:miziptools/nfc/currentnfctag.dart';
import 'package:miziptools/widgets/basic/containerWithBorder.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

class WriteFromDump extends StatelessWidget{

  WriteFromDump({super.key});

  final currentDumpChoice = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(future: getDumpList(), builder: (context, result) {

      if(result.hasData && result.data != null){
        return ContainerWithBorder(child: 
          Column( spacing: 15,
            children: [
              Text("Write dump", style: TextStyle(fontSize: 18),),
              DropdownMenu(dropdownMenuEntries: result.data!, controller: currentDumpChoice,),
              OutlinedButton(onPressed: () => writeDump(context), child: Text("Write"),)
            ],
          )
        );
      } else {
        return Text("blip");
      }
      });
  }

  Future<List<DropdownMenuEntry>> getDumpList() async{
    final dir = await getExternalStorageDirectory();
    // Split pour prendre nom du fichier
    return dir!.listSync().map((entry) => DropdownMenuEntry(value: entry, label: entry.path)).toList();
  }

  Future<void> writeDump(BuildContext context) async{
    
    final tag = context.read<CurrentNFCTag>();
    
    final dumpData = getDumpDataFromFile(currentDumpChoice.text);
    showSnackBar(context, "Writing dump to tag");
    await tag.writeDumpToTag(dumpData);
    showSnackBar(context, "Dump successfully written !");
    // DIsconnect to poll new tag
    //await FlutterNfcKit.finish();
  }

  List<Uint8List> getDumpDataFromFile(String path) {
    final stringData = File(path).readAsLinesSync();
    return stringData.map((block){
      return Uint8List.fromList(block.split("").slices(2).map((x) => int.parse(x.join(), radix: 16)).toList());
    }).toList();
  }

}