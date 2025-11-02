import 'package:flutter/foundation.dart';

Uint8List generateBcc(Uint8List uid){
  return Uint8List.fromList([uid.reduce((a, b) => a ^ b)]);
}