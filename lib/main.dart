import 'package:flutter/material.dart';
import 'package:miziptools/misc/mifare_classic_tag.dart';

import "pages/main_page.dart";
import 'package:logging/logging.dart';

// TODO: Writing new balance to tag 76.92
// TODO: Tag OK, balance: 4.92

void main() {
  setupLogging();
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const App());
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
    return MaterialApp(
      title: 'MizipTools',
      theme: ThemeData(colorScheme: colorScheme, snackBarTheme: snackBarTheme, useMaterial3: true),
      home: MainPage(),
    );
  }
}

