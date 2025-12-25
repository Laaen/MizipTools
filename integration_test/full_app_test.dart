import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:miziptools/extensions/string_extensions.dart';
import 'package:miziptools/extensions/uint8list_extensions.dart';
import 'package:miziptools/main.dart';
import 'package:miziptools/nfc/nfc_tag.dart';
import 'package:miziptools/widgets/balance/tag_balance.dart';
import 'package:miziptools/widgets/advanced/change_uid.dart';
import 'package:miziptools/widgets/dump/dump_tag.dart';
import 'package:miziptools/widgets/balance/tag_add_10.dart';
import 'package:miziptools/widgets/common/tag_data.dart';
import 'package:miziptools/widgets/dump/write_from_dump.dart';
import 'package:path_provider/path_provider.dart';
import 'common_tests.dart';
import 'expected_tag_content.dart';
import 'mock_nfc_adapter.dart';
import 'mock_nfc_tag.dart';

void main(){
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  group("No tag tests", (){
    testWidgets("Start The app, and check displayed data in all menus", (tester) async {
      final dataDir = await getExternalStorageDirectory();
      await tester.pumpWidget(App(nfcAdapter: MockNfcAdapter(), dataDir: dataDir!,));
      await tester.pumpAndSettle();

      expect(find.widgetWithText(TagData, "No tag detected"), findsWidgets);
      
      await tester.tap(find.widgetWithText(Tab, "Dumps"));
      await tester.pumpAndSettle();
      expect(find.widgetWithText(TagData, "No tag detected"), findsWidgets);

      await tester.tap(find.widgetWithText(Tab, "Advanced"));
      await tester.pumpAndSettle();
      expect(find.widgetWithText(TagData, "No tag detected"), findsWidgets);
    });

    testWidgets("Test read dump", (tester) async {
      await testReadDump(tester, null, exampleDumpTestReadDump);
    });

  });

  group("MifareClassic tests", (){
    testWidgets("Start The app, and check displayed data in all menus", (tester) async {
      final dataDir = await getExternalStorageDirectory();
      final mockAdapter = MockNfcAdapter();
      final mockMifareClassicTag = generateMockMifareClassic();
      mockAdapter.setTag(mockMifareClassicTag);
      await tester.pumpWidget(App(nfcAdapter: mockAdapter, dataDir: dataDir!,));

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
      await testDumpTag(tester, generateMockMifareClassic());
    });

    testWidgets("Test write from dump", (tester) async {
      await testWriteFromDump(tester, generateMockMifareClassic(), dumpContentWriteFromDumpTest);
    });

    testWidgets("Test read dump", (tester) async {
      await testReadDump(tester, generateMockMifareClassic(), exampleDumpTestReadDump);
    });

    testWidgets("Test change UID", (tester) async {
      await testChangeUid(tester, generateMockMifareClassic(), "ABD453C7", expectedTagContentChangeUidTestMifareClassic);
    });

    testWidgets("Test auto-repair", (tester) async{
      final dataDir = await getExternalStorageDirectory();
      final mockAdapter = MockNfcAdapter();
      final mockMifareClassicTag = MockNfcTag(data: brokenTag.split("\n").map((x) => x.toUint8List()).toList(), type: NfcTagType.mifareClassic);
      mockAdapter.setTag(mockMifareClassicTag);

      final oldUid = "ABD453C7";

      await tester.pumpWidget(App(nfcAdapter: mockAdapter, dataDir: dataDir!,));

      await tester.tap(find.widgetWithText(Tab, "Advanced"));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextFormField).last, oldUid);
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(OutlinedButton, "Ok").last);
      await tester.pumpAndSettle();
      await Future.delayed(Duration(seconds: 3));
      expect(find.widgetWithText(SnackBar, "Repair successful"), findsOneWidget);
      await tester.pumpAndSettle();
      expect(mockMifareClassicTag.data.map((block) => block.toHexString().toUpperCase()).join("\n"), equals(expectedRepairedTag));

    });

  });

  group("MiZip tests", (){
    testWidgets("Start The app, and check displayed data in all menus", (tester) async {
      final dataDir = await getExternalStorageDirectory();
      final mockAdapter = MockNfcAdapter();
      final mockMizipTag = generateMockMizipTag();
      mockAdapter.setTag(mockMizipTag);

      await tester.pumpWidget(App(nfcAdapter: mockAdapter, dataDir: dataDir!,));

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
      final dataDir = await getExternalStorageDirectory();
      final mockAdapter = MockNfcAdapter();
      final mockMizipTag = generateMockMizipTag();
      mockAdapter.setTag(mockMizipTag);

      final newBalance = "26.92";
      await tester.pumpWidget(App(nfcAdapter: mockAdapter, dataDir: dataDir!,));
      await tester.tap(find.widgetWithText(Tab, "Balance"));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextFormField), newBalance);
      await tester.tap(find.widgetWithText(OutlinedButton, "Ok")); 
      await tester.pumpAndSettle();
      expect(find.widgetWithText(SnackBar, "Balance changed successfully"), findsOneWidget);
      expect(mockMizipTag.data.map((block) => block.toHexString().toUpperCase()).join("\n"), equals(expectedTagContentChangeBalanceTest));

    });

    testWidgets("Add 10\$", (tester) async{
      final dataDir = await getExternalStorageDirectory();
      final mockAdapter = MockNfcAdapter();
      final mockMizipTag = generateMockMizipTag();
      mockAdapter.setTag(mockMizipTag);

      await tester.pumpWidget(App(nfcAdapter: mockAdapter, dataDir: dataDir!,));
      await tester.tap(find.widgetWithText(Tab, "Balance"));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(OutlinedButton, "Add 10\$")); 
      await tester.pumpAndSettle();
      expect(find.widgetWithText(SnackBar, "Balance changed successfully"), findsOneWidget);
      expect(mockMizipTag.data.map((block) => block.toHexString().toUpperCase()).join("\n"), equals(expectedTagContentAddTenTest));

    });

    testWidgets("Test dump tag", (tester) async {
      await testDumpTag(tester, generateMockMizipTag());
    });

    testWidgets("Test write from dump", (tester) async {
      await testWriteFromDump(tester, generateMockMizipTag(), dumpContentWriteFromDumpTest);
    });

    testWidgets("Test read dump", (tester) async {
      await testReadDump(tester, generateMockMizipTag(), exampleDumpTestReadDump);
    });

    testWidgets("Test change UID", (tester) async {
      await testChangeUid(tester, generateMockMizipTag(), "ABD453C7", expectedTagCOntentChangeUidTestMizip);
    });

  });
}


MockNfcTag generateMockMifareClassic(){
  return MockNfcTag(type: NfcTagType.mifareClassic,
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
}

MockNfcTag generateMockMizipTag(){
  return MockNfcTag(type: NfcTagType.mifareClassic,
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
}