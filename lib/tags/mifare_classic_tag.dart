import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';
import 'package:miziptools/extensions/uint8list_extensions.dart';
import 'package:miziptools/misc/generate_keys.dart';
import 'package:miziptools/nfc/nfc_adapter.dart';
import 'package:miziptools/tags/balance.dart';
import 'package:miziptools/exceptions/nfc_exceptions.dart';
import 'package:miziptools/tags/mizip_tag.dart';
import 'package:synchronized/synchronized.dart';

typedef MifareKeys = ({List<Uint8List> a, List<Uint8List> b});

class MifareClassicTag with ChangeNotifier {
  
  /// Lock used to prevent concurrent access to the NFC reader
  Lock lock;

  NfcAdapter nfcAdapter;

  Uint8List uid;
  Balance balance = Balance.empty();

  MifareClassicTag({required this.uid, required this.lock, required this.nfcAdapter});

  static Uint8List generateBcc(Uint8List uid){
    return Uint8List.fromList([uid.reduce((a, b) => a ^ b)]);
  }

  MifareKeys getKeys(){
    return (a: List.filled(5, Uint8List.fromList([0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF])), b:List.filled(5, Uint8List.fromList([0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF])));
  }

  Balance getBalance(){
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

  // TODO : Make an explicit error if trying to write to block 0 if tag is not CUID
  Future<void> writeDumpToTag(List<Uint8List> data) async{
    await lock.synchronized(() async{
      try{
        // Write the data in every sector except sector 0 (issues, if UID changes, breaks everything, we have to do it at the end)
        var currentBlockNb = 4;
        for (var (idx, line) in data.skip(4).indexed){
          await writeBlock(currentBlockNb + idx, line, retries: 5);
        }
      }catch (error){
        Logger.root.warning("Error while dump writing : $error");
        rethrow;
      }
      // We want to throw a special exception
      await writeSectorZero(data.take(4).toList());
    });
  }

  // Special case block 0 must be written last (tag disconnection on UID rewrite)
  Future<void> writeSectorZero(List<Uint8List> data) async{
    // Blocks 1, 2 and sector trailer
    await writeBlock(1, data[1], retries: 5);
    await writeBlock(2, data[2], retries: 5);
    await writeBlock(3, data[3], retries: 5);

    // Block 0, we need to use the new B key of the sector

    // If a fail here, the tag is not a CUID one
    try{
      final newKey = data[3].sublist(10, 16);
      await writeBlock(0, data[0], keyB: newKey, retries: 5);
    } catch (_){
      throw WriteSectorZeroException("Error while writing block 0");
    }
  }

  // TODO : Make an explicit error if trying to write to block 0 if tag is not CUID
  Future<void> setUid(Uint8List newUid) async{

    await lock.synchronized(() async{
      // We must get block 0's content before changing the keys !
      final currentBlockZero = await readBlock(0, retries: 5);
      final newBlockZero = Uint8List.fromList(newUid + generateBcc(newUid) + currentBlockZero.sublist(5, 16));

      // Generate keys only if we are MizipTag, else use defaults
      MifareKeys newKeys;
      if (this is MizipTag){
        newKeys = generateKeys(newUid);
      } else {
        newKeys = defaultKeys;
      }
       
      for(final sectorIdx in Iterable.generate(4)){
        await setsectorKey(sectorIdx + 1, newKeys.a[sectorIdx + 1], newKeys.b[sectorIdx + 1]);
      }

      await setsectorKey(0, newKeys.a[0], newKeys.b[0]);
      await writeBlock(0, newBlockZero, keyB: newKeys.b[0], retries: 5);
    });
  }

  Future<void> rewriteKeys(MifareKeys currentKeys, correctKeys) async{
    return await lock.synchronized(() async {
      for (final (index, _) in currentKeys.a.indexed){
          await setsectorKey(index, correctKeys.a[index], correctKeys.b[index], currentKeyA: currentKeys.a[index], currentKeyB: currentKeys.b[index]);  
      }
    });
  }

  Future<void> setsectorKey(int sectorNb, Uint8List newKeyA, Uint8List newKeyB, {Uint8List? currentKeyA, Uint8List? currentKeyB}) async{
    await lock.synchronized(() async{
      final sectorData = await readSector(sectorNb, retries: 5, keyA: currentKeyA);
      final currentTrailerBlock = Uint8List.fromList(sectorData.slices(16).last);

      final newTrailerBlock = Uint8List.fromList(newKeyA + currentTrailerBlock.sublist(6, 10) + newKeyB);
      await writeBlock(sectorNb * 4 + 3, newTrailerBlock, retries: 5, keyB: currentKeyB);
    });
  }

  /// Returns wether the authentication is successful of not.
  /// 
  /// Some retries are needed because it can fail even if the provided key is the good one.
  /// 
  /// Throws [NfcAdapterTagRemovedException] | [NfcAdapterCommunicationException] | [NfcAdapterException]
  Future<bool> authenticateSector(int sectorNb, {int retries = 2, Uint8List? keyA, Uint8List? keyB}) async{
    Logger.root.info("Authenticating to sector $sectorNb with keys A: ${keyA?.toHexString()} B: ${keyB?.toHexString()}");
    bool result = false;
    for(final _ in Iterable.generate(retries)){
      result = await nfcAdapter.authenticateSector(sectorNb, keyA: keyA, keyB: keyB);
      if(result){
        return true;
      }
    }
    return result;
  }

  Future<void> releaseTag() async{
    try{
      await nfcAdapter.releaseTag();
    } catch (e){
      throw ReleaseFailedException(e.toString());
    }
  }

  /// Returns the block's data
  /// 
  /// Throws [RetriesExcedeedException] | [SectorAuthenticationFailed] | [NfcAdapterCommunicationException] | [NfcAdapterTagRemovedException] | [NfcAdapterException]
  Future<Uint8List> readBlock(int number, {int retries = 0, Duration delay = const Duration(milliseconds: 10)}) async{

    Uint8List result = Uint8List(0);
    Logger.root.info("Reading block $number with key ${getKeys().a[number ~/ 4].toHexString()}");

    return await lock.synchronized(() async {
      for(final _ in Iterable.generate(retries)){
        Future.delayed(delay);
        if(await authenticateSector(number ~/ 4, keyA: getKeys().a[number ~/ 4])){
          result = await nfcAdapter.readBlock(number);
        } else {
          Logger.root.severe("Read failed : Authentication failure with keyA : ${getKeys().a[number ~/ 4].toHexString()}");
          throw SectorAuthenticationFailed("Read failed : Authentication failure with keyA : ${getKeys().a[number ~/ 4].toHexString()}");
        }

        if(result.isNotEmpty){
          return result;
        }

      }
      Logger.root.severe("Failed to read block $number");
      throw RetriesExcedeedException("Failed to read block $number : number of retries excedeed");
    });
  }


  /// Returns the sector's data
  /// 
  /// Throws [RetriesExcedeedException] | [SectorAuthenticationFailed] | [NfcAdapterCommunicationException] | [NfcAdapterTagRemovedException] | [NfcAdapterException]
  Future<Uint8List> readSector(int number, {int retries = 0, Duration delay = const Duration(milliseconds: 10), Uint8List? keyA}) async{

    Uint8List result = Uint8List(0);
    final key = keyA ?? getKeys().a[number];

    Logger.root.info("Reading sector $number with key ${key.toHexString()}");

    return await lock.synchronized(() async {
      for(final _ in Iterable.generate(retries)){
        Future.delayed(delay);
        if(await authenticateSector(number, keyA: key)){
          result = await nfcAdapter.readSector(number);
        } else {
          Logger.root.severe("Read failed : Authentication failure with keyA : ${key.toHexString()}");
          throw SectorAuthenticationFailed("Read failed : Authentication failure with keyA : ${key.toHexString()}");
        }

        if(result.isNotEmpty){
          return result;
        }

      }
      Logger.root.severe("Failed to read block $number");
      throw RetriesExcedeedException("Failed to read block $number : number of retries excedeed");
    });
  }
  

  /// Writes the given data to the block
  /// 
  /// Throws [RetriesExcedeedException] | [SectorAuthenticationFailed] | [NfcAdapterCommunicationException] | [NfcAdapterTagRemovedException] | [NfcAdapterException]
  Future<void> writeBlock(int number, Uint8List data, {int retries = 0, Duration delay = const Duration(milliseconds: 10), Uint8List? keyB}) async{

    bool result = false;
    final key = keyB ?? getKeys().b[number ~/ 4];

    Logger.root.info("Writing data : (${data.toHexString()}) to block $number with key ${key.toHexString()}");

    return await lock.synchronized(() async {
      for(final _ in Iterable.generate(retries)){
        Future.delayed(delay);
        if(await authenticateSector(number ~/ 4, keyB: key)){
          result = await nfcAdapter.writeBlock(number, data);
        } else {
          Logger.root.severe("Write failed : Authentication failure with keyB : ${key.toHexString()}");
          throw SectorAuthenticationFailed("Write failed : Authentication failure with keyB : ${key.toHexString()}");
        }

        if(result){
          return;
        }

      }
      Logger.root.severe("Failed to write block $number");
      throw RetriesExcedeedException("Failed to write block $number : number of retries excedeed");
    });
  }
}
