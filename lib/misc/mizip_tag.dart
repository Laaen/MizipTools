
import 'dart:typed_data';

import 'package:flutter_nfc_kit/flutter_nfc_kit.dart';
import 'package:collection/collection.dart';
import 'package:synchronized/synchronized.dart';

/// Interface to the Mizip Tag
class MizipTag {

  MizipTag({required this.uid, required this.lock});

  String uid;
  Lock lock;

  /// Returns keys A and B for the given uid
  ({List<String> a,List<String> b}) getKeys(){
    const baseKeysA = ["6421E1E7E4D6", "C64672F5FF1C", "8F41FA6D413A", "5C490CED29A3"];
    const baseKeysB = ["4AEEE96063E3", "C825F4CD8983", "118F7E45ED6C", "0BD14A14963F"];
    const baseUID = "6D33BBC2";

    final transformedUID = (int.parse(uid, radix: 16) ^ int.parse(baseUID, radix: 16)).toRadixString(16).padLeft(8, '0');

    final intermediateKeyA = "$transformedUID${transformedUID.substring(0,4)}";
    final intermediateKeyB = "${transformedUID.substring(4,8)}$transformedUID";

    final keysA = ["a0a1a2a3a4a5"] + baseKeysA.map((x){
      return (int.parse(x, radix: 16) ^ int.parse(intermediateKeyA, radix: 16)).toRadixString(16).padLeft(12, '0');
    }).toList();

    final keysB = ["b4c123439eef"] + baseKeysB.map((x){
      return (int.parse(x, radix: 16) ^ int.parse(intermediateKeyB, radix: 16)).toRadixString(16).padLeft(12, '0');
    }).toList();

    return (a: keysA, b: keysB);
  }

  /// Reads a block and returns it, retries a certain amount of times
  Future<Uint8List> readBlock(int number, {int retries = 0}) async{
    try{
      return await lock.synchronized(() async{
        await FlutterNfcKit.authenticateSector(number ~/ 4, keyA: getKeys().a[number ~/ 4]);
        return await FlutterNfcKit.readBlock(number);
      });
    } catch(error) {
      if(retries > 0){
        return await readBlock(number, retries: retries - 1);
      } else {
        rethrow;
      }
    }
  }

  /// Writes the given block, retries a certain amount of times
  Future<void> writeBlock(int number, Uint8List data, {int retries = 0}) async{
    try{
      await lock.synchronized(() async{
        await FlutterNfcKit.authenticateSector(number ~/ 4, keyA: getKeys().a[number ~/ 4]);
        await FlutterNfcKit.authenticateSector(number ~/ 4, keyB: getKeys().b[number ~/ 4]);
        await FlutterNfcKit.writeBlock(number, data);
      });
    } catch(error) {
      if(retries > 0){
        await writeBlock(number, data, retries: retries - 1);
      } else {
        rethrow;
      }
    }
  }

  /// Returns the balance of the tag, returns null in case of error
  Future<String?> getBalance() async{
    // Sector 2 block 9
    try{
      final data = await readBlock(9, retries: 5);
      final balance = data.sublist(1, 3).map((x) {return x.toRadixString(16);}).toList().reversed;
      return (int.parse(balance.join(""), radix: 16) / 100.0).toString();
    } catch(error){
      return null;
    }
  }

  /// Writes the new balance to the tag
  Future<void> setBalance(String value) async{
    // Get the current block's value
    Uint8List current_balance_block;
    current_balance_block = await readBlock(9, retries: 5);
    // Convert given value to a list of 2 hex + get the checksum
    final new_value = (double.parse(value) * 100).toInt().toRadixString(16).split("").slices(2).map((x) => x.join()).toList().reversed.map((x) => int.parse(x, radix: 16)).toList();
    final checksum = new_value.reduce((acc, curr) => acc ^ curr);
    
    // update the block with the new values
    var newBalanceBlock = current_balance_block.toList();
    newBalanceBlock.replaceRange(1, 4, [new_value[0], new_value[1], checksum]);
    await writeBlock(9, Uint8List.fromList(newBalanceBlock), retries: 5);

    // Close the session to trigger a new discovery => new balance
    await FlutterNfcKit.finish();

  }
}