import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:miziptools/data_dir/data_dir.dart';
import 'package:miziptools/nfc/currentnfctag.dart';
import 'package:miziptools/nfc/nfc_adapter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:logging_appenders/logging_appenders.dart';

import "pages/main_page.dart";
import 'package:logging/logging.dart';


void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  final externalDir = await getExternalStorageDirectory();
  setupLogging(externalDir!);
  // TODO: Check if null value can cause issues
  runApp(App(nfcAdapter: NfcAdapter(), dataDir: externalDir!,));
}

void setupLogging(Directory dataDir){
  if(kDebugMode){
    Logger.root.level = Level.INFO;
    Logger.root.onRecord.listen((record) {
      print('${record.level.name}: ${record.time}: ${record.message}');
    });
  } else {
    RotatingFileAppender(baseFilePath: "${dataDir.path}/debug.log", keepRotateCount: 1, rotateAtSizeBytes: 1024 * 1024).attachToLogger(Logger.root);
    Logger.root.level = Level.INFO;
  }
}

class App extends StatelessWidget {
  const App({super.key, required this.nfcAdapter, required this.dataDir});

  final NfcAdapter nfcAdapter;
  final Directory dataDir;

  static final colorScheme = ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 255, 204, 0), brightness: Brightness.dark);
  static final snackBarTheme =  const SnackBarThemeData(backgroundColor: Color.fromARGB(255, 255, 204, 0));

  @override
  Widget build(BuildContext context) {
    return MultiProvider(providers: [
      ChangeNotifierProvider.value(value: CurrentNFCTag.init()),
      ChangeNotifierProvider.value(value: DataDir(dataDir: dataDir)),
      Provider.value(value: nfcAdapter),
    ],
        child: MaterialApp(
          title: 'MizipTools',
          theme: ThemeData(colorScheme: colorScheme, snackBarTheme: snackBarTheme, useMaterial3: true),
          home: MainPage(),
      )
    ); 
  }
}