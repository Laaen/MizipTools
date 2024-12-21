import 'package:flutter/material.dart';

/// Display the tag's data (UID and balance)
/// If not present, displays a message asking the user for scanning the tag
class TagData extends StatelessWidget{

  const TagData({super.key, this.uid, this.balance});

  final String? uid;
  final String? balance;

  @override
  Widget build(BuildContext context) {
    if (uid == null || balance == null){
      return _TagDataAbsent();
    } else {
      return _TagDataPresent(uid: uid!, balance: balance!);
    }
    
  }

}

class _TagDataPresent extends StatelessWidget{

  const _TagDataPresent({super.key, required this.uid, required this.balance});

  final String uid;
  final String balance;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      padding: EdgeInsets.all(20),
      margin: EdgeInsets.fromLTRB(40, 70, 40, 20),
      decoration: BoxDecoration(color: Theme.of(context).colorScheme.onSecondary, 
        shape: BoxShape.rectangle,
        borderRadius: BorderRadius.all(Radius.circular(20))),
      child: Column(
        spacing: 10,
        children: [
          Text("Tag info", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),),
          Row(spacing: 10,
            children: [
              Text("UID: ", style: TextStyle(fontSize: 16),),
              Text(uid, style: TextStyle(fontSize: 16),),
            ],
          ),
          Row(spacing: 10,
            children: [
              Text("Balance:", style: TextStyle(fontSize: 16),),
              Text("$balance\$", style: TextStyle(fontSize: 16),),
            ],
          )
        ],
      ), 
    );
  }

}

class _TagDataAbsent extends StatelessWidget{

  const _TagDataAbsent({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      padding: EdgeInsets.all(20),
      margin: EdgeInsets.fromLTRB(40, 70, 40, 20),
      decoration: BoxDecoration(color: Theme.of(context).colorScheme.onSecondary, 
        shape: BoxShape.rectangle,
        borderRadius: BorderRadius.all(Radius.circular(20))),
      child: Text("No tag detected, please put a Mizip tag on the reader",
        style: TextStyle(fontSize: 16),)
    );
  }

}