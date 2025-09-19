import 'package:flutter/material.dart';
import 'package:miziptools/misc/nfctag.dart';
import 'package:miziptools/misc/snackbar.dart';
import 'package:miziptools/main.dart';
import 'package:miziptools/widgets/basic/containerWithBorder.dart';
import 'package:provider/provider.dart';
import "../misc/mizip_tag.dart";

class TagBalance extends StatelessWidget{

  TagBalance({super.key});

  final _tagBalanceForm = GlobalKey<FormState>();
  final balanceController = TextEditingController();

  @override
  Widget build(BuildContext context) {

    final textField = newBalanceField();

    return Form(
      child: ContainerWithBorder(
        child: Row(
          spacing: 20,
          children: [
            Expanded(child: Form(key: _tagBalanceForm, child: textField)),
            OutlinedButton(onPressed: () => changeBalance(context), child: Text("Ok"))],
        ),
      )
    );
  }

  TextFormField newBalanceField(){
    return TextFormField(
      controller: balanceController, 
      maxLength: 5, 
      maxLines: 1, 
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: "New balance",
        border: UnderlineInputBorder()
      ),
      validator: newBalanceValidator
    );
  }

  String? newBalanceValidator(String? newBalance){
     if (newBalance == null || newBalance.isEmpty){
        return "Can't be empty";
      }
      double? value = double.tryParse(newBalance);
      if (value == null){
        return "Not a valid number";
      }
      if(value < 0.0){
        return "Can't be negative";
      }
      if(value > 100.0){
        return "Can't be over 100.0";
      }
      return null;
  }

  void changeBalance(BuildContext context) async {
    if( _tagBalanceForm.currentState!.validate()){
      final tag = context.read<CurrentNFCTag>();
      showSnackBar(context, "Changing balance");
      await tag.setBalance(balanceController.text);
      if(context.mounted){
        showSnackBar(context, "Balance changed successfully");  
      }
    }
  }

}