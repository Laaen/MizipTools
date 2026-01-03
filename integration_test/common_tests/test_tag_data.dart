import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:miziptools/main.dart';
import 'package:miziptools/widgets/advanced/auto_repair.dart';
import 'package:miziptools/widgets/advanced/change_uid.dart';
import 'package:miziptools/widgets/balance/tag_add_10.dart';
import 'package:miziptools/widgets/balance/tag_balance.dart';
import 'package:miziptools/widgets/common/tag_data.dart';
import 'package:miziptools/widgets/dump/dump_tag.dart';
import 'package:miziptools/widgets/dump/read_dump.dart';
import 'package:miziptools/widgets/dump/write_from_dump.dart';
import 'package:path_provider/path_provider.dart';
import '../mock/mock_nfc_adapter.dart';
import '../mock/mock_nfc_tag.dart';

typedef WidgetsToFind = ({List<Type> balance, List<Type> dumps, List<Type> advanced});

Future<void> testTagDataNoTag(WidgetTester tester, MockNfcTag? mockTag) async{
  final mockAdapter = MockNfcAdapter();
  mockAdapter.setTag(mockTag);

  await commonTagDataExec(tester, mockAdapter, (balance: List<Type>.empty(), dumps: [ReadDump], advanced: List<Type>.empty()), ["No tag detected"]);
}

Future<void> testTagDataMifareClassic(WidgetTester tester, MockNfcTag mockTag) async{
  final mockAdapter = MockNfcAdapter();
  mockAdapter.setTag(mockTag);

  await commonTagDataExec(tester, mockAdapter, (balance: List<Type>.empty(), dumps: [DumpTag, WriteFromDump, ReadDump], advanced: [ChangeUid, AutoRepair]), ["Not a MiZip tag (Mifare Classic Tag)"]);
}

Future<void> testTagDataMizip(WidgetTester tester, MockNfcTag mockTag) async{
  final mockAdapter = MockNfcAdapter();
  mockAdapter.setTag(mockTag);

  await commonTagDataExec(tester, mockAdapter, (balance: [TagAdd10, TagBalance], dumps: [DumpTag, WriteFromDump, ReadDump], advanced: [ChangeUid]), ["UID: ${mockTag.getUid().toUpperCase()}" ,"Balance: 36.92\$"]);
}

Future<void> commonTagDataExec(WidgetTester tester, MockNfcAdapter mockAdapter, WidgetsToFind expectedWidgetList, List<String> expectedShownData) async{
  final dataDir = await getExternalStorageDirectory();

  await tester.pumpWidget(App(nfcAdapter: mockAdapter, dataDir: dataDir!,));

  await checkTab(tester, "Balance", expectedWidgetList.balance, expectedShownData);
  await checkTab(tester, "Dumps", expectedWidgetList.dumps, expectedShownData);
  await checkTab(tester, "Advanced", expectedWidgetList.advanced, expectedShownData);
}

// Checks if displayed data are correct
Future<void> checkTab(WidgetTester tester, String tabName, List<Type> widgetsToFind, List<String> tagDataContent) async{
  
  await tester.tap(find.widgetWithText(Tab, tabName));
  await tester.pumpAndSettle();

  // Check displayed data
  for(final data in tagDataContent){
     expect(find.widgetWithText(TagData, data), findsWidgets);
  }

  // Check present widgets
  for(final widget in widgetsToFind){
    expect(find.byType(widget), findsOneWidget);
  }
}