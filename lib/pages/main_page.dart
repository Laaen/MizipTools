import 'package:flutter/material.dart';
import 'package:flutter_nfc_kit/flutter_nfc_kit.dart';

import "../misc/mizip_tag.dart";

import "../widgets/appbar.dart";
import "../widgets/tag_data.dart";
import "../widgets/tag_balance.dart";


class MainPage extends StatefulWidget{

@override
  State<StatefulWidget> createState() {
    return MainPage_State();
  }
}

class MainPage_State extends State<MainPage>{

  /// The tag's handle, MUST be set to null in case of error to initiate a new poll 
  MizipTag? _tag;

  /// Tries to send a message to the tag to check if it is still present
  Future<bool> checkTagPresent() async{
    try{
      await FlutterNfcKit.transceive("FFCA000000");
      return true;
    } catch(error){
      return false;
    }
  }

  /// Background loop to detect when a tag is put on the phone
  Future<void> watchForTag(Function(NFCTag) callback) async{
    while (true){
      // Check if the tag is still here, if the handle is null, then no, and we set _tag to null
      if (_tag != null){
        var present = await checkTagPresent();
        if (!present) {
          setState(() {
            _tag = null;
          });
        }
      }

      if (_tag == null){
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
    setState(() {
      // Extract data we want to display
      _tag = MizipTag(balance: "20.92", uid: tag.id);
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MizipToolsAppBar(),
      body: Container(
        child: Column(
          children: [
            TagData(uid: _tag?.uid, balance: _tag?.balance,),
            if (_tag != null) TagBalance()
          ],
        ),
      ),
    );
  }

}