import "dart:typed_data";
import "package:collection/collection.dart";
import "package:flutter/foundation.dart";
import "package:logging/logging.dart";
import "package:miziptools/misc/generate_keys.dart";
import "package:miziptools/tags/balance.dart";
import "package:miziptools/tags/mifare_classic_tag.dart";

/// Interface to the Mizip Tag
///
/// A Mizip tag is a Mifare classic with known keys +
/// normalized data layout
class MizipTag extends MifareClassicTag {
  /// Returns a [MizipTag] with the given data
  MizipTag({
    required super.uid,
    required super.lock,
    required super.nfcAdapter,
  });

  @override
  Balance getBalance() {
    return balance;
  }

  /// Gets the number of the current Balance block
  ///
  /// There are two balance blocks in a Mizip tag : 8 and 9
  /// The machine alternates between these two when reading / writing to the tag
  ///
  /// We can know which block is the correct one by reading the first byte
  /// of block 10
  /// 0xAA => block 8
  /// 0x55 => block 9
  Future<int> getCurrentBalanceBlockNumber() async {
    final rawBlockData = await lock.synchronized(() async {
      return readBlock(10, retries: 5);
    });

    if (rawBlockData.first == 0xAA) {
      return 8;
    } else {
      return 9;
    }
  }

  @override
  MifareKeys getKeys() {
    return generateKeys(uid);
  }

  // TODO(Laen): Check if can be deleted
  /// Communicates with the tag to get the raw balance data
  Future<({Uint8List rawBalance, Uint8List rawChecksum, Uint8List counterByte})>
      getRawBalanceData(int blockNb) async {
    return lock.synchronized(() async {
      final data = await readBlock(blockNb, retries: 5);
      return (
        rawBalance: data.sublist(1, 3),
        rawChecksum: data.sublist(3, 4),
        counterByte: data.sublist(15, 16)
      );
    });
  }

  /// Sets the new balance to the tag
  ///
  /// The String value is converted to a Balance object before being used to
  /// write the new balance block
  Future<void> setBalance(String value) async {
    // Convert given value to a list of 2 hex + get the checksum
    final newValue = (double.parse(value) * 100)
        .toInt()
        .toRadixString(16)
        .padLeft(4, "0")
        .split("")
        .slices(2)
        .map((x) => x.join())
        .toList()
        .reversed
        .map((x) => int.parse(x, radix: 16))
        .toList();
    final checksum = newValue.reduce((acc, curr) => acc ^ curr);

    final newBalance = Balance(
      rawBalance: Uint8List.fromList(newValue),
      rawChecksum: Uint8List.fromList([checksum]),
      counterByte: Uint8List.fromList(balance.counterByte),
    );
    Logger.root.info("New balance : $newBalance");
    final blockNbToWrite = await getCurrentBalanceBlockNumber();
    await writeBalance(newBalance, blockNbToWrite);
    await updateInnerBalance();
    Logger.root.info("Tag balance written succesfully");
  }

  @override
  Future<void> updateInnerBalance() async {
    final balanceBlockNb = await getCurrentBalanceBlockNumber();
    final data = await getRawBalanceData(balanceBlockNb);
    balance = Balance(
      rawBalance: data.rawBalance,
      rawChecksum: data.rawChecksum,
      counterByte: data.counterByte,
    );
  }

  /// Performn NCF communication with the tag to write the new
  /// balance block to the give index
  Future<void> writeBalance(Balance balance, int blockNb) async {
    await lock.synchronized(() async {
      await writeBlock(
        blockNb,
        Uint8List.fromList(balance.getRawBlockValue()),
        retries: 5,
      );
    });
  }
}
