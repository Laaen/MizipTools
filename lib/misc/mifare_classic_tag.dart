import 'dart:typed_data';

import 'package:flutter_nfc_kit/flutter_nfc_kit.dart';
import 'package:logging/logging.dart';
import 'package:miziptools/misc/mifare_keys.dart';
import 'package:synchronized/synchronized.dart';

class MifareClassicTag {
  
  String uid;
  /// Lock used to prevent concurrent access to the NFC reader
  Lock lock;

  MifareClassicTag({required this.uid, required this.lock});

  MifareKeys getKeys(){
    return (a: List.filled(5, "FFFFFFFFFFFF"), b:List.filled(5, "FFFFFFFFFFFF"));
  }

  Future<Uint8List> readBlock(int number, {int retries = 0, Duration delay = const Duration(milliseconds: 10)}) async{
    try{
      return await lock.synchronized(() async{
        await FlutterNfcKit.authenticateSector(number ~/ 4, keyA: getKeys().a[number ~/ 4]);
        return await FlutterNfcKit.readBlock(number);
      });
    } catch(error) {
      if(retries > 0){
        Logger.root.warning("Read failed, retrying");
        // Wait some time before retrying
        await Future.delayed(delay);
        return await readBlock(number, retries: retries - 1);
      } else {
        Logger.root.severe("Failed to read block $number");
        rethrow;
      }
    }
  }

    /// Reads a block and returns it, retries a certain amount of times
  Future<Uint8List> readSector(int number, {int retries = 0, Duration delay = const Duration(milliseconds: 10)}) async{
    try{
      return await lock.synchronized(() async{
        await FlutterNfcKit.authenticateSector(number, keyA: getKeys().a[number]);
        return await FlutterNfcKit.readSector(number);
      });
    } catch(error) {
      if(retries > 0){
        Logger.root.warning("Read failed, retrying");
        // Wait some time before retrying
        await Future.delayed(delay);
        return await readSector(number, retries: retries - 1);
      } else {
        Logger.root.severe("Failed to read sector $number");
        rethrow;
      }
    }
  }

  /// Writes the given block, retries a certain amount of times
  Future<void> writeBlock(int number, Uint8List data, {int retries = 0, Duration delay = const Duration(milliseconds: 10)}) async{
    try{
      // Auth with key A seemes to be not mandatory for writing
      //await FlutterNfcKit.authenticateSector(number ~/ 4, keyA: getKeys().a[number ~/ 4]);
      // Retry if auth not good
      if (await FlutterNfcKit.authenticateSector(number ~/ 4, keyB: getKeys().b[number ~/ 4]) != true){
        return await writeBlock(number, data, retries: retries - 1);
      } else {
        await FlutterNfcKit.writeBlock(number, data);
      }      
    } catch(error) {
      if(retries > 0){
        Logger.root.warning("Write failed, retrying");
        // Wait some time before retrying
        await Future.delayed(delay);
        await writeBlock(number, data, retries: retries - 1);
      } else {
        Logger.root.severe("Failed to write block $number");
        rethrow;
      }
    }
  }
}
