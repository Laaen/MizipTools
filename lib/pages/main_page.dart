import 'package:flutter/material.dart';
import 'package:flutter_nfc_kit/flutter_nfc_kit.dart';
import "package:logging/logging.dart";
import "package:miziptools/main.dart";
import "package:miziptools/misc/mifare_classic_tag.dart";
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

  /// Tries to send a message to the tag to check if it is still present
  Future<bool> checkTagPresent({int retries = 2, Duration delay = const Duration(milliseconds: 50)}) async{
    try{
      await globalLock.synchronized(()async {
        Logger.root.info("Tag Ping");
        await FlutterNfcKit.transceive("FFCA000000", timeout: Duration(milliseconds: 200));
      });
      return true;
    } catch(error){
      if(retries > 0){
        Logger.root.warning("Ping failed, retrying");
        await Future.delayed(delay);
        return await checkTagPresent(retries: retries - 1);
      }
      else{
        Logger.root.warning("Tag Lost");
        return false;
      }
    }
  }

  /// Background loop to detect when a tag is put on the phone
  Future<void> watchForTag(Function(NFCTag) callback) async{
    while (true){
      // Check if the tag is still here, go outside the loop when absent
      while (App.tag != null && await checkTagPresent()){    
        await Future.delayed(const Duration(milliseconds: 500));    
      }
      // Update layout
      setState(() {
        App.tag = null;
      });
      // Poll a new tag
      try{
        final tag = await FlutterNfcKit.poll(timeout: const Duration(milliseconds: 100),androidCheckNDEF: false);
        await callback(tag);
      } catch(error) {
        Logger.root.fine("No tag found");
      }
      await Future.delayed(const Duration(milliseconds: 10));
    }
  }

  /// Callback executed when a new tag is detected, gets the tag's handle + its keys
  Future<void> handleTag(NFCTag tag) async{
    Logger.root.info("Tag detected");
    if(tag.type != NFCTagType.mifare_classic){
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Not a Mifare Classic Tag"), duration: Duration(seconds: 2),));
      Logger.root.warning("Not a Mifare classic tag");
      return;
    }
    // TODO : Check if tag is a Mizip one, if not, we abort
    // Try to use the tag as a Mizip one
    final cTag = MizipTag(uid: tag.id, lock: globalLock);
    String? balance = await cTag.getBalance();
    // If we can't read balance, it's a MifareClassic but not Mizip
    if (balance == null) {
      setState(() {
        tagBalance = "Not a Mizip tag";
        App.tag = MifareClassicTag(uid: tag.id, lock: globalLock);
      });
    } else {
      setState(() {
        cTag.balance = balance;
        App.tag = cTag;
      });
    }
    if (mounted){
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
    }
    Logger.root.info("Tag OK, balance: ${tagBalance}");
  }

  @override
  void initState(){
    super.initState();
    watchForTag(handleTag).then((val){});
  }

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
}