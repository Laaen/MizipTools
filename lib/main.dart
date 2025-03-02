import 'package:flutter/material.dart';

import "pages/main_page.dart";
import 'package:logging/logging.dart';

// TODO: Writing new balance to tag 76.92
// TODO: Tag OK, balance: 4.92

void main() {

  // Setup logging
  Logger.root.level = Level.INFO;
  Logger.root.onRecord.listen((record) {
    print('${record.level.name}: ${record.time}: ${record.message}');
  });

  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MizipTools',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 255, 255, 255), brightness: Brightness.dark),
        snackBarTheme: const SnackBarThemeData(backgroundColor: Color.fromARGB(255, 0, 155, 202)),
        useMaterial3: true,
      ),
      home: MainPage(),
    );
  }
}

