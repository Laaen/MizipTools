import "dart:typed_data";
import "package:flutter/material.dart";
import "package:logging/logging.dart";
import "package:miziptools/nfc/currentnfctag.dart";
import "package:miziptools/nfc/nfc_adapter.dart";
import "package:miziptools/nfc/nfc_tag.dart";
import "package:synchronized/synchronized.dart";

/// Performs an authentication to secotr 0, and returns true if succesful
///
/// Succes here is defined as 'The NfcAdapter didn't throw an exception)
/// it doesn't mean the used key was correct, only that the tag received
/// the NFC command and responded to it
///
/// By default it tries it two times with a small delay between each try
Future<bool> checkTagPresent(
  Lock globalLock,
  NfcAdapter nfcAdapter, {
  int retries = 2,
  Duration delay = const Duration(milliseconds: 50),
}) async {
  try {
    await globalLock.synchronized(() async {
      Logger.root.info("Tag Ping");
      await nfcAdapter.authenticateSector(
        0,
        keyA: Uint8List.fromList([0xA0, 0xA1, 0xA2, 0xA3, 0xA4, 0xA5]),
      );
    });
    return true;
  } on Exception catch (error) {
    if (retries > 0) {
      Logger.root.warning("Ping failed, retrying");
      await Future.delayed(delay);
      return checkTagPresent(
        globalLock,
        nfcAdapter,
        retries: retries - 1,
      );
    } else {
      Logger.root.warning("Exceeded retries on ping with error : $error");
      Logger.root.warning("Tag Lost");
      return false;
    }
  }
}

/// Attempts to poll a tag from the NfcAdapter, if succesful,
/// returns the tag else returns null
Future<NfcTag?> getNewTag(NfcAdapter nfcAdapter) async {
  try {
    final tag = await nfcAdapter.pollTag();
    return tag;
  } on Exception {
    Logger.root.fine("No tag found");
    return Future.value();
  }
}

/// Loops until it can get a new tag
Future<NfcTag> waitForNewTag(NfcAdapter nfcAdapter) async {
  NfcTag? tag;
  do {
    tag = await getNewTag(nfcAdapter);
  } while (tag == null);
  return tag;
}

/// Checks every 0.5 seconde if the tag is here
Future<void> waitForTagLost(
  CurrentNFCTag tag,
  NfcAdapter nfcAdapter,
  Lock globalLock,
) async {
  while (tag.isPresent() && await checkTagPresent(globalLock, nfcAdapter)) {
    await Future.delayed(const Duration(milliseconds: 500));
  }
}

/// Main loop for tag detection and handling
///
/// It will :
/// - Wait for a new tag
/// - Call the [onTagDetected] function with the new tag
/// - Call [waitForTagLost()] which will loop until the tag is lost
/// - Call the [onTagLost] function
Future<void> watchForTag(
  CurrentNFCTag currentTag,
  NfcAdapter nfcAdapter,
  Lock globalLock,
  BuildContext context,
  Function() onTagLost,
  Function(Lock, NfcTag, NfcAdapter) onTagDetected,
) async {
  while (true) {
    await waitForTagLost(currentTag, nfcAdapter, globalLock);
    await onTagLost();
    final tag = await waitForNewTag(nfcAdapter);
    await onTagDetected(globalLock, tag, nfcAdapter);
    await Future.delayed(const Duration(milliseconds: 10));
  }
}
