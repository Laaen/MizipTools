import 'dart:io';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:miziptools/data_dir/data_dir.dart';
import 'package:miziptools/exceptions/nfc_exception_handler.dart';
import 'package:miziptools/misc/snackbar.dart';
import 'package:miziptools/nfc/currentnfctag.dart';
import 'package:miziptools/widgets/basic/container_with_border.dart';
import 'package:provider/provider.dart';

class WriteFromDump extends StatelessWidget{

  WriteFromDump({super.key});

  final currentDumpChoice = TextEditingController();

  @override
  Widget build(BuildContext context) {

    final dataDir = context.read<DataDir>();

    return ContainerWithBorder(child: 
      Column( spacing: 15,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text("Write dump to tag", style: TextStyle(fontSize: 18),),
          Row(spacing: 20,
            children: [
              DropdownMenu(dropdownMenuEntries: getDumpList(dataDir.getFilesList()), controller: currentDumpChoice, width: 158.6,),
              OutlinedButton(onPressed: () => writeDump(context), child: Text("Write"),)
            ],
          )
        ],
      )
    );
  }

  List<DropdownMenuEntry> getDumpList(List<FileSystemEntity> dataDir){
    return dataDir.map((entry) => DropdownMenuEntry(value: entry.path, label: entry.path.split("/").last.split(".").first)).where((name) => name.label != "uid_save").toList();
  }

  Future<void> writeDump(BuildContext context) async{

    if(currentDumpChoice.text.isEmpty){
      if(context.mounted){
        showSnackBar(context, "You must select a file");
      }
      return;
    }
    
    final tag = context.read<CurrentNFCTag>();
    final dataDir = context.read<DataDir>();
    
    showSnackBar(context, "Writing dump to tag");

    List<Uint8List> dumpData;

    try{
      dumpData = getDumpDataFromFile(dataDir.readFile("${currentDumpChoice.text}.dump"));
    } catch (e){
      if(context.mounted){
        showSnackBar(context, "Error while reading dump file : $e");
      }
      return;
    }

    try{
      await tag.writeDumpToTag(dumpData);
    } on Exception catch(e){
      // ignore: use_build_context_synchronously
      NfcExceptionHandler.handleException(e, context);
      return;
    }
    
    if(context.mounted){
      showSnackBar(context, "Dump successfully written !");
    }

    // Disconnect to poll new tag
    try{
      await tag.releaseTag();
    } on Exception catch (e){
      // ignore: use_build_context_synchronously
      NfcExceptionHandler.handleException(e, context);
      return;
    }
  }

  List<Uint8List> getDumpDataFromFile(String dumpData) {
    return dumpData.split("\n").map((block){
      return Uint8List.fromList(block.split("").slices(2).map((x) => int.parse(x.join(), radix: 16)).toList());
    }).toList();
  }

}