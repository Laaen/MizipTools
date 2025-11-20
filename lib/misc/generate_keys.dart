import 'dart:typed_data';

import 'package:miziptools/extensions/string_extensions.dart';
import 'package:miziptools/extensions/uint8list_extensions.dart';
import 'package:miziptools/tags/mifare_classic_tag.dart';

MifareKeys defaultKeys = (a: List.generate(5, (_) => Uint8List.fromList([0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF])), b: List.generate(5, (_) => Uint8List.fromList([0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF])));

MifareKeys generateKeys(Uint8List uid){
  final baseKeysA = [
    Uint8List.fromList([0x64, 0x21, 0xE1, 0xE7, 0xE4, 0xD6]),
    Uint8List.fromList([0xC6, 0x46, 0x72, 0xF5, 0xFF, 0x1C]),
    Uint8List.fromList([0x8F, 0x41, 0xFA, 0x6D, 0x41, 0x3A]),
    Uint8List.fromList([0x5C, 0x49, 0x0C, 0xED, 0x29, 0xA3]),
  ];
  final baseKeysB = [
    Uint8List.fromList([0x4A, 0xEE, 0xE9, 0x60, 0x63, 0xE3]),
    Uint8List.fromList([0xC8, 0x25, 0xF4, 0xCD, 0x89, 0x83]),
    Uint8List.fromList([0x11, 0x8F, 0x7E, 0x45, 0xED, 0x6C]),
    Uint8List.fromList([0x0B, 0xD1, 0x4A, 0x14, 0x96, 0x3F]),
  ];
  final baseUID = Uint8List.fromList([0x6D, 0x33, 0xBB, 0xC2]);

  final transformedUID = xor(uid, baseUID, 8);

  final intermediateKeyA = Uint8List.fromList(transformedUID + transformedUID.sublist(0,2));
  final intermediateKeyB = Uint8List.fromList(transformedUID.sublist(2,4) + transformedUID);

  final keysA = [Uint8List.fromList([0xA0, 0xA1, 0xA2, 0xA3, 0xA4, 0xA5])] + baseKeysA.map((key) => xor(key, intermediateKeyA, 12)).toList(); 

  final keysB = [Uint8List.fromList([0xB4, 0xC1, 0x23, 0X43, 0x9e, 0xEF])] + baseKeysB.map((key) => xor(key, intermediateKeyB, 12)).toList();

  return (a: keysA, b: keysB);
}

Uint8List xor(Uint8List x, Uint8List y, int leftPad){
  return (int.parse(x.toHexString(), radix: 16) ^ int.parse(y.toHexString(), radix: 16)).toRadixString(16).padLeft(leftPad, '0').toUint8List();
}