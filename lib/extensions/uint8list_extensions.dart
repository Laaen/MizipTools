import "dart:typed_data";

/// This extension contains only one function to convert a Uint8List to a String
extension Converter on Uint8List {
  /// Returns a String from a Uint8List
  /// Ex: [0x0A, 0x67, 0xB9] => "0A67B9"
  String toHexString() {
    return map((x) => x.toRadixString(16).padLeft(2, "0")).toList().join();
  }
}
