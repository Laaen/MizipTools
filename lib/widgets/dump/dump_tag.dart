import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:miziptools/data_dir/data_dir.dart';
import 'package:miziptools/exceptions/nfc_exception_handler.dart';
import 'package:miziptools/extensions/uint8list_extensions.dart';
import 'package:miziptools/nfc/currentnfctag.dart';
import 'package:miziptools/misc/snackbar.dart';
import 'package:miziptools/widgets/basic/container_with_border.dart';
import 'package:provider/provider.dart';

import '../../tags/mifare_classic_tag.dart';

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

    List<Uint8List> rawDump = [];
    try{
      rawDump = await tag.dumpTagData();
    } on Exception catch(e){
      // ignore: use_build_context_synchronously
      NfcExceptionHandler.handleException(e, context);
      return;
    }

    List<String> stringDump = [];
    try{
      stringDump = toStringDump(rawDump);
      stringDump = addKeysToDump(stringDump, keys);
    } catch (e){
      if(context.mounted){
        showSnackBar(context, "Error while processing dump : $e");
      }
      return;
    }

    try{
      if(context.mounted){
        writeDumpToFile(context, fileName, stringDump);
      }
    } catch (e){
      if(context.mounted){
        showSnackBar(context, "Error while writing dump to file : $e");
      }
      return;
    }

    if(context.mounted){
      showSnackBar(context, "Dump done file : $fileName.dump");
    }

  }

  List<String> toStringDump(List<Uint8List> rawDump){
    List<String> result = [];
    for(final block in rawDump){
      result.add(block.toHexString().toUpperCase());
    }
    return result;
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
    final dir = context.read<DataDir>();
    dir.writeFile("$fileName.dump", content.join("\n"));
  }

}