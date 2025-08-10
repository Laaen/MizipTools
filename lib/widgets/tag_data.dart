import 'package:flutter/material.dart';
import 'package:miziptools/main.dart';
import 'package:miziptools/misc/mifare_classic_tag.dart';
import 'package:miziptools/misc/mizip_tag.dart';
import 'package:miziptools/widgets/basic/containerWithBorder.dart';

class TagData extends StatelessWidget{

  const TagData({super.key});

  @override
  Widget build(BuildContext context) {
    
    // Order of evaluation is important as MizipTag inherits MifareClassicTag
    if (App.tag is MizipTag){
      return ContainerWithBorder(child: getTagDataDisplay(App.tag as MizipTag));
    }
    else if (App.tag is MifareClassicTag){
      return ContainerWithBorder(child: Text("Not a mizip tag (Mifare Classic Tag)"));
    } else {
      return ContainerWithBorder(child: Text("No tag detected", style: TextStyle(fontSize: 16)));
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
