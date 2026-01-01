import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:miziptools/extensions/uint8list_extensions.dart';
import 'package:miziptools/main.dart';
import 'package:miziptools/widgets/dump/dump_tag.dart' show DumpTag;
import 'package:path_provider/path_provider.dart';
import '../mock_nfc_adapter.dart';
import '../mock_nfc_tag.dart';

Future<void> testDumpTagSuccesful(WidgetTester tester, MockNfcTag mockTag) async{
  final dir = await getExternalStorageDirectory();
  final mockAdapter = MockNfcAdapter();
  mockAdapter.setTag(mockTag);

  await tester.pumpWidget(App(nfcAdapter: mockAdapter, dataDir: dir!,));
  await tester.tap(find.widgetWithText(Tab, "Dumps"));
  await tester.pumpAndSettle();
  await tester.tap(find.widgetWithText(DumpTag, "Dump Tag"));
  await tester.pumpAndSettle();
  expect(find.widgetWithText(SnackBar, "Dump done file : ${mockTag.getUid().toUpperCase()}.dump"), findsOneWidget);
      
  // File exists
  final file = dir.listSync().where((f) => f.path.split("/").last != "uid_save").last;
  expect(file.path.split("/").last, equals("${mockTag.getUid().toUpperCase()}.dump"));

  // Content is OK
  final expectedContent = mockTag.data.map((block) => block.toHexString().toUpperCase()).join("\n");
  final fileContent = File(file.path).readAsStringSync();
  expect(fileContent, equals(expectedContent));

  // Cleanup
  File(file.path).deleteSync();
}