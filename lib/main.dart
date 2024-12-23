import 'package:flutter/material.dart';

import "pages/main_page.dart";

void main() {
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
        colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 236, 214, 134), brightness: Brightness.dark),
        snackBarTheme: const SnackBarThemeData(backgroundColor: Color.fromARGB(255, 202, 138, 0)),
        useMaterial3: true,
      ),
      home: MainPage(),
    );
  }
}

