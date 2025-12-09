import 'package:flutter/services.dart';
import 'package:flutter_nfc_kit/flutter_nfc_kit.dart';
import 'package:miziptools/extensions/string_extensions.dart';
import 'package:miziptools/nfc/nfc_tag.dart';

class NfcAdapterException implements Exception{
  String cause;
  NfcAdapterException(this.cause);
}

class NfcAdapterCommunicationException extends NfcAdapterException{
  NfcAdapterCommunicationException(super.cause);
}

class NfcAdapterTagRemovedException extends NfcAdapterException{
  NfcAdapterTagRemovedException(super.cause);
}

class NfcAdapter {

  NfcAdapter();

  Future<Uint8List> pingTag({Duration timeout = const Duration(milliseconds: 200)}) async{
    try{
      return await FlutterNfcKit.transceive("FFCA000000".toUint8List(), timeout: timeout);
    } on Exception catch (e){
      handleException(e);
    }
    return Uint8List(0);
  }

  Future<NfcTag> pollTag({Duration timeout = const Duration(milliseconds: 200)}) async{
    try{
      final tag = await FlutterNfcKit.poll(timeout: timeout, androidCheckNDEF: false);
      final type = tag.type == NFCTagType.mifare_classic ? NfcTagType.mifareClassic : NfcTagType.other;
      return NfcTag(type: type, id: tag.id);
    } on Exception catch(e){
      handleException(e);
    }
    return NfcTag(type: NfcTagType.other, id: "FFFFFFFF");
  }

  Future<void> releaseTag() async {
    try{
      return await FlutterNfcKit.finish();
    } on Exception catch(e){
      handleException(e);
    }
  }

  Future<bool> authenticateSector(int sectorNb, {Uint8List? keyA, Uint8List? keyB}) async{
    try{
      return await FlutterNfcKit.authenticateSector(sectorNb, keyA: keyA, keyB: keyB);
    } on Exception catch(e){
      handleException(e);
    }
    return false;
  }

  Future<void> writeBlock(int blockNb, Uint8List data) async{
    try{
      return await FlutterNfcKit.writeBlock(blockNb, data);
    } on Exception catch(e){
      handleException(e);
    }
  }

  Future<Uint8List> readBlock(int blockNb) async{
    try{
      return await FlutterNfcKit.readBlock(blockNb);
    } on Exception catch(e){
      handleException(e);
    }
    return Uint8List(0);
  }

  Future<Uint8List> readSector(int sectorNb) async{
    try{
      return await FlutterNfcKit.readSector(sectorNb);
    } on Exception catch(e){
      handleException(e);
    }
    return Uint8List(0);
  }

  void handleException(Exception exception){
    if (exception is PlatformException){
      if(exception.code == "503"){
        throw NfcAdapterTagRemovedException("Tag was removed");
      } else{
        throw NfcAdapterCommunicationException("Communication exception occured");
      }
    } else {
      throw NfcAdapterException("Unknown exception occured : $exception");
    }
  }

}