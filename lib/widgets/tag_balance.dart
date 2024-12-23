import 'package:flutter/material.dart';

class TagBalance extends StatefulWidget{

  TagBalance({super.key});

  @override
  State<StatefulWidget> createState() {
    return TagBalanceState();
  }
}

class TagBalanceState extends State<TagBalance>{

  final _tabBalanceKey = GlobalKey<FormState>();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print("Création");
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      child:  
      Container(
        padding: EdgeInsets.all(20),
        margin: EdgeInsets.fromLTRB(40, 15, 40, 0),
        decoration: BoxDecoration(color: Theme.of(context).colorScheme.onSecondary, borderRadius: BorderRadius.all(Radius.circular(20)), shape: BoxShape.rectangle),
        child: Row(
          children: [
            Expanded(child: 
              TextFormField(
                maxLength: 5,
                maxLines: 1,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: "New balance",
                  border: UnderlineInputBorder()
                ),
                validator: (String? data){
                  if (data == null || data == ""){
                    return "Value can't be empty";
                  } else if (data.contains("-")){
                    return "Value can't be negative";
                  }
                  return null;
                },
              )
            )
          ],
        ),
      )
    );
  }

}