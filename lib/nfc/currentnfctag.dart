import 'package:flutter/foundation.dart';
import 'package:miziptools/tags/balance.dart';
import 'package:miziptools/tags/mifare_classic_tag.dart';
import 'package:miziptools/tags/mifare_keys.dart';
import 'package:miziptools/tags/mizip_tag.dart';

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
  
  Future<Balance> getBalance() async{
    return await innerTag!.getBalance();
  }

  Future<Uint8List> readSector(int number, {int retries = 0, Duration delay = const Duration(milliseconds: 10)}) async{
    return await innerTag!.readSector(number);
  }

  Future<List<Uint8List>> dumpTagData() async{
    return await innerTag!.dumpTagData();
  }

  Future<void> writeDumpToTag(List<Uint8List> data) async{
    await innerTag?.writeDumpToTag(data);
  }

  Future<void> setBalance(String value) async{
    final tag = innerTag! as MizipTag;
    await tag.setBalance(value);
    notifyListeners();
  }

  Future<void> setUid(Uint8List newUid) async{
    await innerTag!.setUid(newUid);
  }

  bool isMizipTag(){
    return isPresent() && innerTag! is MizipTag;
  }

  bool isMifareClassic(){
    return isPresent();
  }

}
