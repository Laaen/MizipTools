import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:miziptools/extensions/uint8list_extensions.dart';
import 'package:miziptools/main.dart';
import 'package:path_provider/path_provider.dart';
import '../mock_nfc_adapter.dart';
import '../mock_nfc_tag.dart';

Future<void> testAutoRepair(WidgetTester tester, MockNfcTag mockTag) async{
  final mockAdapter = MockNfcAdapter();
  mockAdapter.setTag(mockTag);

  await commonAutoRepairExec(tester, mockAdapter, "Repair successful", expectedAutoRepairSuccess);

}

Future<void> commonAutoRepairExec(WidgetTester tester, MockNfcAdapter mockAdapter, String expectedSnackBarMessage, String expectedResult) async{
      final dataDir = await getExternalStorageDirectory();

      // The UID which should be in save_uid
      final oldUid = "ABD453C7";

      await tester.pumpWidget(App(nfcAdapter: mockAdapter, dataDir: dataDir!,));

      await tester.tap(find.widgetWithText(Tab, "Advanced"));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextFormField).last, oldUid);
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.widgetWithText(OutlinedButton, "Ok").last);
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(OutlinedButton, "Ok").last);
      await tester.pumpAndSettle();
      await Future.delayed(Duration(seconds: 3));
      expect(find.widgetWithText(SnackBar, expectedSnackBarMessage), findsOneWidget);
      await tester.pumpAndSettle();

      // Wait for tag poll after release
      Future.delayed(Duration(seconds: 1));

      expect(mockAdapter.currentTag!.data.map((block) => block.toHexString().toUpperCase()).join("\n"), equals(expectedResult));
}

const expectedAutoRepairSuccess = """ED711B74F3890400C808002000000017
6200488849884A884B88000000000000
00000000000000000000000000000000
A0A1A2A3A4A5787788C1B4C123439EEF
0E43004E61BC80010001000000005E02
01000001000080010001000000008001
AA020000000000000000000000000000
E4634151649478778803EA586922C355
00A90AA3000000000000000000000006
006C0E62000000000000000000000007
55070000000000000000000000000000
4604D2437F5E787788126893748F2935
00000000000000000000000000000000
00000000000000000000000000000001
55010000000000000000000000000000
0F035ADBC17878778800B139FE074DDA
00000000000000000000000000000000
00000000000000000000000000000001
55010000000000000000000000000000
DC0BAC5BA9E178778800AB67CA563689""";