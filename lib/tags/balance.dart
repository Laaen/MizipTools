import 'dart:typed_data';

import 'package:collection/collection.dart';

/// Represents the balance of a tag
/// Is used to convert between raw bytes format to double or String
class Balance {
  /// Two bytes for the balance
  late Uint8List rawBalance;
  /// One byte for balance checksum
  late Uint8List rawChecksum;
  /// On balance reading fail, it is marked as not valid
  bool valid = false;

  Balance({required this.rawBalance, required this.rawChecksum});
  
  Balance.empty(): rawBalance = Uint8List(0), rawChecksum = Uint8List(0);
  
  Balance.fromDouble(double value){
    rawBalance = _rawBalanceFromDouble(value);
    rawChecksum = _rawChecksum(rawBalance);
  }

  Uint8List _rawBalanceFromDouble(double value){
    return Uint8List.fromList((value* 100).toInt().toRadixString(16).padLeft(4, '0').split("").slices(2).map((x) => x.join()).toList().reversed.map((x) => int.parse(x, radix: 16)).toList());
  }

  Uint8List _rawChecksum(Uint8List rawBalance){
    return Uint8List.fromList([rawBalance.reduce((acc, curr) => acc ^ curr)]);
  }

  String getStringBalance(){
    final hexaStringArrBalance = _getHexaStringArrBalance();
    return (int.parse(hexaStringArrBalance.join(""), radix: 16) / 100.0).toStringAsFixed(2);
  }

  double getDoubleBalance(){
    final hexaStringArrBalance = _getHexaStringArrBalance();
    return  (int.parse(hexaStringArrBalance.join(""), radix: 16) / 100.0);
  }

  Uint8List getRawBlockValue(){
    return Uint8List.fromList([0] + rawBalance + rawChecksum + List.filled(12, 0));
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