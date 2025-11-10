import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:miziptools/nfc/currentnfctag.dart';
import 'package:miziptools/nfc/nfc_adapter.dart';
import 'package:miziptools/nfc/nfc_tag.dart';

import 'mock_nfc_tag.dart';

class MockNfcAdapter extends NfcAdapter{
  
  /// Makes the methods fail (either exception throw of false return)
  bool failureMode = false;

  /// The NFC tag to simulate
  MockNfcTag? currentTag;
  
  MockNfcAdapter();

  void setTag(MockNfcTag? tag){
    currentTag = tag;
  }

  void removeTag(){
    currentTag = null;
  }

  @override
  Future<Uint8List> pingTag({Duration timeout = const Duration(milliseconds: 200)}) async{
    Future.delayed(Duration(milliseconds: 500));
    if (failureMode || currentTag == null){
      throw PlatformException(code: "503");
    } else {
      return Uint8List(0);
    }
  }

  @override
  Future<NfcTag> pollTag({Duration timeout = const Duration(milliseconds: 200)}) async{
    await Future.delayed(Duration(milliseconds: 500));
    if (failureMode){
      throw PlatformException(code: "503");
    } else if (currentTag != null) {
      return NfcTag(type: currentTag!.type, id: currentTag!.getUid());
    } else{
      throw PlatformException(code: "503");
    }
  }

  @override
  Future<void> releaseTag() async {
    final cTag = currentTag;
    removeTag();
    await Future.delayed(Duration(milliseconds: 500));
    setTag(cTag!);
  }

  @override
  Future<bool> authenticateSector(int sectorNb, {Uint8List? keyA, Uint8List? keyB}) async{
    return currentTag!.authenticateSector(sectorNb, keyA, keyB);
  }

  @override
  Future<void> writeBlock(int blockNb, Uint8List data) async{
    return currentTag!.writeBlock(blockNb, data);
  }

  @override
  Future<Uint8List> readBlock(int blockNb) async{
    return currentTag!.readBlock(blockNb);
  }

  @override
  Future<Uint8List> readSector(int sectorNb) async{
    return currentTag!.readSector(sectorNb);
  }
}