import 'dart:io';
import 'dart:typed_data';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:logging/logging.dart';
import 'package:miziptools/misc/snackbar.dart';
import 'package:miziptools/nfc/currentnfctag.dart';
import 'package:miziptools/nfc/nfc_adapter.dart';
import 'package:miziptools/widgets/basic/containerWithBorder.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

class WriteFromDump extends StatelessWidget{

  WriteFromDump({super.key});

  Directory? dumpDir;
  final currentDumpChoice = TextEditingController();
  late List<DropdownMenuEntry> filesList;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(future: getExternalStorageDirectory(), builder: (context, result) {
      if(result.hasData && result.data != null){
        dumpDir = result.data!;
        return ContainerWithBorder(child: 
          Column( spacing: 15,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text("Write dump to tag", style: TextStyle(fontSize: 18),),
              Row(spacing: 20,
                children: [
                  DropdownMenu(dropdownMenuEntries: getDumpList(), controller: currentDumpChoice, width: 180,),
                  OutlinedButton(onPressed: () => writeDump(context), child: Text("Write"),)
                ],
              )
            ],
          )
        );
      } else {
        return Text("blip");
      }
      });
  }

  // TODO : Faire en sorte d'avoir uniquement le nom de fichier de visible
  List<DropdownMenuEntry> getDumpList(){
    // Split pour prendre nom du fichier
    return dumpDir!.listSync().map((entry) => DropdownMenuEntry(value: entry.path, label: entry.path.split("/").last)).toList();
  }

  Future<void> writeDump(BuildContext context) async{
    
    final tag = context.read<CurrentNFCTag>();
    final nfcAdapter = context.read<NfcAdapter>();
    
    final dumpData = getDumpDataFromFile("${dumpDir!.path}/${currentDumpChoice.text}");
    showSnackBar(context, "Writing dump to tag");
    await tag.writeDumpToTag(dumpData);
    showSnackBar(context, "Dump successfully written !");
    // Disconnect to poll new tag
    try{
      await nfcAdapter.releaseTag();
    } on PlatformException catch(e){
      if (e.code == 503){
        Logger.root.info("Tag already disconnected");
        showSnackBar(context, "Error, the tag was removed during the write");
      }
    }
  }

  List<Uint8List> getDumpDataFromFile(String path) {
    final stringData = File(path).readAsLinesSync();
    return stringData.map((block){
      return Uint8List.fromList(block.split("").slices(2).map((x) => int.parse(x.join(), radix: 16)).toList());
    }).toList();
  }

}