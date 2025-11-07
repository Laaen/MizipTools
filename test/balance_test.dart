import 'package:flutter/services.dart';
import 'package:miziptools/tags/balance.dart';
import 'package:test/test.dart';

void main(){
  group("Balance class tests", (){
    group("Constructors tests", (){
      test("Basic constructor", (){
        final balance = Balance(rawBalance: Uint8List.fromList([0xA9, 0x0A]), rawChecksum: Uint8List.fromList([0xA3]), counterByte: Uint8List.fromList([0x06]));
        expect(balance.counterByte, equals(Uint8List.fromList([0x06])));
        expect(balance.rawBalance, equals(Uint8List.fromList([0xA9, 0x0A])));
        expect(balance.rawChecksum, equals(Uint8List.fromList([0xA3])));
      });

      test("Empty constructor", (){
        final balance = Balance.empty();
        expect(balance.counterByte, equals(Uint8List.fromList([])));
        expect(balance.rawBalance, equals(Uint8List.fromList([])));
        expect(balance.rawChecksum, equals(Uint8List.fromList([])));
      });
    });

    group("Methods tests", (){
      final balance = Balance(rawBalance: Uint8List.fromList([0x6C, 0x0E]), rawChecksum: Uint8List.fromList([0xA3]), counterByte: Uint8List.fromList([0x06]));
      test("getStringBalance", (){
        expect(balance.getStringBalance(), equals("36.92"));
      });
      test("getDoubleBalance", (){
        expect(balance.getDoubleBalance(), equals(36.92));
      });
    });
  });

}