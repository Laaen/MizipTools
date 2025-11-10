import 'package:flutter/material.dart';
import 'package:miziptools/nfc/currentnfctag.dart';
import 'package:miziptools/nfc/nfc_adapter.dart';
import 'package:miziptools/nfc/nfc_tag.dart';
import 'package:synchronized/synchronized.dart';
import 'package:logging/logging.dart';

Future<void> watchForTag(CurrentNFCTag currentTag, NfcAdapter nfcAdapter, Lock globalLock, BuildContext context, Function() onTagLost, Function(Lock, NfcTag, NfcAdapter) onTagDetected) async{

  while (true){
    await waitForTagLost(currentTag, nfcAdapter, globalLock);
    await onTagLost();
    final tag = await waitForNewTag(nfcAdapter);
    await onTagDetected(globalLock, tag, nfcAdapter);
    await Future.delayed(const Duration(milliseconds: 10));
  }
}

Future<void> waitForTagLost(CurrentNFCTag tag, NfcAdapter nfcAdapter, Lock globalLock) async {
  while (tag.isPresent() && await checkTagPresent(globalLock, nfcAdapter)){
    await Future.delayed(const Duration(milliseconds: 500));
  }
}

Future<bool> checkTagPresent(Lock globalLock, NfcAdapter nfcAdapter, {int retries = 2, Duration delay = const Duration(milliseconds: 50)}) async{
  try{
    await globalLock.synchronized(()async {
      Logger.root.info("Tag Ping");
      await nfcAdapter.pingTag();
    });
    return true;
  } catch(error){
    if(retries > 0){
      Logger.root.warning("Ping failed, retrying");
      await Future.delayed(delay);
      return await checkTagPresent(globalLock, nfcAdapter, retries: retries - 1);
    }
    else{
      Logger.root.warning("Tag Lost");
      return false;
    }
  }
}

Future<NfcTag> waitForNewTag(NfcAdapter nfcAdapter) async{
  NfcTag? tag;
  do{
    tag = await getNewTag(nfcAdapter);
  } while (tag == null);
  return tag;
}

Future<NfcTag?> getNewTag(NfcAdapter nfcAdapter) async {
  try {
    final tag = await nfcAdapter.pollTag();
    return tag;
  } catch (error) {
    Logger.root.fine("No tag found");
    return Future.value(null);
  }
}