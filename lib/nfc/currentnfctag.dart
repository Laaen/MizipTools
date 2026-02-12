import 'dart:io';

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';
import 'package:miziptools/extensions/uint8list_extensions.dart';
import 'package:miziptools/misc/generate_keys.dart';
import 'package:miziptools/tags/balance.dart';
import 'package:miziptools/tags/mifare_classic_tag.dart';
import 'package:miziptools/tags/mizip_tag.dart';
import 'package:path_provider/path_provider.dart';

class CurrentNFCTag with ChangeNotifier {
  
  MifareClassicTag? innerTag;

  CurrentNFCTag.init();

  Future<void> updateInnerTag(MifareClassicTag? newTag) async{
    innerTag = newTag;
    await innerTag?.updateInnerBalance();
    notifyListeners();
  }

  void setTagAbsent(){
    innerTag = null;
    notifyListeners();
  }

  bool isPresent(){
    return innerTag != null;
  }

  MifareKeys getKeys(){
    return innerTag!.getKeys();
  }

  Uint8List getUid(){
    return innerTag!.uid;
  }
  
  Balance getBalance(){
    return innerTag!.getBalance();
  }

  Future<void> updateInnerBalance() async{
    await innerTag!.updateInnerBalance();
  } 

  Future<Uint8List> readSector(int number, {int retries = 0, Duration delay = const Duration(milliseconds: 10)}) async{
    return await innerTag!.readSector(number);
  }

  Future<List<Uint8List>> dumpTagData() async{
    return await innerTag!.dumpTagData();
  }

  Future<void> writeDumpToTag(List<Uint8List> data) async{
    await saveUID(data[0].sublist(0, 4).toHexString().toUpperCase());
    await innerTag?.writeDumpToTag(data);
  }

  Future<void> setBalance(String value) async{
    final tag = innerTag! as MizipTag;
    await tag.setBalance(value);
    notifyListeners();
  }

  Future<void> setUid(Uint8List newUid) async{
    await saveUID(newUid.toHexString().toUpperCase());
    await innerTag!.setUid(newUid);
  }

  Future<bool> authenticateSector(int sectorNb, Uint8List? keyA, keyB) async{
    return await innerTag!.authenticateSector(sectorNb, keyA: keyA, keyB: keyB);
  }

  Future<void> releaseTag() async{
    await innerTag!.releaseTag();
    setTagAbsent();
  }

  Future<void> autoRepair(Uint8List oldUid) async{
    MifareKeys validKeys = (a: [], b: []);

    MifareKeys candidateCurrentUid = generateKeys(innerTag!.uid);
    MifareKeys candidateOldUid = generateKeys(oldUid);
    MifareKeys candidateMifareClassic = (a: List.filled(5, Uint8List.fromList([0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF])), b:List.filled(5, Uint8List.fromList([0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF])));

    // Test keys A
    for(final (index, keys) in IterableZip([candidateMifareClassic.a, candidateCurrentUid.a, candidateOldUid.a]).indexed){
      for(final key in keys){
        if(await tryAuthenticate(index, keyA: key)){
          validKeys.a.add(key);
          break;
        }
      }
    }

    // Test keys B
    for(final (index, keys) in IterableZip([candidateMifareClassic.b, candidateCurrentUid.b, candidateOldUid.b]).indexed){
      for(final key in keys){
        if(await tryAuthenticate(index, keyB: key)){
          validKeys.b.add(key);
          break;
        }
      }
    }
    await innerTag!.rewriteKeys(validKeys, candidateCurrentUid);
  }

  Future<bool> tryAuthenticate(int sectorNb, {Uint8List? keyA, Uint8List? keyB, int nbRetries = 2}) async{
    if (! await innerTag!.authenticateSector(sectorNb, keyA: keyA, keyB: keyB)){
      if (nbRetries > 0){
        return tryAuthenticate(sectorNb, keyA: keyA, keyB: keyB, nbRetries: nbRetries - 1);
      } else {
        return false;
      }
    } else{
      return true;
    }
  }

  bool isMizipTag(){
    return isPresent() && innerTag! is MizipTag;
  }

  bool isMifareClassic(){
    return isPresent();
  }

  Future<bool> saveUID(String uid) async {
    final dataDir = await getExternalStorageDirectory();
    if (dataDir == null){
      return false;
    }

    try{
      File("${dataDir.path}/uid_save").writeAsStringSync(uid);
    } on FileSystemException catch (e){
      Logger.root.severe("Error while saving UID : $e");
      return false;
    }

    return true;
  }

}
