import 'package:flutter/material.dart';
import 'package:miziptools/main.dart';
import 'package:logging/logging.dart';
import 'package:path_provider/path_provider.dart';

import 'full_app_test.dart';
import 'mock_nfc_adapter.dart';


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