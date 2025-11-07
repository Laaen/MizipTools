import 'dart:typed_data';

import 'package:collection/collection.dart';

/// Represents the balance of a tag
/// Is used to convert between raw bytes format to double or String
class Balance {
  /// Two bytes for the balance
  late Uint8List rawBalance;
  /// One byte for balance checksum
  late Uint8List rawChecksum;
  late Uint8List counterByte;
  /// On balance reading fail, it is marked as not valid
  bool valid = false;

  Balance({required this.rawBalance, required this.rawChecksum, required this.counterByte});
  
  Balance.empty(): rawBalance = Uint8List(0), rawChecksum = Uint8List(0), counterByte = Uint8List(0);

  // TODO : An exception may occur here : FormatException (FormatException: Invalid radix-16 number (at character 1)
  String getStringBalance(){
    final hexaStringArrBalance = _getHexaStringArrBalance();
    return (int.parse(hexaStringArrBalance.join(""), radix: 16) / 100.0).toStringAsFixed(2);
  }

  double getDoubleBalance(){
    final hexaStringArrBalance = _getHexaStringArrBalance();
    return  (int.parse(hexaStringArrBalance.join(""), radix: 16) / 100.0);
  }

  Uint8List getRawBlockValue(){
    return Uint8List.fromList([0] + rawBalance + rawChecksum + List.filled(11, 0) + counterByte);
  }

  List<String> _getHexaStringArrBalance(){
    return rawBalance.map((x) => x.toRadixString(16).padLeft(2, "0")).toList().reversed.toList();
  }

  void setValid(bool state){
    valid = state;
  }

  bool isValid(){
    return valid;
  }

}