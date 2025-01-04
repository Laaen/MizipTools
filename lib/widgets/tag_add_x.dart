import 'package:flutter/material.dart';
import "../misc/mizip_tag.dart";

/// Widget holding the "Add 10$" functionnality
class TagAdd10 extends StatelessWidget{
  TagAdd10({super.key, required this.currentTag});
  final MizipTag currentTag;

  //TODO: Add NFC stuff here
  void add10() async {
    final currentBalance = await currentTag.getBalance();
    if (currentBalance == null){
      // TODO: Error handling
    }
    await currentTag.setBalance((double.parse(currentBalance!) + 10.0).toString());
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      padding: EdgeInsets.all(20),
      margin: EdgeInsets.fromLTRB(40, 15, 40, 20),
      decoration: BoxDecoration(color: Theme.of(context).colorScheme.onSecondary, 
        shape: BoxShape.rectangle,
        borderRadius: BorderRadius.all(Radius.circular(20))),
      child: ElevatedButton(onPressed: add10, child: Text("Add 10\$"),),
    );
  }

}