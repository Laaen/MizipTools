import 'dart:typed_data';

import 'package:flutter_nfc_kit/flutter_nfc_kit.dart';
import 'package:miziptools/extensions/string_extensions.dart';
import 'package:miziptools/nfc/nfc_tag.dart';

class NfcAdapter {

  NfcAdapter();

  Future<Uint8List> pingTag({Duration timeout = const Duration(milliseconds: 200)}) async{
    return await FlutterNfcKit.transceive("FFCA000000".toUint8List(), timeout: timeout);
  }

  Future<NfcTag> pollTag({Duration timeout = const Duration(milliseconds: 200)}) async{
    final tag = await FlutterNfcKit.poll(timeout: timeout, androidCheckNDEF: false);
    final type = tag.type == NFCTagType.mifare_classic ? NfcTagType.mifareClassic : NfcTagType.other;
    return NfcTag(type: type, id: tag.id);
  }

  Future<void> releaseTag() async {
    return await FlutterNfcKit.finish();
  }

  Future<bool> authenticateSector(int sectorNb, {Uint8List? keyA, Uint8List? keyB}) async{
    return await FlutterNfcKit.authenticateSector(sectorNb, keyA: keyA, keyB: keyB);
  }

  Future<void> writeBlock(int blockNb, Uint8List data) async{
    return await FlutterNfcKit.writeBlock(blockNb, data);
  }

  Future<Uint8List> readBlock(int blockNb) async{
    return await FlutterNfcKit.readBlock(blockNb);
  }

  Future<Uint8List> readSector(int sectorNb) async{
    return await FlutterNfcKit.readSector(sectorNb);
  }

}