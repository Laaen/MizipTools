import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:miziptools/extensions/uint8list_extensions.dart';
import 'package:miziptools/main.dart';
import 'package:miziptools/widgets/dump/dialog_read_dump.dart';
import 'package:miziptools/widgets/dump/dump_tag.dart' show DumpTag;
import 'package:path_provider/path_provider.dart';
import 'mock_nfc_adapter.dart';
import 'mock_nfc_tag.dart';

Future<void> testDumpTag(WidgetTester tester, MockNfcTag mockTag) async{
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

Future<void> testWriteFromDump(WidgetTester tester, MockNfcTag mockTag, String dumpContent) async{
  final mockAdapter = MockNfcAdapter();
  mockAdapter.setTag(mockTag);

  // To compare with saved_uid
  final newUid = dumpContent.substring(0, 8);
      
  // Create the dump
  final dir = await getExternalStorageDirectory();
  File("${dir!.path}/${dumpContent.substring(0, 8)}.dump").writeAsStringSync(dumpContent);

  await tester.pumpWidget(App(nfcAdapter: mockAdapter, dataDir: dir,));
  await tester.tap(find.widgetWithText(Tab, "Dumps"));
  await tester.pumpAndSettle();
  await Future.delayed(Duration(seconds: 1));
  await tester.pumpAndSettle();
  await tester.ensureVisible(find.widgetWithText(OutlinedButton, "Write"));
  await tester.pumpAndSettle();
  await tester.tap(find.byType(DropdownMenu).first);
  await tester.pumpAndSettle();
  // The first found text is bugged
  await tester.tap(find.text(dumpContent.substring(0, 8)).at(1));
  await tester.pumpAndSettle();
  await tester.tap(find.widgetWithText(OutlinedButton, "Write"));
  await tester.pumpAndSettle();
  expect(find.widgetWithText(SnackBar, "Dump successfully written !"), findsOneWidget);

  // Content is OK
  expect(mockTag.data.map((block) => block.toHexString().toUpperCase()).join("\n"), equals(dumpContent));

  // Backup of previous UID is here
  expect(await File("${dir.path}/uid_save").exists(), equals(true));
  expect(File("${dir.path}/uid_save").readAsLinesSync().first, equals(newUid));

  // Cleanup
  File("${dir.path}/${dumpContent.substring(0, 8)}.dump").deleteSync();
}

Future<void> testWriteFromDumpFail(WidgetTester tester, MockNfcTag mockTag, String dumpContent) async{
  final mockAdapter = MockNfcAdapter();
  mockTag.setFailureBlockZero(true);
  mockAdapter.setTag(mockTag);

  // To compare with saved_uid
  final newUid = dumpContent.substring(0, 8);
      
  // Create the dump
  final dir = await getExternalStorageDirectory();
  File("${dir!.path}/${dumpContent.substring(0, 8)}.dump").writeAsStringSync(dumpContent);

  await tester.pumpWidget(App(nfcAdapter: mockAdapter, dataDir: dir,));
  await tester.tap(find.widgetWithText(Tab, "Dumps"));
  await tester.pumpAndSettle();
  await Future.delayed(Duration(seconds: 1));
  await tester.pumpAndSettle();
  await tester.ensureVisible(find.widgetWithText(OutlinedButton, "Write"));
  await tester.pumpAndSettle();
  await tester.tap(find.byType(DropdownMenu).first);
  await tester.pumpAndSettle();
  // The first found text is bugged
  await tester.tap(find.text(dumpContent.substring(0, 8)).at(1));
  await tester.pumpAndSettle();
  await tester.tap(find.widgetWithText(OutlinedButton, "Write"));
  await tester.pumpAndSettle();
  expect(find.widgetWithText(SnackBar, "Warning : Sector 0 write failed, tag is not a CUID one"), findsOneWidget);

  // Content is partially written
  // The first block will be different than the dump
  expect(mockTag.data.map((block) => block.toHexString().toUpperCase()).toList().sublist(1), equals(dumpContent.split("\n").sublist(1)));

  // Backup of previous UID is here
  expect(await File("${dir.path}/uid_save").exists(), equals(true));
  expect(File("${dir.path}/uid_save").readAsLinesSync().first, equals(newUid));

  // Cleanup
  File("${dir.path}/${dumpContent.substring(0, 8)}.dump").deleteSync();
}

Future<void> testReadDump(WidgetTester tester, MockNfcTag? mockTag, String dumpData) async{
  final mockAdapter = MockNfcAdapter();
  mockAdapter.setTag(mockTag);

  // Create the dump
  final dir = await getExternalStorageDirectory();
  File("${dir!.path}/${dumpData.substring(0, 8)}.dump").writeAsStringSync(dumpData);

  await tester.pumpWidget(App(nfcAdapter: mockAdapter, dataDir: dir,));
  await tester.tap(find.widgetWithText(Tab, "Dumps"));
  await tester.pumpAndSettle();
  await Future.delayed(Duration(seconds: 1));
  await tester.pumpAndSettle();
  await tester.ensureVisible(find.widgetWithText(OutlinedButton, "Read"));
  await tester.pumpAndSettle();
  await tester.tap(find.byType(DropdownMenu).last);
  await tester.pumpAndSettle();
  await tester.tap(find.text(dumpData.substring(0, 8)).last);
  await tester.pumpAndSettle();
  await tester.tap(find.widgetWithText(OutlinedButton, "Read"));
  await tester.pumpAndSettle();
  expect(find.byType(ReadDumpDialog), findsOne);
  await tester.tap(find.widgetWithText(OutlinedButton, "Close"));
  await tester.pumpAndSettle();
  expect(find.byType(ReadDumpDialog), findsNothing);

  // Cleanup
  File("${dir.path}/${dumpData.substring(0, 8)}.dump").deleteSync();

}

Future<void> testChangeUid(WidgetTester tester, MockNfcTag mockTag, String newUid, String expectedContent) async{
  final dir = await getExternalStorageDirectory();
  final mockAdapter = MockNfcAdapter();
  mockAdapter.setTag(mockTag);

  // To compare with saved_uid
  final newUid = expectedContent.substring(0, 8);

  await tester.pumpWidget(App(nfcAdapter: mockAdapter, dataDir: dir!,));
  await tester.tap(find.widgetWithText(Tab, "Advanced"));
  await tester.pumpAndSettle();
  await tester.enterText(find.byType(TextFormField).first, newUid);
  await tester.pumpAndSettle();
  await tester.ensureVisible(find.widgetWithText(OutlinedButton, "Ok").first);
  await tester.pumpAndSettle();
  await tester.tap(find.widgetWithText(OutlinedButton, "Ok").first);
  await tester.pumpAndSettle();
  expect(find.widgetWithText(SnackBar, "UID changed successfully"), findsOneWidget);
  await tester.pumpAndSettle();
  expect(mockTag.data.map((block) => block.toHexString().toUpperCase()).join("\n"), equals(expectedContent));

  // Backup of previous UID is here
  expect(await File("${dir.path}/uid_save").exists(), equals(true));
  expect(File("${dir.path}/uid_save").readAsLinesSync().first, equals(newUid));

}

Future<void> testChangeUidFail(WidgetTester tester, MockNfcTag mockTag, String newUid, String expectedContent) async{
  final dir = await getExternalStorageDirectory();
  final mockAdapter = MockNfcAdapter();
  mockTag.setFailureBlockZero(true);
  mockAdapter.setTag(mockTag);

  // To compare with saved_uid
  final newUid = expectedContent.substring(0, 8);

  await tester.pumpWidget(App(nfcAdapter: mockAdapter, dataDir: dir!,));
  await tester.tap(find.widgetWithText(Tab, "Advanced"));
  await tester.pumpAndSettle();
  await tester.enterText(find.byType(TextFormField).first, newUid);
  await tester.pumpAndSettle();
  await tester.ensureVisible(find.widgetWithText(OutlinedButton, "Ok").first);
  await tester.pumpAndSettle();
  await tester.tap(find.widgetWithText(OutlinedButton, "Ok").first);
  await tester.pumpAndSettle();
  expect(find.widgetWithText(SnackBar, "Warning : Sector 0 write failed, tag is not a CUID one"), findsOneWidget);
  await tester.pumpAndSettle();

  // Content is partially written
  // The first block will be different than the dump
  expect(mockTag.data.map((block) => block.toHexString().toUpperCase()).toList().sublist(1), equals(expectedContent.split("\n").sublist(1)));

  // Backup of previous UID is here
  expect(await File("${dir.path}/uid_save").exists(), equals(true));
  expect(File("${dir.path}/uid_save").readAsLinesSync().first, equals(newUid));

}