import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:collection/collection.dart';
import 'package:logging/logging.dart';
import 'package:miziptools/misc/generate_keys.dart';
import 'package:miziptools/tags/balance.dart';
import 'package:miziptools/tags/mifare_classic_tag.dart';

/// Interface to the Mizip Tag
class MizipTag extends MifareClassicTag{

  MizipTag({required super.uid, required super.lock, required super.nfcAdapter});

  @override
  MifareKeys getKeys(){
    return generateKeys(uid);
  }

  @override
  Balance getBalance(){
    return balance;
  }

  @override
  Future<void> updateInnerBalance() async {
    final balanceBlockNb = await getCurrentBalanceBlockNumber();
    final data = await getRawBalanceData(balanceBlockNb); 
    balance = Balance(rawBalance: data.rawBalance, rawChecksum: data.rawChecksum, counterByte: data.counterByte);
  }

  Future<({Uint8List rawBalance, Uint8List rawChecksum, Uint8List counterByte})> getRawBalanceData(int blockNb) async{
    return await lock.synchronized(() async {
      final data = await readBlock(blockNb, retries: 5);
      return (rawBalance: data.sublist(1, 3), rawChecksum: data.sublist(3, 4), counterByte: data.sublist(15, 16));
    });
  }

  Future<void> setBalance(String value) async{

    // Convert given value to a list of 2 hex + get the checksum
    final newValue = (double.parse(value) * 100).toInt().toRadixString(16).padLeft(4, '0').split("").slices(2).map((x) => x.join()).toList().reversed.map((x) => int.parse(x, radix: 16)).toList();
    final checksum = newValue.reduce((acc, curr) => acc ^ curr);
      
    var newBalance = Balance(rawBalance: Uint8List.fromList(newValue), rawChecksum: Uint8List.fromList([checksum]), counterByte: Uint8List.fromList(balance.counterByte));
    Logger.root.info("New balance : $newBalance");
    final blockNbToWrite = await getCurrentBalanceBlockNumber();
    await writeBalance(newBalance, blockNbToWrite);
    await updateInnerBalance();      
    Logger.root.info("Tag balance written succesfully");
  }

  Future<int> getCurrentBalanceBlockNumber() async{
    final rawBlockData = await lock.synchronized(() async {
      return await readBlock(10, retries: 5);
    });

    if(rawBlockData.first == 0xAA){
      return 8;
    } else {
      return 9;
    }

  }

  Future<void> writeBalance(Balance balance, int blockNb) async{
    await lock.synchronized(() async {
      await writeBlock(blockNb, Uint8List.fromList(balance.getRawBlockValue()), retries: 5);
    });
  }

}