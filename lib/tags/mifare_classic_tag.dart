import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_nfc_kit/flutter_nfc_kit.dart';
import 'package:logging/logging.dart';
import 'package:miziptools/tags/balance.dart';
import 'package:miziptools/tags/mifare_keys.dart';
import 'package:synchronized/synchronized.dart';

class MifareClassicTag with ChangeNotifier {
  
  /// Lock used to prevent concurrent access to the NFC reader
  Lock lock;

  String uid;
  Balance balance = Balance.empty();

  MifareClassicTag({required this.uid, required this.lock});
  MifareClassicTag.empty() : uid = "INVALID_UID", lock = Lock();

  MifareKeys getKeys(){
    return (a: List.filled(5, "FFFFFFFFFFFF"), b:List.filled(5, "FFFFFFFFFFFF"));
  }

  Future<Balance> getBalance() async{
    return balance;
  }

  Future<void> updateInnerBalance() async {
    return;
  }

  Future<List<Uint8List>> dumpTagData() async{
    List<Uint8List> dump = [];
    await lock.synchronized(() async{
      for (int sectorNb = 0 ; sectorNb < 5; sectorNb++){
        final sectorData = await readSector(sectorNb, retries: 5);
        for (final line in sectorData.slices(16)){
          dump.add(Uint8List.fromList(line));
        }
      }
    });
    return dump;
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
      if (await FlutterNfcKit.authenticateSector(number ~/ 4, keyB: getKeys().b[number ~/ 4]) != true){
        return await writeBlock(number, data, retries: retries - 1);
      } else {
        await FlutterNfcKit.writeBlock(number, data);
      }      
    } catch(error) {
      if(retries > 0){
        Logger.root.warning("Write failed, retrying");
        await Future.delayed(delay);
        await writeBlock(number, data, retries: retries - 1);
      } else {
        Logger.root.severe("Failed to write block $number");
        rethrow;
      }
    }
  }
}
