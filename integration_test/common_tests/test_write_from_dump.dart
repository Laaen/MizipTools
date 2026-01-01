import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:miziptools/extensions/uint8list_extensions.dart';
import 'package:miziptools/main.dart';
import 'package:path_provider/path_provider.dart';
import '../mock_nfc_adapter.dart';
import '../mock_nfc_tag.dart';

// TODO : Add test write to tag with incorrect key

Future<void> testWriteFromDumpSuccesful(WidgetTester tester, MockNfcTag mockTag) async{
  final mockAdapter = MockNfcAdapter();
  mockAdapter.setTag(mockTag);

  await commonWriteFromDumpExec(tester, mockAdapter, dumpContentWriteFromDumpTest, "Dump successfully written !", expectedContentWriteDumpSuccessful);
}

Future<void> testWriteFromDumpBlockZeroFail(WidgetTester tester, MockNfcTag mockTag) async{
  final mockAdapter = MockNfcAdapter();
  mockTag.setFailureBlockZero(true);
  mockAdapter.setTag(mockTag);

  // Same as dumpContent, but block 0 unchanged
  final expectedResult = "${mockTag.data.first.toHexString()}\n${dumpContentWriteFromDumpTest.split("\n").sublist(1).join("\n")}"; 
  await commonWriteFromDumpExec(tester, mockAdapter, dumpContentWriteFromDumpTest, "Warning : Sector 0 write failed, tag is not a CUID one", expectedResult.toUpperCase());
}

/*
Future<void> testWriteFromDumpKeyFail(WidgetTester tester, MockNfcTag mockTag) async{
  final mockAdapter = MockNfcAdapter();
  mockTag.setFailureBlockZero(true);
  mockAdapter.setTag(mockTag);

  await commonWriteFromDumpExec(tester, mockAdapter, dumpContentWriteFromDumpTest, "Warning : Sector 0 write failed, tag is not a CUID one", dumpContentWriteFromDumpTest);
}
*/

Future<void> commonWriteFromDumpExec(WidgetTester tester, MockNfcAdapter mockAdapter, String dumpContent, String expectedSnackBarMessage, String expectedTagContent) async{  
  final dir = await getExternalStorageDirectory();
  final newUid = dumpContent.substring(0, 8);

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
  expect(find.widgetWithText(SnackBar, expectedSnackBarMessage), findsOneWidget);

  // Wait for tag to be rediscovered if write was successful
  await Future.delayed(Duration(seconds: 1));

  // Content is OK
  expect(mockAdapter.currentTag!.data.map((block) => block.toHexString().toUpperCase()).join("\n"), equals(expectedTagContent));

  // Backup of previous UID is here
  expect(await File("${dir.path}/uid_save").exists(), equals(true));
  expect(File("${dir.path}/uid_save").readAsLinesSync().first, equals(newUid));

  // Cleanup
  File("${dir.path}/${dumpContent.substring(0, 8)}.dump").deleteSync();
}

const dumpContentWriteFromDumpTest = """ABD453C7EB890400C808002000000017
6200488849884A884B88000000000000
00000000000000000000000000000000
A0A1A2A3A4A5787788C1B4C123439EEF
0E43004E61BC80010001000000005E02
01000001000080010001000000008001
AA020000000000000000000000000000
A2C609E2223178778803A2EB2F878BE6
00A90AA3000000000000000000000006
00840A8E000000000000000000000007
55070000000000000000000000000000
00A19AF039FB787788122020322A6186
00000000000000000000000000000000
00000000000000000000000000000001
55010000000000000000000000000000
49A6126887DD78778800F98AB8A20569
00000000000000000000000000000000
00000000000000000000000000000001
55010000000000000000000000000000
9AAEE4E8EF4478778800E3D48CF37E3A""";

const expectedContentWriteDumpSuccessful = dumpContentWriteFromDumpTest;