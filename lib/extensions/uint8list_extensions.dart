import 'dart:typed_data';
import 'package:collection/collection.dart';

extension Converter on Uint8List{

  String toHexString(){
    return map((x) => x.toRadixString(16).padLeft(2, "0")).toList().join("");
  }

}