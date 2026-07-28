import "dart:io";

import "package:flutter/foundation.dart";
import "package:flutter/material.dart";
import "package:logging/logging.dart";
import "package:logging_appenders/logging_appenders.dart";
import "package:miziptools/data_dir/data_dir.dart";
import "package:miziptools/nfc/currentnfctag.dart";
import "package:miziptools/nfc/nfc_adapter.dart";
import "package:miziptools/pages/main_page.dart";
import "package:miziptools/pages/nfc_error_page.dart";
import "package:path_provider/path_provider.dart";
import "package:provider/provider.dart";

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final externalDir = await getExternalStorageDirectory();
  setupLogging(externalDir!);
  final adapter = NfcAdapter();
  // Sets the isValid property
  await adapter.checkValidity();
  runApp(App(nfcAdapter: adapter, dataDir: externalDir));
}

/// Sets up the logging
///
/// If in debug mode, the logging is only a print, to be able to view it in the console
/// If in release mode, the logs are appended in a file
void setupLogging(Directory dataDir) {
  if (kDebugMode) {
    Logger.root.level = Level.INFO;
    Logger.root.onRecord.listen((record) {
      // This print is here only in debug mode
      // ignore: avoid_print
      print("${record.level.name}: ${record.time}: ${record.message}");
    });
  } else {
    RotatingFileAppender(
      baseFilePath: "${dataDir.path}/debug.log",
      keepRotateCount: 1,
    ).attachToLogger(Logger.root);
    Logger.root.level = Level.INFO;
  }
}

/// Main class
class App extends StatelessWidget {
  /// Returns a new [App] with the given parameters
  const App({required this._nfcAdapter, required this._dataDir, super.key});

  static final _colorScheme = ColorScheme.fromSeed(
    seedColor: const Color.fromARGB(255, 255, 204, 0),
    brightness: Brightness.dark,
  );
  static const _snackBarTheme = SnackBarThemeData(
    backgroundColor: Color.fromARGB(255, 255, 204, 0),
  );

  final NfcAdapter _nfcAdapter;
  final Directory _dataDir;

  @override
  Widget build(BuildContext context) {
    if (_nfcAdapter.isValid) {
      return returnMainPage(context);
    } else {
      return returnNfcErrorPage(context);
    }
  }

  /// Returns the main page
  ///
  /// The main page of the application displayed if the NFC reader is enabled
  Widget returnMainPage(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: CurrentNFCTag.init()),
        ChangeNotifierProvider.value(value: DataDir(dataDir: _dataDir)),
        Provider.value(value: _nfcAdapter),
      ],
      child: MaterialApp(
        title: "MizipTools",
        theme: ThemeData(
          colorScheme: _colorScheme,
          snackBarTheme: _snackBarTheme,
          useMaterial3: true,
        ),
        home: const MainPage(),
      ),
    );
  }

  /// The page displayed if NFC is disabled
  Widget returnNfcErrorPage(BuildContext context) {
    return MaterialApp(
      title: "MizipTools",
      theme: ThemeData(
        colorScheme: _colorScheme,
        snackBarTheme: _snackBarTheme,
        useMaterial3: true,
      ),
      home: const NfcErrorPage(),
    );
  }
}
