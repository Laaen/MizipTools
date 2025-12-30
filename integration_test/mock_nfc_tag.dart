import 'package:collection/collection.dart';
import 'package:flutter/services.dart';
import 'package:miziptools/extensions/uint8list_extensions.dart';
import 'package:miziptools/nfc/nfc_tag.dart';

class MockNfcTag {

  List<Uint8List> data;
  final NfcTagType type;
  // If the tag should fail when writing to block 0
  bool failureBlockZero = false;

  MockNfcTag({required this.data, required this.type});

  String getUid(){
    return data[0].sublist(0, 4).toHexString();
  }

  Uint8List getBlock(int blockNb){
    return data[blockNb]; 
  }

  bool authenticateSector(int sectorNb, Uint8List? keyA, Uint8List? keyB){
    var result = false;
    if(keyA != null){
      final tagKeyA = data[sectorNb * 4 + 3].sublist(0, 6);
      result = tagKeyA.equals(keyA);
    }
    if(keyB != null){
      final tagKeyB = data[sectorNb * 4 + 3].sublist(10, 16);
      result = tagKeyB.equals(keyB);
    }
    return result;
  }

  Uint8List readBlock(int blockNb){
    return data[blockNb];
  }

  Uint8List readSector(int sectorNb){
    return Uint8List.fromList(data.sublist(sectorNb * 4, sectorNb * 4 + 4).flattened.toList());
  }

  bool writeBlock(int blockNb, Uint8List newData){
    // Fail write on block zero
    if(failureBlockZero && (blockNb == 0)){
      return false;
    }
    data[blockNb] = newData;
    return true;
  }

  void setFailureBlockZero(bool value){
    failureBlockZero = value;
  }

}