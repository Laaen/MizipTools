import "package:flutter_nfc_kit/flutter_nfc_kit.dart";

/// Type of the tag
enum NfcTagType {
  /// Mifare classic
  mifareClassic,

  /// Something else (not supported)
  other
}

/// A NFC tag
class NfcTag {
  /// Creates a new [NFCTag] from the given type and id
  NfcTag({required this.type, required this.id});

  /// Which type it is
  final NfcTagType type;

  /// Its UID
  final String id;
}

