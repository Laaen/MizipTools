import 'package:flutter/services.dart';
import 'package:miziptools/extensions/string_extensions.dart';
import 'package:miziptools/extensions/uint8list_extensions.dart';
import 'package:test/test.dart';

void main(){

  group("String converter", (){
    test("Throws an exception if an empty String is given", (){
      String data = "";
      expect(() => data.toUint8List(), throwsA(TypeMatcher<ConversionError>()));
    });

    test("Throws an exception if String has an odd number of characters", (){
      String data = "13F";
      expect(() => data.toUint8List(), throwsA(TypeMatcher<ConversionError>()));
    });

    test("Throws an exception if less than 2 characters are given", (){
      String data = "F";
      expect(() => data.toUint8List(), throwsA(TypeMatcher<ConversionError>()));
    });

    test("Result is correct", (){
      String data = "FFFF0020A80C";
      final expectedResult = Uint8List.fromList([255, 255, 0, 32, 168, 12]);
      expect(data.toUint8List(), expectedResult);
    });
  });

  group("Uint8List converter",(){
    test("Empty List returns empty String", (){
      final data = Uint8List.fromList([]);
      expect(data.toHexString(), equals(""));
    });

    test("Returns a correct result", (){
      final data = Uint8List.fromList([0x76, 0xAF, 0xD6]);
      expect(data.toHexString(), equals("76afd6"));
    });

    test("Works with leading 0x00", (){
      final data = Uint8List.fromList([0x00, 0xAF, 0xD6]);
      expect(data.toHexString(), equals("00afd6"));
    });

    test("Works with byte starting with 0x0", (){
      final data = Uint8List.fromList([0x02, 0xAF, 0xD6]);
      expect(data.toHexString(), equals("02afd6"));
    });

  });
}