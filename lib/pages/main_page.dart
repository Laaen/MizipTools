import 'package:flutter/material.dart';

import "../misc/mizip_tag.dart";

import "../widgets/appbar.dart";
import "../widgets/tag_data.dart";


class MainPage extends StatefulWidget{

@override
  State<StatefulWidget> createState() {
    return MainPage_State();
  }
}

class MainPage_State extends State<MainPage>{

  MizipTag? tag;

@override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MizipToolsAppBar(),
      body: Container(
        child: Column(
          children: [
            TagData(uid: tag?.uid, balance: tag?.balance,)
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(onPressed: (){ setState(() {
        if (tag == null){
          tag = MizipTag(balance: "26.92", uid: "LAEN");
        } else {
          tag = null;
        }
      });}),
    );
  }

}