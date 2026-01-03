
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:miziptools/extensions/uint8list_extensions.dart';
import 'package:miziptools/main.dart';
import 'package:path_provider/path_provider.dart';
import '../mock_nfc_adapter.dart';
import '../mock_nfc_tag.dart';

Future<void> testChangeBalanceSuccess(WidgetTester tester, MockNfcTag mockTag, String newBalance) async{
  final mockAdapter = MockNfcAdapter();
  mockAdapter.setTag(mockTag);
  await commonChangeBalanceExec(tester, mockAdapter, newBalance, "Balance changed successfully", expectedTagContentChangeBalanceTest);
}

Future<void> testChangeBalanceTagRemoved(WidgetTester tester, MockNfcTag mockTag, String newBalance) async{
  final mockAdapter = MockNfcAdapter();
  mockAdapter.setTag(mockTag);

  // Nothing should be changed
  final expectedResult = mockTag.data.map((block) => block.toHexString().toUpperCase()).join("\n");
  await commonChangeBalanceExec(tester, mockAdapter, newBalance, "Communication error", expectedResult, disconnectTag: true);
}

Future<void> commonChangeBalanceExec(WidgetTester tester, MockNfcAdapter mockAdapter, String newBalance, String expectedSnackBarMessage, String expectedResult, {bool disconnectTag = false}) async{
  final dataDir = await getExternalStorageDirectory();

  await tester.pumpWidget(App(nfcAdapter: mockAdapter, dataDir: dataDir!,));
  await tester.tap(find.widgetWithText(Tab, "Balance"));
  await tester.pumpAndSettle();
  await tester.enterText(find.byType(TextFormField), newBalance);
  if (disconnectTag){
    mockAdapter.setFailureMode(true);
  }
  await tester.tap(find.widgetWithText(OutlinedButton, "Ok")); 
  await tester.pumpAndSettle();
  expect(find.widgetWithText(SnackBar, expectedSnackBarMessage), findsOneWidget);
  expect(mockAdapter.currentTag!.data.map((block) => block.toHexString().toUpperCase()).join("\n"), equals(expectedResult));
}

const expectedTagContentChangeBalanceTest = """ED711B74F3890400C808002000000017
6200488849884A884B88000000000000
00000000000000000000000000000000
A0A1A2A3A4A5787788C1B4C123439EEF
0E43004E61BC80010001000000005E02
01000001000080010001000000008001
AA020000000000000000000000000000
E4634151649478778803EA586922C355
00A90AA3000000000000000000000006
00840A8E000000000000000000000007
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