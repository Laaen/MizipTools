import 'package:flutter/foundation.dart';
import 'package:flutter_nfc_kit/flutter_nfc_kit.dart';
import 'package:logging/logging.dart';
import 'package:miziptools/misc/mifare_classic_tag.dart';
import 'package:miziptools/misc/mifare_keys.dart';
import 'package:miziptools/misc/mizip_tag.dart';
import 'package:synchronized/synchronized.dart';

class CurrentNFCTag with ChangeNotifier {
  
  MifareClassicTag? innerTag;

  CurrentNFCTag.init();

  void updateInnerTag(MifareClassicTag? newTag){
    innerTag = newTag;
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

  String getUid(){
    return innerTag!.uid;
  }
  
  Future<String> getBalance() async{
    return await innerTag!.getBalance();
  }

  Future<Uint8List> readSector(int number, {int retries = 0, Duration delay = const Duration(milliseconds: 10)}) async{
    return await innerTag!.readSector(number);
  }

  Future<void> setBalance(String value) async{
    final tag = innerTag! as MizipTag;
    await tag.setBalance(value);
    notifyListeners();
  }

  bool isMizipTag(){
    return isPresent() && innerTag! is MizipTag;
  }

  bool isMifareClassic(){
    return isPresent();
  }

}
