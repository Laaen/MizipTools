import 'dart:typed_data';
import 'package:flutter_nfc_kit/flutter_nfc_kit.dart';
import 'package:collection/collection.dart';
import 'package:logging/logging.dart';
import 'package:miziptools/misc/mifare_classic_tag.dart';
import 'package:miziptools/misc/mifare_keys.dart';

/// Interface to the Mizip Tag
class MizipTag extends MifareClassicTag{

  MizipTag({required super.uid, required super.lock});

  @override
  MifareKeys getKeys(){
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

  Future<String> getBalance() async{
    await updateInnerBalance();
    return this.balance;
  }

  Future<void> updateInnerBalance() async {
    try{
      final data = await readBlock(9, retries: 5);
      final balance = data.sublist(1, 3).map((x) => x.toRadixString(16).padLeft(2, "0")).toList().reversed;
      this.balance = (int.parse(balance.join(""), radix: 16) / 100.0).toString();
    } catch(error){
      this.balance = "N/A";
    }
  }

  /// Writes the new balance to the tag
  Future<bool> setBalance(String value) async{

    await lock.synchronized(() async {
      // Get the current block's value
      Uint8List currentBalanceBlock;
      try{
        currentBalanceBlock = await readBlock(9, retries: 5);
      } catch(err){
        return false;
      }
      // Convert given value to a list of 2 hex + get the checksum
      final newValue = (double.parse(value) * 100).toInt().toRadixString(16).padLeft(4, '0').split("").slices(2).map((x) => x.join()).toList().reversed.map((x) => int.parse(x, radix: 16)).toList();
      final checksum = newValue.reduce((acc, curr) => acc ^ curr);
      
      // update the block with the new values
      var newBalanceBlock = currentBalanceBlock.toList();
      newBalanceBlock.replaceRange(1, 4, [newValue[0], newValue[1], checksum]);
      Logger.root.info("New block : $newBalanceBlock");
      await lock.synchronized(() async {
        await writeBlock(9, Uint8List.fromList(newBalanceBlock), retries: 5);
      });
      Logger.root.info("Tag balance written succesfully");
      
      // Close the session to trigger a new discovery => new balance
      // TODO: Retirer et juste update le balance
      await FlutterNfcKit.finish();
    });
    
    return true;
  }
}