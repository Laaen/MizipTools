import 'package:flutter/material.dart';
import 'package:miziptools/exceptions/nfc_exception_handler.dart';
import 'package:miziptools/extensions/string_extensions.dart';
import 'package:miziptools/misc/snackbar.dart';
import 'package:miziptools/nfc/currentnfctag.dart';
import 'package:miziptools/widgets/basic/container_with_border.dart';
import 'package:provider/provider.dart';

class ChangeUid extends StatelessWidget{

  ChangeUid({super.key});

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
        labelText: "New UID",
        border: UnderlineInputBorder()
      ),
    );

    return ContainerWithBorder(
      child: Row(
        spacing: 20,
        children: [
          Expanded(child: Form(key: _uidFormKey, child: textField)),
          OutlinedButton(onPressed: ()async => changeUid(context), child: Text("Ok"))
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

  Future<void> changeUid(BuildContext context) async{
    final tag = context.read<CurrentNFCTag>();
    if(_uidFormKey.currentState!.validate()){
      showSnackBar(context, "Changing UID");
      try{
        await tag.setUid(_uidFormController.text.toUint8List());
      } on Exception catch(e){
        // ignore: use_build_context_synchronously
        NfcExceptionHandler.handleException(e, context);
        return;
      }
        
      if(context.mounted){
        showSnackBar(context, "UID changed successfully");
      }

      try{
        await tag.releaseTag();
      } on Exception catch(e){
        // ignore: use_build_context_synchronously
        NfcExceptionHandler.handleException(e, context);
        return;
      }
    }
  }
}