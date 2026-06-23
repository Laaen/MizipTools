import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logging/logging.dart';
import 'package:miziptools/nfc/nfc_adapter.dart';
import 'package:miziptools/nfc/nfc_tag.dart';

import 'mock_nfc_tag.dart';

class MockNfcAdapter extends NfcAdapter {
  /// Makes the methods fail (either exception throw of false return)
  bool communicationError = false;

  /// The NFC tag to simulate
  MockNfcTag? tagToSimulate;

  /// If NFC is enabled on the device
  final bool available;

  /// The currently present tag
  MockNfcTag? currentTag;

  MockNfcAdapter({this.tagToSimulate, this.available = true});

  void removeTag() {
    currentTag = null;
  }

  void putTag() {
    currentTag = tagToSimulate;
  }

  @override
  bool get isValid {
    return available;
  }

  @override
  Future<void> checkValidity() async {
    return;
  }

  @override
  Future<Uint8List> pingTag(
      {Duration timeout = const Duration(milliseconds: 200)}) async {
    Future.delayed(Duration(milliseconds: 500));
    if (currentTag == null) {
      Logger.root.warning("Ping : Tag is null");
      throw NfcAdapterTagRemovedException("Tag was removed");
    } else if (communicationError) {
      Logger.root.warning("Ping : Mocking communication error");
      throw NfcAdapterCommunicationException("Communication error");
    } else {
      Logger.root.info("Ping OK");
      return Uint8List(0);
    }
  }

  @override
  Future<NfcTag> pollTag(
      {Duration timeout = const Duration(milliseconds: 200)}) async {
    Logger.root.info("Polling tag ...");
    await Future.delayed(Duration(milliseconds: 500));
    if (communicationError) {
      Logger.root.warning("Poll : Mocking communication error");
      throw NfcAdapterCommunicationException("Communication error");
    } else {
      Logger.root.info("Poll : Returning tag");
      return NfcTag(type: tagToSimulate!.type, id: tagToSimulate!.getUid());
    }
  }

  @override
  Future<void> releaseTag() async {
    removeTag();
  }

  @override
  Future<bool> authenticateSector(int sectorNb,
      {Uint8List? keyA, Uint8List? keyB}) async {
    return currentTag!.authenticateSector(sectorNb, keyA, keyB);
  }

  @override
  Future<bool> writeBlock(int blockNb, Uint8List data) async {
    if (communicationError) {
      throw NfcAdapterCommunicationException("Communication error");
    }
    return currentTag!.writeBlock(blockNb, data);
  }

  @override
  Future<Uint8List> readBlock(int blockNb) async {
    if (communicationError) {
      throw NfcAdapterCommunicationException("Communication error");
    }
    return currentTag!.readBlock(blockNb);
  }

  @override
  Future<Uint8List> readSector(int sectorNb) async {
    if (communicationError) {
      throw NfcAdapterCommunicationException("Communication error");
    }
    return currentTag!.readSector(sectorNb);
  }

  void setCommunicationError(bool value) {
    communicationError = value;
  }
}
