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

  Future<void> writeDumpToTag(List<Uint8List> data) async{
    await lock.synchronized(() async{
      try{
        // Write the data in every sector except sector 0 (issues, if UID changes, breaks everything, we have to do it at the end)
        var currentBlockNb = 4;
        for (var (idx, line) in data.skip(4).indexed){
          await writeBlock(currentBlockNb + idx, line, retries: 5);
        }
        await writeSectorZero(data.take(4).toList());
      }catch (error){
        Logger.root.warning("Error while dump writing : $error");
        return;
      }
    });
  }

  // Special case block 0 must be written last (tag disconnection on UID rewrite)
  Future<void> writeSectorZero(List<Uint8List> data) async{
    // Blocks 1, 2 and sector trailer
    await writeBlock(1, data[1], retries: 5);
    await writeBlock(2, data[2], retries: 5);
    await writeBlock(3, data[3], retries: 5);

    // Block 0, we need to use the new B key of the sector
    final newKey = data[3].sublist(10, 16);
    await writeBlockZero(data[0], newKey, retries: 5);
  }

  Future<void> writeBlockZero(Uint8List data, Uint8List key, {int retries = 0, Duration delay = const Duration(milliseconds: 10)}) async{
    try{
      if (await FlutterNfcKit.authenticateSector(0, keyB: key) != true){
        return await writeBlockZero(data, key, retries: retries - 1);
      } else {
        await FlutterNfcKit.writeBlock(0, data);
      }      
    } catch(error) {
      if(retries > 0){
        Logger.root.warning("Write failed, retrying");
        await Future.delayed(delay);
        await writeBlockZero(data, key, retries: retries - 1);
      } else {
        Logger.root.severe("Failed to write block 0");
        rethrow;
      }
    }
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
      await FlutterNfcKit.authenticateSector(number ~/ 4, keyB: getKeys().b[number ~/ 4]);
      await FlutterNfcKit.writeBlock(number, data);  
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
