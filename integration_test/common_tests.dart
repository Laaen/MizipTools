import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:miziptools/extensions/uint8list_extensions.dart';
import 'package:miziptools/main.dart';
import 'package:miziptools/widgets/dump_tag.dart' show DumpTag;
import 'package:path_provider/path_provider.dart';
import 'mock_nfc_adapter.dart';
import 'mock_nfc_tag.dart';

Future<void> testDumpTag(WidgetTester tester, MockNfcTag mockTag) async{
  final mockAdapter = MockNfcAdapter();
  mockAdapter.setTag(mockTag);

  await tester.pumpWidget(App(nfcAdapter: mockAdapter));
  await tester.tap(find.widgetWithText(Tab, "Dumps"));
  await tester.pumpAndSettle();
  await tester.tap(find.widgetWithText(DumpTag, "Dump Tag"));
  await tester.pumpAndSettle();
  expect(find.widgetWithText(SnackBar, "Dump done file : ${mockTag.getUid().toUpperCase()}.dump"), findsOneWidget);
      
  // File exists
  final dir = await getExternalStorageDirectory();
  final file = dir!.listSync().first;
  expect(file.path.split("/").last, equals("${mockTag.getUid().toUpperCase()}.dump"));

  // Content is OK
  final expectedContent = mockTag.data.map((block) => block.toHexString().toUpperCase()).join("\n");
  final fileContent = File(file.path).readAsStringSync();
  expect(fileContent, equals(expectedContent));
}

Future<void> testWriteFromDump(WidgetTester tester, MockNfcTag mockTag, String dumpContent) async{
  final mockAdapter = MockNfcAdapter();
  mockAdapter.setTag(mockTag);
      
  // Create the dump
  final dir = await getExternalStorageDirectory();
  File("${dir!.path}/${dumpContent.substring(0, 8)}.dump").writeAsStringSync(dumpContent);

  await tester.pumpWidget(App(nfcAdapter: mockAdapter));
  await tester.tap(find.widgetWithText(Tab, "Dumps"));
  await tester.pumpAndSettle();
  await tester.tap(find.byType(DropdownMenu));
  await tester.pumpAndSettle();
  await tester.tap(find.text("${dir.path}/${dumpContent.substring(0, 8)}.dump").last);
  await tester.pumpAndSettle();
  await tester.tap(find.widgetWithText(OutlinedButton, "Write"));
  await tester.pumpAndSettle();
  expect(find.widgetWithText(SnackBar, "Dump successfully written !"), findsOneWidget);

  // Content is OK
  expect(mockTag.data.map((block) => block.toHexString().toUpperCase()).join("\n"), equals(dumpContent));
}

Future<void> testChangeUid(WidgetTester tester, MockNfcTag mockTag, String newUid, String expectedContent) async{
  final mockAdapter = MockNfcAdapter();
  mockAdapter.setTag(mockTag);

  await tester.pumpWidget(App(nfcAdapter: mockAdapter));
  await tester.tap(find.widgetWithText(Tab, "Advanced"));
  await tester.pumpAndSettle();
  await tester.enterText(find.byType(TextFormField), newUid);
  await tester.tap(find.widgetWithText(OutlinedButton, "Ok"));
  await tester.pumpAndSettle();
  expect(find.widgetWithText(SnackBar, "UID changed successfully"), findsOneWidget);
  expect(mockTag.data.map((block) => block.toHexString().toUpperCase()).join("\n"), equals(expectedContent));
}