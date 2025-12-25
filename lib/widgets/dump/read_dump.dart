import 'dart:io';
import 'package:flutter/material.dart';
import 'package:miziptools/data_dir/data_dir.dart';
import 'package:miziptools/misc/snackbar.dart';
import 'package:miziptools/widgets/basic/container_with_border.dart';
import 'package:miziptools/widgets/dump/dialog_read_dump.dart';
import 'package:provider/provider.dart';

class ReadDump extends StatelessWidget{

  ReadDump({super.key});

  final currentDumpChoice = TextEditingController();

  @override
  Widget build(BuildContext context) {

    final dataDir = context.read<DataDir>();

    return ContainerWithBorder(child: 
      Column( spacing: 15,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text("Read dump", style: TextStyle(fontSize: 18),),
          Row(spacing: 15,
            children: [
              DropdownMenu(dropdownMenuEntries: getDumpList(dataDir.getFilesList()), controller: currentDumpChoice, width: 160,),
              OutlinedButton(onPressed: () => readDump(context), child: Text("Read"),)
            ],
          )
        ],
      )
    );
  }

  List<DropdownMenuEntry> getDumpList(List<FileSystemEntity> dataDir){
    return dataDir.map((entry) => DropdownMenuEntry(value: entry.path, label: entry.path.split("/").last.split(".").first)).where((name) => name.label != "uid_save").toList();
  }

  Future<void> readDump(BuildContext context) async{

    if(currentDumpChoice.text.isEmpty){
      if(context.mounted){
        showSnackBar(context, "You must select a file");
      }
      return;
    }

    final dataDir = context.read<DataDir>();

    try{
      final fileContent = dataDir.readFile("${currentDumpChoice.text}.dump");
      showDialog<String>(context: context, builder: (context) {
        return ReadDumpDialog(title: currentDumpChoice.text, dataToDisplay: fileContent,);
      });
    } catch(e){
      if(context.mounted){
        showSnackBar(context, "Error while reading dump : $e");
      }
    }

  }
}