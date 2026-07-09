import "package:flutter/services.dart";
import "package:flutter_nfc_kit/flutter_nfc_kit.dart";
import "package:logging/logging.dart";
import "package:miziptools/extensions/string_extensions.dart";
import "package:miziptools/nfc/nfc_tag.dart";

/// All NFC interaction goes through this class
///
/// Is is meant to be an abstraction over NFC communication
/// Currently, it uses the "flutter_nfc_kit" module to perform
/// nfc stuff
class NfcAdapter {
  /// Returns a new NfcAdapter
  NfcAdapter();

  /// Wether if NFC is available and enabled on the device or not
  bool nfcEnabled = false;

  /// Getter for nfcEnabled
  bool get isValid {
    return nfcEnabled;
  }

  /// Calls [FlutterNfcKit.authenticateSector()] with the provided keys
  ///
  /// Returns wether the authentication is succesful or not
  /// A succesful authentication means the key was correct
  ///
  /// Throws an [NfcAdapterException] if something went wrong
  Future<bool> authenticateSector(
    int sectorNb, {
    Uint8List? keyA,
    Uint8List? keyB,
  }) async {
    try {
      return await FlutterNfcKit.authenticateSector(
        sectorNb,
        keyA: keyA,
        keyB: keyB,
      );
    } on Exception catch (e) {
      handleException(e);
    }
    return false;
  }

  /// Gets the device's nfc availability
  Future<void> checkValidity() async {
    nfcEnabled =
        await FlutterNfcKit.nfcAvailability == NFCAvailability.available;
  }

  /// Gets an exception throwed by a [FlutterNfcKit] method invocation
  /// and rethrows a [NfcAdapterException] based on the original exception
  void handleException(Exception exception) {
    if (exception is PlatformException) {
      logFiltered(exception);
      if (exception.code == "503") {
        throw NfcAdapterTagRemovedException("Tag was removed");
      } else {
        throw NfcAdapterCommunicationException(
          "Communication exception occured",
        );
      }
    } else {
      throw NfcAdapterException("Unknown exception occured : $exception");
    }
  }

  /// Doesn't log errors 404 (NFC not available), 408 (Polling tag timeout)
  void logFiltered(PlatformException exception) {
    if (![404, 408].contains(int.parse(exception.code))) {
      Logger.root.warning("Got exception : $exception");
    }
  }

  Future<NfcTag> pollTag(
      {Duration timeout = const Duration(milliseconds: 200)}) async {
    try {
      final tag =
          await FlutterNfcKit.poll(timeout: timeout, androidCheckNDEF: false);
      final type = tag.type == NFCTagType.mifare_classic
          ? NfcTagType.mifareClassic
          : NfcTagType.other;
      return NfcTag(type: type, id: tag.id);
    } on Exception catch (e) {
      handleException(e);
    }
    return NfcTag(type: NfcTagType.other, id: "FFFFFFFF");
  }

  Future<Uint8List> readBlock(int blockNb) async {
    try {
      return await FlutterNfcKit.readBlock(blockNb);
    } on Exception catch (e) {
      handleException(e);
    }
    return Uint8List(0);
  }

  Future<Uint8List> readSector(int sectorNb) async {
    try {
      return await FlutterNfcKit.readSector(sectorNb);
    } on Exception catch (e) {
      handleException(e);
    }
    return Uint8List(0);
  }

  Future<void> releaseTag() async {
    try {
      return await FlutterNfcKit.finish();
    } on Exception catch (_) {
      return;
    }
  }

  Future<bool> writeBlock(int blockNb, Uint8List data) async {
    try {
      await FlutterNfcKit.writeBlock(blockNb, data);
      // If we reach here, there was no error
      return true;
    } on Exception catch (e) {
      handleException(e);
      return false;
    }
  }
}

class NfcAdapterCommunicationException extends NfcAdapterException {
  NfcAdapterCommunicationException(super.cause);
}

class NfcAdapterException implements Exception {
  NfcAdapterException(this.cause);
  String cause;
}

class NfcAdapterTagRemovedException extends NfcAdapterException {
  NfcAdapterTagRemovedException(super.cause);
}
