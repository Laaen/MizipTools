  
import 'package:miziptools/tags/mifare_keys.dart';

MifareKeys generateKeys(String uid){
  const baseKeysA = ["6421E1E7E4D6", "C64672F5FF1C", "8F41FA6D413A", "5C490CED29A3"];
  const baseKeysB = ["4AEEE96063E3", "C825F4CD8983", "118F7E45ED6C", "0BD14A14963F"];
  const baseUID = "6D33BBC2";

  final transformedUID = xor(uid, baseUID, 8);

  final intermediateKeyA = "$transformedUID${transformedUID.substring(0,4)}";
  final intermediateKeyB = "${transformedUID.substring(4,8)}$transformedUID";

  final keysA = ["a0a1a2a3a4a5"] + baseKeysA.map((key) => xor(key, intermediateKeyA, 12)).toList(); 

  final keysB = ["b4c123439eef"] + baseKeysB.map((key) => xor(key, intermediateKeyB, 12)).toList();

  return (a: keysA, b: keysB);
}

String xor(String x, String y, int leftPad){
  return (int.parse(x, radix: 16) ^ int.parse(y, radix: 16)).toRadixString(16).padLeft(leftPad, '0');
}