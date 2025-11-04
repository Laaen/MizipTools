import 'package:flutter/services.dart';
import 'package:miziptools/misc/generate_keys.dart';
import 'package:miziptools/tags/mifare_keys.dart';
import 'package:test/test.dart';

void main(){
  test("Generate a correct set of keys", (){

    final keysA = [
      Uint8List.fromList([0xA0, 0xA1, 0xA2, 0xA3, 0xA4, 0xA5]),
      Uint8List.fromList([0x34, 0x64, 0x0E, 0x8A, 0xB4, 0x93]),
      Uint8List.fromList([0x96, 0x03, 0x9D, 0x98, 0xAF, 0x59]),
      Uint8List.fromList([0xDF, 0x04, 0x15, 0x00, 0x11, 0x7F]),
      Uint8List.fromList([0x0C, 0x0C, 0xE3, 0x80, 0x79, 0xE6]),
    ];

    final expectedKeys = ( b: ["b4c123439eef", "a583b9258c8e", "2748a48866ee", "fee22e000201", "e4bc1a517952"]);

    expect(generateKeys(Uint8List.fromList([0x3D, 0x76, 0x54, 0xAF])).a, equals(keysA));
    //expect(generateKeys(Uint8List.fromList([0x3D, 0x76, 0x54, 0xAF])).b, equals(expectedKeys.b));
  });

}