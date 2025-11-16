import 'dart:io';
import 'package:flutter/material.dart';
import 'package:miziptools/widgets/basic/container_with_border.dart';
import 'package:miziptools/widgets/dialog_read_dump.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

class ReadDump extends StatelessWidget{

  ReadDump({super.key});

  final currentDumpChoice = TextEditingController();

  @override
  Widget build(BuildContext context) {

    final dataDir = context.read<Directory>();

    return ContainerWithBorder(child: 
      Column( spacing: 15,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text("Read dump", style: TextStyle(fontSize: 18),),
          Row(spacing: 15,
            children: [
              DropdownMenu(dropdownMenuEntries: getDumpList(dataDir), controller: currentDumpChoice, width: 160,),
              OutlinedButton(onPressed: () => readDump(context), child: Text("Read"),)
            ],
          )
        ],
      )
    );
  }

  List<DropdownMenuEntry> getDumpList(Directory dataDir){
    return dataDir.listSync().map((entry) => DropdownMenuEntry(value: entry.path, label: entry.path.split("/").last.split(".").first)).where((name) => name.label != "uid_save").toList();
  }

  Future<void> readDump(BuildContext context) async{
    final dataDir = context.read<Directory>();
    final fileContent = File("${dataDir.path}/${currentDumpChoice.text}.dump").readAsStringSync();
    showDialog<String>(context: context, builder: (context) {
      return ReadDumpDialog(title: currentDumpChoice.text, dataToDisplay: fileContent,);
    });
  }
}