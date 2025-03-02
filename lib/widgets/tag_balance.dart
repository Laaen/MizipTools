import 'package:flutter/material.dart';
import "../misc/mizip_tag.dart";

class TagBalance extends StatefulWidget{

  const TagBalance({super.key, required this.currentTag});

  final MizipTag currentTag;

  @override
  State<StatefulWidget> createState() {
    return TagBalanceState();
  }
}

class TagBalanceState extends State<TagBalance>{

  final _tagBalanceForm = GlobalKey<FormState>();

  final balanceController = TextEditingController();

  void changeBalance() async {
    if( _tagBalanceForm.currentState!.validate()){
      if(mounted){
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Setting balance to : ${balanceController.text}\$"), duration: Duration(seconds: 2),));
      }
      await widget.currentTag.setBalance(balanceController.text);
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    balanceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      child:  
      Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(color: Theme.of(context).colorScheme.onSecondary, borderRadius: BorderRadius.all(Radius.circular(20)), shape: BoxShape.rectangle),
        child: Row(
          spacing: 20,
          children: [
            Expanded(child: 
              Form(key: _tagBalanceForm,
                child: TextFormField(
                  controller: balanceController,
                  maxLength: 5,
                  maxLines: 1,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: "New balance",
                    border: UnderlineInputBorder()
                  ),
                  validator: (String? data){
                    if (data == null || data == ""){
                      return "Can't be empty";
                    }
                    double? value = double.tryParse(data);
                    // Check if valid number
                    if (value == null){
                      return "Not a valid number";
                    }
                    // Check if between two given values
                    if(value < 0.0){
                      return "Can't be negative";
                    }
                    if(value > 100.0){
                      return "Can't be over 100.0";
                    }
                    return null;
                  },
                )
              )
            )
          , OutlinedButton(onPressed: changeBalance, child: Text("Ok"))],
        ),
      )
    );
  }

}