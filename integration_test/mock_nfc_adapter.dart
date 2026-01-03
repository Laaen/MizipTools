import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
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
    if (currentTag == null){
      throw NfcAdapterTagRemovedException("Tag was removed");
    } else if (failureMode){
      throw NfcAdapterCommunicationException("Communication error");
    } else {
      return Uint8List(0);
    }
  }

  @override
  Future<NfcTag> pollTag({Duration timeout = const Duration(milliseconds: 200)}) async{
    await Future.delayed(Duration(milliseconds: 500));
    if (failureMode){
      throw NfcAdapterCommunicationException("Communication error");
    } else if (currentTag != null) {
      return NfcTag(type: currentTag!.type, id: currentTag!.getUid());
    } else{
      throw NfcAdapterTagRemovedException("Tag was removed");
    }
  }

  @override
  Future<void> releaseTag() async {
    final cTag = currentTag;
    removeTag();
    await Future.delayed(Duration(milliseconds: 700));
    setTag(cTag!);
  }

  @override
  Future<bool> authenticateSector(int sectorNb, {Uint8List? keyA, Uint8List? keyB}) async{
    return currentTag!.authenticateSector(sectorNb, keyA, keyB);
  }

  @override
  Future<bool> writeBlock(int blockNb, Uint8List data) async{
    if (failureMode){
      throw NfcAdapterCommunicationException("Communication error");
    }
    return currentTag!.writeBlock(blockNb, data);
  }

  @override
  Future<Uint8List> readBlock(int blockNb) async{
    if (failureMode){
      throw NfcAdapterCommunicationException("Communication error");
    }
    return currentTag!.readBlock(blockNb);
  }

  @override
  Future<Uint8List> readSector(int sectorNb) async{
    if (failureMode){
      throw NfcAdapterCommunicationException("Communication error");
    }
    return currentTag!.readSector(sectorNb);
  }

  void setFailureMode(bool value){
    failureMode = value;
  }

}