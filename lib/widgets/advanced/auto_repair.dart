import 'dart:io';

import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:miziptools/data_dir/data_dir.dart';
import 'package:miziptools/exceptions/nfc_exception_handler.dart';
import 'package:miziptools/extensions/string_extensions.dart';
import 'package:miziptools/misc/snackbar.dart';
import 'package:miziptools/nfc/currentnfctag.dart';
import 'package:miziptools/widgets/basic/container_with_border.dart';
import 'package:provider/provider.dart';

class AutoRepair extends StatelessWidget {

  AutoRepair({super.key});

  final _uidFormKey = GlobalKey<FormState>();
  final _uidFormController = TextEditingController();

  static const validChars = "0123456789ABCDEF";

  @override
  Widget build(BuildContext context) {
    final textField = TextFormField(
      controller: _uidFormController,
      maxLength: 8,
      validator: uidFieldValidator,
      decoration: InputDecoration(
        labelText: "Old UID",
        border: UnderlineInputBorder()
      ),
    );

    _uidFormController.text = getSavedUid(context);

    return ContainerWithBorder(
      child: Column(
        spacing: 10,
        children: [
          Text("Auto-Repair", style: TextStyle(fontSize: 18),),
          Row(
            spacing: 20,
            children: [
              Expanded(child: Form(key: _uidFormKey, child: textField)),
              OutlinedButton(onPressed: ()async => autoRepair(context), child: Text("Ok"))
            ],
          )
        ],
      )
    );
  }

  String? uidFieldValidator(String? data){
    data = data?.toUpperCase();

    if(data == null || data.length < 8){
      return "UID must be 8 chars";
    } if (data.characters.any((char) => !validChars.contains(char))){
      return "Must be valid hexa";
    }
    return null;
  }

  Future<void> autoRepair(BuildContext context) async{
    final tag = context.read<CurrentNFCTag>();
    if(_uidFormKey.currentState!.validate()){
      
      showSnackBar(context, "Trying to auto-repair");

      try{
        await tag.autoRepair(_uidFormController.text.toUint8List());
        if(context.mounted){
          showSnackBar(context, "Repair successful");
        }      
      } on Exception catch(e) {
        // ignore: use_build_context_synchronously
        NfcExceptionHandler.handleException(e, context);
        return;
      }

      try{
        // Release to poll new tag
        await tag.releaseTag();
      } on Exception catch(e){
        // ignore: use_build_context_synchronously
        NfcExceptionHandler.handleException(e, context);
        return;
      }
  
    }
  }

  String getSavedUid(BuildContext context){
    try{
      final dataDir = context.read<DataDir>();
      return dataDir.readFile("uid_save");
    } on FileSystemException catch(e){
      Logger.root.severe("Error while reading save uid file : $e");
      return "00000000";
    }
  }

}