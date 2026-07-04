import "dart:typed_data";
import "package:collection/collection.dart";

/// Thrown if something bad happens during the conversion
/// from String to Uint8List
class ConversionError implements Exception {
  /// Create a [ConversionError] with the given cause
  ConversionError(this.cause);

  /// Why the exception was thrown
  String cause;
}

/// This extension contains only one function to convert a String to a Uint8List
extension Converter on String {
  /// Returns a Uint8List from a string
  /// Throws a [ConversionError] if an incorrect string is passed to it
  /// Ex : "0A67B9" => [0x0A, 0x67, 0xB9]
  Uint8List toUint8List() {
    if (length % 2 != 0) {
      throw ConversionError("Odd number of characters");
    } else if (length < 2) {
      throw ConversionError("Not enough characters (need at least 2)");
    }
    try {
      return Uint8List.fromList(
        split("").slices(2).map((x) => int.parse(x.join(), radix: 16)).toList(),
      );
    } on FormatException {
      throw ConversionError(
        "A non-hexadecimal chaeacter is present in the string",
      );
    }
  }
}

