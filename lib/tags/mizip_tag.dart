import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:collection/collection.dart';
import 'package:logging/logging.dart';
import 'package:miziptools/tags/balance.dart';
import 'package:miziptools/tags/mifare_classic_tag.dart';
import 'package:miziptools/tags/mifare_keys.dart';

/// Interface to the Mizip Tag
class MizipTag extends MifareClassicTag{

  MizipTag({required super.uid, required super.lock});

  @override
  MifareKeys getKeys(){
    const baseKeysA = ["6421E1E7E4D6", "C64672F5FF1C", "8F41FA6D413A", "5C490CED29A3"];
    const baseKeysB = ["4AEEE96063E3", "C825F4CD8983", "118F7E45ED6C", "0BD14A14963F"];
    const baseUID = "6D33BBC2";

    final transformedUID = _xor(super.uid, baseUID, 8);

    final intermediateKeyA = "$transformedUID${transformedUID.substring(0,4)}";
    final intermediateKeyB = "${transformedUID.substring(4,8)}$transformedUID";

    final keysA = ["a0a1a2a3a4a5"] + baseKeysA.map((key) => _xor(key, intermediateKeyA, 12)).toList(); 

    final keysB = ["b4c123439eef"] + baseKeysB.map((key) => _xor(key, intermediateKeyB, 12)).toList();

    return (a: keysA, b: keysB);
  }

  String _xor(String x, String y, int leftPad){
    return (int.parse(x, radix: 16) ^ int.parse(y, radix: 16)).toRadixString(16).padLeft(leftPad, '0');
  }

  @override
  Future<Balance> getBalance() async{
    await updateInnerBalance();
    return balance;
  }

  @override
  Future<void> updateInnerBalance() async {
    try{
      final data = await getRawBalanceData(); 
      balance = Balance(rawBalance: data.rawBalance, rawChecksum: data.rawChecksum, counterByte: data.counterByte);
      print("Counter byte : ");
      print(balance.counterByte);
      balance.setValid(true);
    } catch(error){
      Logger.root.warning("Error while getting balance : ${error.toString()}");
      balance = Balance.empty();
    }
  }

  Future<({Uint8List rawBalance, Uint8List rawChecksum, Uint8List counterByte})> getRawBalanceData() async{
    return await lock.synchronized(() async {
      final data = await readBlock(9, retries: 5);
      return (rawBalance: data.sublist(1, 3), rawChecksum: data.sublist(3, 4), counterByte: data.sublist(15, 16));
    });
  }

  Future<void> setBalance(String value) async{

    // Convert given value to a list of 2 hex + get the checksum
    final newValue = (double.parse(value) * 100).toInt().toRadixString(16).padLeft(4, '0').split("").slices(2).map((x) => x.join()).toList().reversed.map((x) => int.parse(x, radix: 16)).toList();
    final checksum = newValue.reduce((acc, curr) => acc ^ curr);
      
    var newBalance = Balance(rawBalance: Uint8List.fromList(newValue), rawChecksum: Uint8List.fromList([checksum]), counterByte: Uint8List.fromList(balance.counterByte));
    Logger.root.info("New balance : $newBalance");
    await writeBalance(newBalance);
    await updateInnerBalance();      
    Logger.root.info("Tag balance written succesfully");
}

  Future<void> writeBalance(Balance balance) async{
    await lock.synchronized(() async {
      await writeBlock(9, Uint8List.fromList(balance.getRawBlockValue()), retries: 5);
    });
  }

}