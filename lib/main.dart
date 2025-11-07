import 'package:flutter/material.dart';
import 'package:miziptools/nfc/currentnfctag.dart';
import 'package:miziptools/nfc/nfc_adapter.dart';
import 'package:provider/provider.dart';

import "pages/main_page.dart";
import 'package:logging/logging.dart';


void main() {
  setupLogging();
  WidgetsFlutterBinding.ensureInitialized();
  runApp(App(nfcAdapter: NfcAdapter(),));
}

void setupLogging(){
  Logger.root.level = Level.INFO;
  Logger.root.onRecord.listen((record) {
    print('${record.level.name}: ${record.time}: ${record.message}');
  });
}

class App extends StatelessWidget {
  const App({super.key, required this.nfcAdapter});

  final NfcAdapter nfcAdapter;

  static final colorScheme = ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 255, 255, 255), brightness: Brightness.dark);
  static final snackBarTheme =  const SnackBarThemeData(backgroundColor: Color.fromARGB(255, 0, 155, 202));

  @override
  Widget build(BuildContext context) {
    return MultiProvider(providers: [
      ChangeNotifierProvider.value(value: CurrentNFCTag.init()),
      Provider.value(value: nfcAdapter)
    ],
        child: MaterialApp(
          title: 'MizipTools',
          theme: ThemeData(colorScheme: colorScheme, snackBarTheme: snackBarTheme, useMaterial3: true),
          home: MainPage(),
      )
    ); 
  }
}