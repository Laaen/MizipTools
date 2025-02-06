import 'package:flutter/material.dart';
import "../misc/mizip_tag.dart";
import "package:logging/logging.dart";

class TagAdd10 extends StatefulWidget{

  final MizipTag currentTag;

  TagAdd10({required this.currentTag});

  @override
  State<StatefulWidget> createState() => _TagAdd10State();
}


/// Widget holding the "Add 10$" functionnality
class _TagAdd10State extends State<TagAdd10>{
  
  _TagAdd10State();

  void add10(MizipTag currentTag) async {
    Logger.root.info("Button `Add 10` pressed");
    if(mounted){
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Adding 10\$"), duration: Duration(seconds: 10),));
    }

    bool writeStatus;
    final currentBalance = await currentTag.getBalance();
    Logger.root.info("Got Tag's balance");
    if (currentBalance == null){
      Logger.root.severe("Can't get tag's balance");
      writeStatus = false;
    } else if (double.parse(currentBalance) + 10 > 100){
      Logger.root.info("Setting tag's balance to 100");
      writeStatus = await currentTag.setBalance(100.toString());
    } else {
      Logger.root.info("Writing new balance to tag ${double.parse(currentBalance) + 10.0}");
      writeStatus = await currentTag.setBalance((double.parse(currentBalance) + 10.0).toString());
    }

    // Show a message
    if (writeStatus == true){
      if (mounted){
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Added 10\$"), duration: Duration(seconds: 2),));
      }
    } else {
      if(mounted){
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error while adding 10\$"), duration: Duration(seconds: 2),));
      }
    }
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
      child: ElevatedButton(onPressed: () => add10(widget.currentTag), child: Text("Add 10\$"),),
    );
  }

}