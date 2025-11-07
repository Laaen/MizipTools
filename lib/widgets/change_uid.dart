import 'package:flutter/material.dart';
import 'package:miziptools/extensions/string_extensions.dart';
import 'package:miziptools/misc/snackbar.dart';
import 'package:miziptools/nfc/currentnfctag.dart';
import 'package:miziptools/nfc/nfc_adapter.dart';
import 'package:miziptools/widgets/basic/containerWithBorder.dart';
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
    final nfcAdapter = context.read<NfcAdapter>();
    if(_uidFormKey.currentState!.validate()){
      showSnackBar(context, "Changing UID");
      try{
        await tag.setUid(_uidFormController.text.toUint8List());
        showSnackBar(context, "UID change succeful");
        // Release to poll new tag
        await nfcAdapter.releaseTag();
      }catch(e){
        showSnackBar(context, "Error : $e");
      }
    }
  }
}