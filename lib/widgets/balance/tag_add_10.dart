import "dart:math";

import 'package:flutter/material.dart';
import "package:miziptools/exceptions/nfc_exception_handler.dart";
import "package:miziptools/nfc/currentnfctag.dart";
import "package:miziptools/misc/snackbar.dart";
import "package:miziptools/widgets/basic/container_with_border.dart";
import "package:provider/provider.dart";


class TagAdd10 extends StatelessWidget{

  const TagAdd10({super.key});

  @override
  Widget build(BuildContext context) {
    return ContainerWithBorder(
      child: OutlinedButton(onPressed: () => add10(context), child: Text("Add 10\$"),),
    );
  }

  void add10(BuildContext context) async {
    
    showSnackBar(context, "Adding 10\$");
    final tag = context.read<CurrentNFCTag>();

    try{
      await tag.updateInnerBalance();
    } catch(e){
      if(context.mounted){
        showSnackBar(context, "Error: Could not get tag's current balance");
      }
      return;
    }

    final currentBalance = tag.getBalance();
    if(!currentBalance.isValid()){
      if(context.mounted){
        showSnackBar(context, "Error: The retreived balance is incorrect");
      }
      return;
    }

    final newBalance = min(currentBalance.getDoubleBalance() + 10, 100.0);

    try {
      await tag.setBalance(newBalance.toString());
    } on Exception catch (e) {
      // ignore: use_build_context_synchronously
      NfcExceptionHandler.handleException(e, context);
      return;
    }

    if(context.mounted){
      showSnackBar(context, "Balance changed successfully");  
    }
  }
}

