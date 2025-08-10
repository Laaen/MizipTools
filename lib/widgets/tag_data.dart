import 'package:flutter/material.dart';
import 'package:miziptools/main.dart';
import 'package:miziptools/misc/mizip_tag.dart';
import 'package:miziptools/widgets/basic/containerWithBorder.dart';

class TagData extends StatelessWidget{

  const TagData({super.key});

  @override
  Widget build(BuildContext context) {
    if (App.tag is! MizipTag){
      return ContainerWithBorder(child: Text("No tag detected", style: TextStyle(fontSize: 16)));
    } else {
      return ContainerWithBorder(child: getTagDataDisplay(App.tag as MizipTag));
    }
  }

  Widget getTagDataDisplay(MizipTag tag){
    return Column(
      children : [
        Text("Tag data", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),),
        Container(height: 10,),
        Row(children: [Text("UID: ${tag.uid}", style: TextStyle(fontSize: 16))]),
        Row(children: [Text("Balance: ${tag.balance}\$", style: TextStyle(fontSize: 16))])
      ]
    );
  }
}
