import 'package:flutter/material.dart';
import 'package:miziptools/misc/nfctag.dart';
import 'package:miziptools/misc/mifare_classic_tag.dart';
import 'package:provider/provider.dart';

import "pages/main_page.dart";
import 'package:logging/logging.dart';


void main() {
  setupLogging();
  WidgetsFlutterBinding.ensureInitialized();
  runApp(App());
}

void setupLogging(){
  Logger.root.level = Level.INFO;
  Logger.root.onRecord.listen((record) {
    print('${record.level.name}: ${record.time}: ${record.message}');
  });
}

class App extends StatelessWidget {
  const App({super.key});

  static MifareClassicTag? tag;

  static final colorScheme = ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 255, 255, 255), brightness: Brightness.dark);
  static final snackBarTheme =  const SnackBarThemeData(backgroundColor: Color.fromARGB(255, 0, 155, 202));

  @override
  Widget build(BuildContext context) {
    return MultiProvider(providers: [ChangeNotifierProvider.value(value: CurrentNFCTag.init())],
        child: MaterialApp(
          title: 'MizipTools',
          theme: ThemeData(colorScheme: colorScheme, snackBarTheme: snackBarTheme, useMaterial3: true),
          home: MainPage(),
      )
    ); 
  }
}