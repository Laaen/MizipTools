import 'dart:typed_data';

extension Converter on Uint8List{
  String toHexString(){
    return map((x) => x.toRadixString(16).padLeft(2, "0")).toList().join("");
  }
}