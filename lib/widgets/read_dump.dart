import 'dart:io';
import 'package:flutter/material.dart';
import 'package:miziptools/widgets/basic/container_with_border.dart';
import 'package:miziptools/widgets/dialog_read_dump.dart';
import 'package:path_provider/path_provider.dart';

class ReadDump extends StatelessWidget{

  ReadDump({super.key});

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
              Text("Read dump", style: TextStyle(fontSize: 18),),
              Row(spacing: 15,
                children: [
                  DropdownMenu(dropdownMenuEntries: getDumpList(), controller: currentDumpChoice, width: 160,),
                  OutlinedButton(onPressed: () => readDump(context), child: Text("Read"),)
                ],
              )
            ],
          )
        );
      } else {
        return Text("Loading dump directory ...");
      }
      });
  }

  List<DropdownMenuEntry> getDumpList(){
    return dumpDir!.listSync().map((entry) => DropdownMenuEntry(value: entry.path, label: entry.path.split("/").last.split(".").first)).toList();
  }

  Future<void> readDump(BuildContext context) async{
    final fileContent = File("${dumpDir!.path}/${currentDumpChoice.text}.dump").readAsStringSync();
    showDialog<String>(context: context, builder: (context) {
      return ReadDumpDialog(title: currentDumpChoice.text, dataToDisplay: fileContent,);
    });
  }
}