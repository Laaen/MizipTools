import 'package:flutter/material.dart';
import 'package:miziptools/extensions/string_extensions.dart';
import 'package:miziptools/main.dart';
import 'package:logging/logging.dart';
import 'package:miziptools/nfc/nfc_tag.dart';
import 'package:path_provider/path_provider.dart';

import 'full_app_test.dart';
import 'mock/mock_nfc_adapter.dart';
import 'mock/mock_nfc_tag.dart';


void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  final dataDir = await getExternalStorageDirectory();
  setupLogging();
  final adapter = MockNfcAdapter();
  adapter.setTag(generateMockMizipTag());
  runApp(App(nfcAdapter: adapter, dataDir: dataDir!,));
}

void setupLogging(){
  Logger.root.level = Level.INFO;
  Logger.root.onRecord.listen((record) {
    // ignore: avoid_print
    print('${record.level.name}: ${record.time}: ${record.message}');
  });
}

MockNfcTag generateMockMizipTag(){
  return MockNfcTag(type: NfcTagType.mifareClassic,
    data: [
      "ED711B74F3890400C808002000000017".toUint8List(),
      "6200488849884A884B88000000000000".toUint8List(),
      "00000000000000000000000000000000".toUint8List(),
      "A0A1A2A3A4A5787788C1B4C123439EEF".toUint8List(),
      "0E43004E61BC80010001000000005E02".toUint8List(),
      "01000001000080010001000000008001".toUint8List(),
      "AA020000000000000000000000000000".toUint8List(),
      "E4634151649478778803EA586922C355".toUint8List(),
      "00A90AA3000000000000000000000006".toUint8List(),
      "006C0E62000000000000000000000007".toUint8List(),
      "55070000000000000000000000000000".toUint8List(),
      "4604D2437F5E787788126893748F2935".toUint8List(),
      "00000000000000000000000000000000".toUint8List(),
      "00000000000000000000000000000001".toUint8List(),
      "55010000000000000000000000000000".toUint8List(),
      "0F035ADBC17878778800B139FE074DDA".toUint8List(),
      "00000000000000000000000000000000".toUint8List(),
      "00000000000000000000000000000001".toUint8List(),
      "55010000000000000000000000000000".toUint8List(),
      "DC0BAC5BA9E178778800AB67CA563689".toUint8List(),
    ] 
  );
}