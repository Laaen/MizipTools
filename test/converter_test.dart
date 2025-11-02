import 'package:flutter/services.dart';
import 'package:miziptools/extensions/string_extensions.dart';
import 'package:test/test.dart';

void main(){
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

}