import "dart:io";

import 'package:flutter/material.dart';
import 'package:flutter_nfc_kit/flutter_nfc_kit.dart';
import 'package:synchronized/synchronized.dart';

import "../misc/mizip_tag.dart";

import "../widgets/appbar.dart";
import "../widgets/tag_data.dart";
import "../widgets/tag_balance.dart";
import "../widgets/tag_add_x.dart";

class MainPage extends StatefulWidget{

@override
  State<StatefulWidget> createState() {
    return MainPage_State();
  }
}

class MainPage_State extends State<MainPage>{

  /// The tag's handle, MUST be set to null in case of error / disconnection to initiate a new poll 
  MizipTag? currentTag;
  /// The balance, we need to put it here because async/await
  String tagBalance = "";
  /// GLobal lock, to prevent concurrent transmissions
  Lock globalLock = Lock(reentrant: true);

  /// Tries to send a message to the tag to check if it is still present
  Future<bool> checkTagPresent() async{
    try{
      await globalLock.synchronized(()async {
        await FlutterNfcKit.transceive("FFCA000000");
      });
      return true;
    } catch(error){
      return false;
    }
  }

  /// Background loop to detect when a tag is put on the phone
  Future<void> watchForTag(Function(NFCTag) callback) async{
    while (true){
      // Check if the tag is still here, if the handle is null, then no, and we set currentTag to null
      if (currentTag != null){
        var present = await checkTagPresent();
        if (!present) {
          setState(() {
            currentTag = null;
          });
        }
      }

      if (currentTag == null){
        try{
          final tag = await FlutterNfcKit.poll(timeout: const Duration(seconds: 2),androidCheckNDEF: false);
          await callback(tag);
        } catch(error) {
          //print(error);
        }
      }
      await Future.delayed(const Duration(seconds: 1));
    }
  }

  /// Callback executed when a new tag is detected, gets the tag's handle + its keys
  Future<void> handleTag(NFCTag tag) async{
    if(tag.type != NFCTagType.mifare_classic){
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Not a Mifare Classic Tag"), duration: Duration(seconds: 2),));
      return;
    }
    // Extract data we want to display
    final cTag = MizipTag(uid: tag.id, lock: globalLock);
    String? balance = await cTag.getBalance();
    balance ??= "N/A";
    setState(() {
      this.tagBalance = balance!;
      this.currentTag = cTag;
    });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("New tag detected : ${tag.id}"), duration: Duration(seconds: 2),));
  }

  @override
  void initState(){
    super.initState();
    // Launch background loop
    watchForTag(handleTag).then((val){});
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: MizipToolsAppBar(),
      body: Container(
        child: Column(
          children: [
            TagData(uid: currentTag?.uid, balance: tagBalance,),
            if (currentTag != null) TagBalance(currentTag: currentTag!,),
            if (currentTag != null) TagAdd10(currentTag: currentTag!,),
          ],
        ),
      ),
    );
  }

}