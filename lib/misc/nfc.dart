import 'package:flutter/material.dart';
import 'package:synchronized/synchronized.dart';
import 'package:logging/logging.dart';
import 'package:flutter_nfc_kit/flutter_nfc_kit.dart';
import "package:miziptools/main.dart";
import "../misc/mizip_tag.dart";

Future<void> watchForTag(Lock globalLock, BuildContext context, Function() onTagLost, Function(Lock, NFCTag) onTagDetected) async{

  while (true){
    await waitForTagLost(globalLock);
    await onTagLost();
    final tag = await waitForNewTag();
    await onTagDetected(globalLock, tag);
    await Future.delayed(const Duration(milliseconds: 10)); // TODO : Vérifier si utile ou non
  }
}

Future<void> waitForTagLost(Lock globalLock) async {
  while (App.tag != null && await checkTagPresent(globalLock)){
    await Future.delayed(const Duration(milliseconds: 500));
  }
}

Future<bool> checkTagPresent(Lock globalLock, {int retries = 2, Duration delay = const Duration(milliseconds: 50)}) async{
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
      return await checkTagPresent(globalLock, retries: retries - 1);
    }
    else{
      Logger.root.warning("Tag Lost");
      return false;
    }
  }
}

Future<NFCTag> waitForNewTag() async{
  NFCTag? tag;
  do{
    tag = await getNewTag();
  } while (tag == null);
  return tag;
}

Future<NFCTag?> getNewTag() async {
  try {
    final tag = await FlutterNfcKit.poll(timeout: const Duration(milliseconds: 200), androidCheckNDEF: false);
    return tag;
  } catch (error) {
    Logger.root.fine("No tag found");
    return Future.value(null);
  }
}