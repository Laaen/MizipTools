import "dart:typed_data";

/// Represents the balance of a tag
/// Is used to convert between raw bytes format to double or String
class Balance {
  /// Returns a new [Balance] with the given data
  /// Its validity is checked at instanciation time
  Balance({
    required this.rawBalance,
    required this.rawChecksum,
    required this.counterByte,
  }) {
    checkBalance();
  }

  /// Returns a [Balance] with its fields set to 0
  Balance.empty()
      : rawBalance = Uint8List(0),
        rawChecksum = Uint8List(0),
        counterByte = Uint8List(0);

  /// Two bytes for the balance
  late Uint8List rawBalance;

  /// One byte for balance checksum
  late Uint8List rawChecksum;

  /// The byte which acts like a counter (the last one of the block)
  /// It is incremented by 1 everytime the balance is changed
  late Uint8List counterByte;

  /// On balance reading fail, it is marked as not valid
  BalanceValidity valid = BalanceValidity.invalid;

  /// Checks if balance is valid
  ///
  /// Validity is checked by looking at the length of the fields :
  /// - Two bytes for the balance
  /// - One byte for the checksum
  /// - One byte for the counter
  ///
  /// If the computed checksum does not match,
  /// the balance validity is [BalanceValidity.badChecksum]
  void checkBalance() {
    if (rawBalance.length != 2 ||
        rawChecksum.length != 1 ||
        counterByte.length != 1) {
      valid = BalanceValidity.invalid;
    }

    if (checkChecksum()) {
      valid = BalanceValidity.valid;
    } else {
      valid = BalanceValidity.badChecksum;
    }
  }

  /// Computes the balance checksum from the two balance bytes
  bool checkChecksum() {
    return rawBalance.first ^ rawBalance.last == rawChecksum.first;
  }

  /// Gets the balance as a [double]
  double getDoubleBalance() {
    final hexaStringArrBalance = _getHexaStringArrBalance();
    return int.parse(hexaStringArrBalance.join(), radix: 16) / 100.0;
  }

  /// Generates the balance block full data
  Uint8List getRawBlockValue() {
    return Uint8List.fromList(
        [0] + rawBalance + rawChecksum + List.filled(11, 0) + counterByte);
  }

  /// Gets the balance value as a string
  // TODO(Laen): An exception may occur here : FormatException (FormatException:
  // Invalid radix-16 number (at character 1)
  String getStringBalance() {
    final hexaStringArrBalance = _getHexaStringArrBalance();
    return (int.parse(hexaStringArrBalance.join(), radix: 16) / 100.0)
        .toStringAsFixed(2);
  }

  /// Getter for valid
  BalanceValidity isValid() {
    return valid;
  }

  /// Changes the validity of the Balance
  void setValid(BalanceValidity state) {
    valid = state;
  }

  List<String> _getHexaStringArrBalance() {
    return rawBalance
        .map((x) => x.toRadixString(16).padLeft(2, "0"))
        .toList()
        .reversed
        .toList();
  }
}

///Enum for validity of Balance
enum BalanceValidity {
  /// The balance is valid, but the checksum is not
  badChecksum,

  /// The balance ind not valid
  invalid,

  /// The balance is valid
  valid,
}
