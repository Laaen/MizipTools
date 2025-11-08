import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:miziptools/extensions/string_extensions.dart';
import 'package:miziptools/extensions/uint8list_extensions.dart';
import 'package:miziptools/main.dart';
import 'package:miziptools/nfc/nfc_tag.dart';
import 'package:miziptools/widgets/tag_balance.dart';
import 'package:miziptools/widgets/change_uid.dart';
import 'package:miziptools/widgets/dump_tag.dart';
import 'package:miziptools/widgets/tag_add_10.dart';
import 'package:miziptools/widgets/tag_data.dart';
import 'package:miziptools/widgets/write_from_dump.dart';
import 'package:path_provider/path_provider.dart';
import 'dump_content.dart';
import 'mock_nfc_adapter.dart';
import 'mock_nfc_tag.dart';

void main(){
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  group("No tag tests", (){
    testWidgets("Start The app, and check displayed data in all menus", (tester) async {
      await tester.pumpWidget(App(nfcAdapter: MockNfcAdapter()));
      await tester.pumpAndSettle();

      expect(find.widgetWithText(TagData, "No tag detected"), findsWidgets);
      
      await tester.tap(find.widgetWithText(Tab, "Dumps"));
      await tester.pumpAndSettle();
      expect(find.widgetWithText(TagData, "No tag detected"), findsWidgets);

      await tester.tap(find.widgetWithText(Tab, "Advanced"));
      await tester.pumpAndSettle();
      expect(find.widgetWithText(TagData, "No tag detected"), findsWidgets);
    });
  });

  group("MifareClassic tests", (){

      final mockAdapter = MockNfcAdapter();
      final mockMifareClassicTag = MockNfcTag(type: NfcTagType.mifareClassic,
        data: [
          "ED711B74F3890400C808002000000017".toUint8List(),
          "6200488849884A884B88000000000000".toUint8List(),
          "00000000000000000000000000000000".toUint8List(),
          "FFFFFFFFFFFF78778800FFFFFFFFFFFF".toUint8List(),
          "0E43004E61BC80010001000000005E02".toUint8List(),
          "01000001000080010001000000008001".toUint8List(),
          "AA020000000000000000000000000000".toUint8List(),
          "FFFFFFFFFFFF78778800FFFFFFFFFFFF".toUint8List(),
          "00A90AA3000000000000000000000006".toUint8List(),
          "006C0E62000000000000000000000007".toUint8List(),
          "55070000000000000000000000000000".toUint8List(),
          "FFFFFFFFFFFF78778800FFFFFFFFFFFF".toUint8List(),
          "00000000000000000000000000000000".toUint8List(),
          "00000000000000000000000000000001".toUint8List(),
          "55010000000000000000000000000000".toUint8List(),
          "FFFFFFFFFFFF78778800FFFFFFFFFFFF".toUint8List(),
          "00000000000000000000000000000000".toUint8List(),
          "00000000000000000000000000000001".toUint8List(),
          "55010000000000000000000000000000".toUint8List(),
          "FFFFFFFFFFFF78778800FFFFFFFFFFFF".toUint8List(),
        ] 
      );
      mockAdapter.setTag(mockMifareClassicTag);

    testWidgets("Start The app, and check displayed data in all menus", (tester) async {

      await tester.pumpWidget(App(nfcAdapter: mockAdapter));

      await tester.tap(find.widgetWithText(Tab, "Balance"));
      await tester.pumpAndSettle();
      expect(find.widgetWithText(TagData, "Not a MiZip tag (Mifare Classic Tag)"), findsWidgets);
      
      await tester.tap(find.widgetWithText(Tab, "Dumps"));
      await tester.pumpAndSettle();
      expect(find.widgetWithText(TagData, "Not a MiZip tag (Mifare Classic Tag)"), findsWidgets);
      expect(find.byType(DumpTag), findsOneWidget);
      expect(find.byType(WriteFromDump), findsOneWidget);

      await tester.tap(find.widgetWithText(Tab, "Advanced"));
      await tester.pumpAndSettle();
      expect(find.widgetWithText(TagData, "Not a MiZip tag (Mifare Classic Tag)"), findsWidgets);
      expect(find.byType(ChangeUid), findsOneWidget);
    });

    testWidgets("Test dump tag", (tester) async {
      await tester.pumpWidget(App(nfcAdapter: mockAdapter));
      await tester.tap(find.widgetWithText(Tab, "Dumps"));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(DumpTag, "Dump Tag"));
      await tester.pumpAndSettle();
      expect(find.widgetWithText(SnackBar, "Dump done file : ${mockMifareClassicTag.getUid().toUpperCase()}.dump"), findsOneWidget);
      
      // File exists
      final dir = await getExternalStorageDirectory();
      final file = dir!.listSync().first;
      expect(file.path.split("/").last, equals("${mockMifareClassicTag.getUid().toUpperCase()}.dump"));

      // Content is OK
      final expectedContent = mockMifareClassicTag.data.map((block) => block.toHexString().toUpperCase()).join("\n");
      final fileContent = File(file.path).readAsStringSync();
      expect(fileContent, equals(expectedContent));
    });

    testWidgets("Test write from dump", (tester) async {
      
      // Create the dump
      final dir = await getExternalStorageDirectory();
      File("${dir!.path}/ABD453C7.dump").writeAsStringSync(dumpContentWriteFromDumpTest);

      await tester.pumpWidget(App(nfcAdapter: mockAdapter));
      await tester.tap(find.widgetWithText(Tab, "Dumps"));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(DropdownMenu));
      await tester.pumpAndSettle();
      await tester.tap(find.text("${dir.path}/ABD453C7.dump").last);
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(OutlinedButton, "Write"));
      await tester.pumpAndSettle();
      expect(find.widgetWithText(SnackBar, "Dump successfully written !"), findsOneWidget);

      // Content is OK
      expect(mockMifareClassicTag.data.map((block) => block.toHexString().toUpperCase()).join("\n"), equals(dumpContentWriteFromDumpTest));
    });

    testWidgets("Test change UID", (tester) async {
      final newUid = "ABD453C7";
      await tester.pumpWidget(App(nfcAdapter: mockAdapter));
      await tester.tap(find.widgetWithText(Tab, "Advanced"));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextFormField), newUid);
      await tester.tap(find.widgetWithText(OutlinedButton, "Ok"));
      await tester.pumpAndSettle();
      expect(find.widgetWithText(SnackBar, "UID changed successfully"), findsOneWidget);
      expect(mockMifareClassicTag.data.map((block) => block.toHexString().toUpperCase()).join("\n"), equals(expectedTagContentChangeUidTestMifareClassic));
    });
  });

  group("MiZip tests", (){
    final mockAdapter = MockNfcAdapter();
    final mockMizipTag = MockNfcTag(type: NfcTagType.mifareClassic,
      data: [
        "ED711B74F3890400C808002000000017".toUint8List(),
        "6200488849884A884B88000000000000".toUint8List(),
        "00000000000000000000000000000000".toUint8List(),
        "A0A1A2A3A4A5787788C1B4C123439EEF".toUint8List(),
        "0E43004E61BC80010001000000005E02".toUint8List(),
        "01000001000080010001000000008001".toUint8List(),
        "AA020000000000000000000000000000".toUint8List(),
        "E4634151649478778803EA586922C355".toUint8List(),
        "00A90AA3000000000000000000000006".toUint8List(),
        "006C0E62000000000000000000000007".toUint8List(),
        "55070000000000000000000000000000".toUint8List(),
        "4604D2437F5E787788126893748F2935".toUint8List(),
        "00000000000000000000000000000000".toUint8List(),
        "00000000000000000000000000000001".toUint8List(),
        "55010000000000000000000000000000".toUint8List(),
        "0F035ADBC17878778800B139FE074DDA".toUint8List(),
        "00000000000000000000000000000000".toUint8List(),
        "00000000000000000000000000000001".toUint8List(),
        "55010000000000000000000000000000".toUint8List(),
        "DC0BAC5BA9E178778800AB67CA563689".toUint8List(),
      ] 
    );
    mockAdapter.setTag(mockMizipTag);

    testWidgets("Start The app, and check displayed data in all menus", (tester) async {

      await tester.pumpWidget(App(nfcAdapter: mockAdapter));

      await tester.tap(find.widgetWithText(Tab, "Balance"));
      await tester.pumpAndSettle();
      expect(find.widgetWithText(TagData, "UID: ${mockMizipTag.getUid().toUpperCase()}"), findsWidgets);
      expect(find.widgetWithText(TagData, "Balance: 36.92\$"), findsWidgets);
      expect(find.byType(TagBalance), findsOneWidget);
      expect(find.byType(TagAdd10), findsOneWidget);
      
      await tester.tap(find.widgetWithText(Tab, "Dumps"));
      await tester.pumpAndSettle();
      expect(find.widgetWithText(TagData, "UID: ${mockMizipTag.getUid().toUpperCase()}"), findsWidgets);
      expect(find.widgetWithText(TagData, "Balance: 36.92\$"), findsWidgets);
      expect(find.byType(DumpTag), findsOneWidget);
      expect(find.byType(WriteFromDump), findsOneWidget);

      await tester.tap(find.widgetWithText(Tab, "Advanced"));
      await tester.pumpAndSettle();
      expect(find.widgetWithText(TagData, "UID: ${mockMizipTag.getUid().toUpperCase()}"), findsWidgets);
      expect(find.widgetWithText(TagData, "Balance: 36.92\$"), findsWidgets);
      expect(find.byType(ChangeUid), findsOneWidget);
    });

    testWidgets("Change balance", (tester) async{
      final newBalance = "26.92";
      await tester.pumpWidget(App(nfcAdapter: mockAdapter));
      await tester.tap(find.widgetWithText(Tab, "Balance"));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextFormField), newBalance);
      await tester.tap(find.widgetWithText(OutlinedButton, "Ok")); 
      await tester.pumpAndSettle();
      expect(find.widgetWithText(SnackBar, "Balance changed successfully"), findsOneWidget);
      expect(mockMizipTag.data.map((block) => block.toHexString().toUpperCase()).join("\n"), equals(expectedTagContentChangeBalanceTest));

    });
  });
}