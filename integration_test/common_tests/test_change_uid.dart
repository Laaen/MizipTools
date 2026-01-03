import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:miziptools/extensions/uint8list_extensions.dart';
import 'package:miziptools/main.dart';
import 'package:path_provider/path_provider.dart';
import '../mock/mock_nfc_adapter.dart';
import '../mock/mock_nfc_tag.dart';

Future<void> testChangeUid(WidgetTester tester, MockNfcTag mockTag, String newUid, String expectedResult) async{
  final mockAdapter = MockNfcAdapter();
  mockAdapter.setTag(mockTag);
  await commonChangeUidExec(tester, mockAdapter, newUid, "UID changed successfully", expectedResult);
}

Future<void> testChangeUidNotCUID(WidgetTester tester, MockNfcTag mockTag, String newUid, String expectedResult) async{
  final mockAdapter = MockNfcAdapter();
  mockTag.setFailureBlockZero(true);
  mockAdapter.setTag(mockTag);
  await commonChangeUidExec(tester, mockAdapter, newUid, "Warning : Sector 0 write failed, tag is not a CUID one", expectedResult);
}

Future<void> testChangeUidWrongKey(WidgetTester tester, MockNfcTag mockTag, String newUid, String expectedResult) async{
  final mockAdapter = MockNfcAdapter();
  mockTag.setDenyAuthList([1]);
  mockAdapter.setTag(mockTag);

  // Nothing changed
  final expectedResult = mockTag.data.map((block) => block.toHexString().toUpperCase()).join("\n");
  await commonChangeUidExec(tester, mockAdapter, newUid, "Incorrect keys", expectedResult);
}

Future<void> testChangeUidTagRemoved(WidgetTester tester, MockNfcTag mockTag, String newUid, String expectedResult) async{
  final mockAdapter = MockNfcAdapter();
  mockAdapter.setTag(mockTag);

  // Nothing changed
  final expectedResult = mockTag.data.map((block) => block.toHexString().toUpperCase()).join("\n");
  await commonChangeUidExec(tester, mockAdapter, newUid, "Communication error", expectedResult, disconnectTag: true);
}

Future<void> commonChangeUidExec(WidgetTester tester, MockNfcAdapter mockAdapter, String newUid, String expectedSnackBarMessage, String expectedResult, {bool disconnectTag = false}) async{
  final dir = await getExternalStorageDirectory();

  await tester.pumpWidget(App(nfcAdapter: mockAdapter, dataDir: dir!,));
  await tester.tap(find.widgetWithText(Tab, "Advanced"));
  await tester.pumpAndSettle();
  await tester.enterText(find.byType(TextFormField).first, newUid);
  await tester.pumpAndSettle();
  await tester.ensureVisible(find.widgetWithText(OutlinedButton, "Ok").first);
  await tester.pumpAndSettle();
  if (disconnectTag){
    mockAdapter.setTagRemoved(true);
  }
  await tester.tap(find.widgetWithText(OutlinedButton, "Ok").first);
  await tester.pumpAndSettle();
  expect(find.widgetWithText(SnackBar, expectedSnackBarMessage), findsOneWidget);

  // Wait for tag to be rediscovered if change is successful
  await Future.delayed(Duration(seconds: 1));

  expect(mockAdapter.currentTag!.data.map((block) => block.toHexString().toUpperCase()).join("\n"), equals(expectedResult));

  // Backup of previous UID is here
  expect(await File("${dir.path}/uid_save").exists(), equals(true));
  expect(File("${dir.path}/uid_save").readAsLinesSync().first, equals(newUid));
}

const expectedTagContentChangeUidTestMifareClassicSuccess = """ABD453C7EB890400C808002000000017
6200488849884A884B88000000000000
00000000000000000000000000000000
FFFFFFFFFFFF78778800FFFFFFFFFFFF
0E43004E61BC80010001000000005E02
01000001000080010001000000008001
AA020000000000000000000000000000
FFFFFFFFFFFF78778800FFFFFFFFFFFF
00A90AA3000000000000000000000006
006C0E62000000000000000000000007
55070000000000000000000000000000
FFFFFFFFFFFF78778800FFFFFFFFFFFF
00000000000000000000000000000000
00000000000000000000000000000001
55010000000000000000000000000000
FFFFFFFFFFFF78778800FFFFFFFFFFFF
00000000000000000000000000000000
00000000000000000000000000000001
55010000000000000000000000000000
FFFFFFFFFFFF78778800FFFFFFFFFFFF""";

const expectedTagContentChangeUidTestMifareClassicNotCUID = """ED711B74F3890400C808002000000017
6200488849884A884B88000000000000
00000000000000000000000000000000
FFFFFFFFFFFF78778800FFFFFFFFFFFF
0E43004E61BC80010001000000005E02
01000001000080010001000000008001
AA020000000000000000000000000000
FFFFFFFFFFFF78778800FFFFFFFFFFFF
00A90AA3000000000000000000000006
006C0E62000000000000000000000007
55070000000000000000000000000000
FFFFFFFFFFFF78778800FFFFFFFFFFFF
00000000000000000000000000000000
00000000000000000000000000000001
55010000000000000000000000000000
FFFFFFFFFFFF78778800FFFFFFFFFFFF
00000000000000000000000000000000
00000000000000000000000000000001
55010000000000000000000000000000
FFFFFFFFFFFF78778800FFFFFFFFFFFF""";

const expectedTagContentChangeUidTestMizipSuccess = """ABD453C7EB890400C808002000000017
6200488849884A884B88000000000000
00000000000000000000000000000000
A0A1A2A3A4A5787788C1B4C123439EEF
0E43004E61BC80010001000000005E02
01000001000080010001000000008001
AA020000000000000000000000000000
A2C609E2223178778803A2EB2F878BE6
00A90AA3000000000000000000000006
006C0E62000000000000000000000007
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

const expectedTagContentChangeUidTestMizipNotCUID = """ED711B74F3890400C808002000000017
6200488849884A884B88000000000000
00000000000000000000000000000000
A0A1A2A3A4A5787788C1B4C123439EEF
0E43004E61BC80010001000000005E02
01000001000080010001000000008001
AA020000000000000000000000000000
A2C609E2223178778803A2EB2F878BE6
00A90AA3000000000000000000000006
006C0E62000000000000000000000007
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