import "dart:io";
import "package:collection/collection.dart";
import "package:flutter/foundation.dart";
import "package:logging/logging.dart";
import "package:miziptools/extensions/uint8list_extensions.dart";
import "package:miziptools/misc/generate_keys.dart";
import "package:miziptools/tags/balance.dart";
import "package:miziptools/tags/mifare_classic_tag.dart";
import "package:miziptools/tags/mizip_tag.dart";
import "package:path_provider/path_provider.dart";

/// Represents the NFC tag currently detected by the phone
/// It uses the [ChangeNotifier] mixin to allow for UI updates
class CurrentNFCTag with ChangeNotifier {
  /// Creates a [CurrentNFCTag] with an innerTag set ot null
  CurrentNFCTag.init();

  /// The currently detected tag
  /// Can be a [MifareClassicTag], a [MizipTag] or null
  MifareClassicTag? innerTag;

  /// Sets innerTag to newTag and triggers a balance update with [MifareClassicTag.updateInnerBalance()]
  /// Triggers an UI reload
  Future<void> updateInnerTag(MifareClassicTag? newTag) async {
    innerTag = newTag;
    await innerTag?.updateInnerBalance();
    notifyListeners();
  }

  /// Sets innerTag to null and triggers an UI reload
  void setTagAbsent() {
    innerTag = null;
    notifyListeners();
  }

  /// Returns if innerTag is null
  bool isPresent() {
    return innerTag != null;
  }

  /// Returns the [MifareKeys] of the innerTag
  MifareKeys getKeys() {
    return innerTag!.getKeys();
  }

  /// Returns the UID of the innerTag
  Uint8List getUid() {
    return innerTag!.uid;
  }

  /// Returns the [Balance] of the innerTag
  /// If you want up to date data, you must call [updateInnerBalance()] before
  Balance getBalance() {
    return innerTag!.getBalance();
  }

  /// Performs NFC communication to get the balance of the tag
  Future<void> updateInnerBalance() async {
    await innerTag!.updateInnerBalance();
  }

  /// Returns the sector data as a 16 * 4 bytes [Uint8List]
  /// Each sector has 4 blocks of 16 bytes
  Future<Uint8List> readSector(
    int number, {
    int retries = 0,
    Duration delay = const Duration(milliseconds: 10),
  }) async {
    return innerTag!.readSector(number);
  }

  /// Returns the whole tag data as a list of 5 [Uint8List]
  /// A tag has 5 sectors
  Future<List<Uint8List>> dumpTagData() async {
    return innerTag!.dumpTagData();
  }

  /// Writes the given data to the tag
  Future<void> writeDumpToTag(List<Uint8List> data) async {
    await saveUID(data[0].sublist(0, 4).toHexString().toUpperCase());
    await innerTag?.writeDumpToTag(data);
  }

  /// Sets a new balance to the tag
  Future<void> setBalance(String value) async {
    final tag = innerTag! as MizipTag;
    await tag.setBalance(value);
    notifyListeners();
  }

  /// Sets a new UID to the tag
  /// The tag must be a CUID one
  Future<void> setUid(Uint8List newUid) async {
    await saveUID(newUid.toHexString().toUpperCase());
    await innerTag!.setUid(newUid);
  }

  /// Authenticato to the given sector with the given keys
  Future<bool> authenticateSector(int sectorNb, Uint8List? keyA, keyB) async {
    return await innerTag!.authenticateSector(sectorNb, keyA: keyA, keyB: keyB);
  }

  Future<void> releaseTag() async {
    await innerTag!.releaseTag();
    setTagAbsent();
  }

  Future<void> autoRepair(Uint8List oldUid) async {
    MifareKeys validKeys = (a: [], b: []);

    MifareKeys candidateCurrentUid = generateKeys(innerTag!.uid);
    MifareKeys candidateOldUid = generateKeys(oldUid);
    MifareKeys candidateMifareClassic = (
      a: List.filled(
          5, Uint8List.fromList([0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF])),
      b: List.filled(
          5, Uint8List.fromList([0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF]))
    );

    // Test keys A
    for (final (index, keys) in IterableZip([
      candidateMifareClassic.a,
      candidateCurrentUid.a,
      candidateOldUid.a
    ]).indexed) {
      for (final key in keys) {
        if (await tryAuthenticate(index, keyA: key)) {
          validKeys.a.add(key);
          break;
        }
      }
    }

    // Test keys B
    for (final (index, keys) in IterableZip([
      candidateMifareClassic.b,
      candidateCurrentUid.b,
      candidateOldUid.b
    ]).indexed) {
      for (final key in keys) {
        if (await tryAuthenticate(index, keyB: key)) {
          validKeys.b.add(key);
          break;
        }
      }
    }
    await innerTag!.rewriteKeys(validKeys, candidateCurrentUid);
  }

  Future<bool> tryAuthenticate(int sectorNb,
      {Uint8List? keyA, Uint8List? keyB, int nbRetries = 2}) async {
    if (!await innerTag!.authenticateSector(sectorNb, keyA: keyA, keyB: keyB)) {
      if (nbRetries > 0) {
        return tryAuthenticate(sectorNb,
            keyA: keyA, keyB: keyB, nbRetries: nbRetries - 1);
      } else {
        return false;
      }
    } else {
      return true;
    }
  }

  bool isMizipTag() {
    return isPresent() && innerTag! is MizipTag;
  }

  Future<bool> saveUID(String uid) async {
    final dataDir = await getExternalStorageDirectory();
    if (dataDir == null) {
      return false;
    }

    try {
      File("${dataDir.path}/uid_save").writeAsStringSync(uid);
    } on FileSystemException catch (e) {
      Logger.root.severe("Error while saving UID : $e");
      return false;
    }

    return true;
  }
}
