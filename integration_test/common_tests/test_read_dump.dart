import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:miziptools/main.dart';
import 'package:miziptools/widgets/dump/dialog_read_dump.dart';
import 'package:path_provider/path_provider.dart';
import '../mock/mock_nfc_adapter.dart';
import '../mock/mock_nfc_tag.dart';

// TODO : Add test for error message if no file selected

Future<void> testReadDumpSuccess(WidgetTester tester, MockNfcTag? mockTag, String dumpData) async{
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
  await Future.delayed(Duration(milliseconds: 100));
  expect(find.byType(ReadDumpDialog), findsOne);
  await tester.tap(find.widgetWithText(OutlinedButton, "Close"));
  await tester.pumpAndSettle();
  await Future.delayed(Duration(milliseconds: 100));
  expect(find.byType(ReadDumpDialog), findsNothing);

  // Cleanup
  File("${dir.path}/${dumpData.substring(0, 8)}.dump").deleteSync();

}

const exampleDumpTestReadDump = """ABD453C7EB890400C808002000000017
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
