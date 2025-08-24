import 'package:flutter/material.dart';
import 'package:flutter_nfc_kit/flutter_nfc_kit.dart';
import "package:logging/logging.dart";
import "package:miziptools/main.dart";
import "package:miziptools/misc/mifare_classic_tag.dart";
import "package:miziptools/misc/nfc.dart";
import "package:miziptools/misc/snackbar.dart";
import "package:miziptools/widgets/dump_tag.dart";
import 'package:synchronized/synchronized.dart';

import "../misc/mizip_tag.dart";

import "../widgets/appbar.dart";
import "../widgets/tag_data.dart";
import "../widgets/change_tag_balance.dart";
import "../widgets/tag_add_10.dart";

class MainPage extends StatefulWidget{

@override
  State<StatefulWidget> createState() {
    return MainPage_State();
  }
}

class MainPage_State extends State<MainPage>{

  String tagBalance = "";
  Lock globalLock = Lock(reentrant: true);

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: MizipToolsAppBar(),
      body: Container(
        padding: EdgeInsets.fromLTRB(40, 30, 40, 30),
        child: Column(
          spacing: 20,
          children: [
            TagData(),
            // Some buttons don't appear if not a mizip tag
            if (App.tag != null && App.tag is MizipTag) TagBalance(),
            if (App.tag != null && App.tag is MizipTag) TagAdd10(),
            if (App.tag != null) DumpTag(),
          ],
        ),
      ),
    );
  }

  @override
  void initState(){
    super.initState();
    watchForTag(globalLock, context, onTagLost, onTagDetected).then((val){});
  }

  void onTagLost() async {
    setState(() {
      App.tag = null;
    });
  }

  /// Callback executed when a new tag is detected, gets the tag's handle + its keys
  Future<void> onTagDetected (Lock globalLock, NFCTag tag) async{

    if(tag.type != NFCTagType.mifare_classic){
      await handleNotMifareClassicTag();
      return;
    }

    MifareClassicTag currentTag;
    if (await isMizipTag(tag)){
      currentTag = MizipTag(uid: tag.id, lock: globalLock);
    } else {
      currentTag = MifareClassicTag(uid: tag.id, lock: globalLock);
    }

    await currentTag.updateInnerBalance();

    setState(() {
      App.tag = currentTag;
    });
  }

  Future<void> handleNotMifareClassicTag() async {
    showSnackBar(context, "Not a Mifare Classic tag");
    Logger.root.warning("Not a Mifare classic tag");
    await Future.delayed(Duration(seconds: 2));
  }

  Future<bool> isMizipTag(NFCTag tag) async{
    final cTag = MizipTag(uid: tag.id, lock: globalLock);
    String? balance = await cTag.getBalance();
    return balance != "N/A";
  }
}