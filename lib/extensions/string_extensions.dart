import 'dart:typed_data';
import 'package:collection/collection.dart';

class ConversionError implements Exception{
  String cause;
  ConversionError(this.cause);
}

extension Converter on String{

  Uint8List toUint8List(){
    if(length % 2 != 0){
      throw ConversionError("Odd number of characters");
    } else if(length < 2){
      throw ConversionError("Not enough characters (need at least 2)");
    }
    return Uint8List.fromList(split("").slices(2).map((x) => int.parse(x.join(), radix: 16)).toList());
  }

}