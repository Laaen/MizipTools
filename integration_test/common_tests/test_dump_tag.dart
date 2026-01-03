import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:miziptools/extensions/uint8list_extensions.dart';
import 'package:miziptools/main.dart';
import 'package:miziptools/widgets/dump/dump_tag.dart' show DumpTag;
import 'package:path_provider/path_provider.dart';
import '../mock_nfc_adapter.dart';
import '../mock_nfc_tag.dart';

Future<void> testDumpTagRemovedTag(WidgetTester tester, MockNfcTag mockTag) async{
  final mockAdapter = MockNfcAdapter();
  mockAdapter.setTag(mockTag);
  await commonDumpTagExec(tester, mockAdapter, "Communication error", disconnectTag: true);
}

Future<void> testDumpTagKeyError(WidgetTester tester, MockNfcTag mockTag) async{
  final mockAdapter = MockNfcAdapter();
  mockTag.setDenyAuthList([3]);
  mockAdapter.setTag(mockTag);
  await commonDumpTagExec(tester, mockAdapter, "Incorrect keys");
}

Future<void> testDumpTagSuccesful(WidgetTester tester, MockNfcTag mockTag) async{
  final mockAdapter = MockNfcAdapter();
  mockAdapter.setTag(mockTag);
  await commonDumpTagExec(tester, mockAdapter, "Dump done file : ${mockAdapter.currentTag!.getUid().toUpperCase()}.dump");
}

Future<void> commonDumpTagExec(WidgetTester tester, MockNfcAdapter mockAdapter, String expectedSnackBarMessage, {bool disconnectTag = false}) async{
  final dir = await getExternalStorageDirectory();
  await tester.pumpWidget(App(nfcAdapter: mockAdapter, dataDir: dir!,));
  await tester.tap(find.widgetWithText(Tab, "Dumps"));
  await tester.pumpAndSettle();
  if (disconnectTag){
    mockAdapter.setFailureMode(true);
  }
  await tester.tap(find.widgetWithText(DumpTag, "Dump Tag"));
  await tester.pumpAndSettle();
  expect(find.widgetWithText(SnackBar, expectedSnackBarMessage), findsOneWidget);
      
  // Only if the dump was supposed to be successful
    if (mockAdapter.currentTag!.denyAuthList.isEmpty && !disconnectTag){
    // File exists
    final file = dir.listSync().where((f) => f.path.split("/").last != "uid_save").last;
    expect(file.path.split("/").last, equals("${mockAdapter.currentTag!.getUid().toUpperCase()}.dump"));

    // Content is OK
    final expectedContent = mockAdapter.currentTag!.data.map((block) => block.toHexString().toUpperCase()).join("\n");
    final fileContent = File(file.path).readAsStringSync();
    expect(fileContent, equals(expectedContent));

    // Cleanup
    File(file.path).deleteSync();
  }
}
