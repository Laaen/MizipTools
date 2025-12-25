import 'package:flutter/material.dart';
import 'package:miziptools/extensions/uint8list_extensions.dart';
import 'package:miziptools/nfc/currentnfctag.dart';
import 'package:miziptools/widgets/basic/container_with_border.dart';
import 'package:provider/provider.dart';

class TagData extends StatelessWidget{

  const TagData({super.key});

  @override
  Widget build(BuildContext context) {

    final tag = Provider.of<CurrentNFCTag>(context);
    // Order of evaluation is important as MizipTag inherits MifareClassicTag
    if (tag.isMizipTag()){
      return ContainerWithBorder(child: getTagDataDisplay(tag));
    } else if (tag.isMifareClassic()){
      return ContainerWithBorder(child: Text("Not a MiZip tag (Mifare Classic Tag)"));
    } else {
      return ContainerWithBorder(child: Text("No tag detected", style: TextStyle(fontSize: 16)));
    }
  }

  Widget getTagDataDisplay(CurrentNFCTag tag){
    return Column(
      children : [
        Text("Tag data", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),),
        Container(height: 10,),
        Row(children: [Text("UID: ${tag.getUid().toHexString().toUpperCase()}", style: TextStyle(fontSize: 16))]),
        Row(children: [Text("Balance: ${tag.getBalance().getStringBalance()}\$", style: TextStyle(fontSize: 16))])
      ]
    );
  }

}