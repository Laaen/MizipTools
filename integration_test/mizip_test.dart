import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:miziptools/extensions/string_extensions.dart';
import 'package:miziptools/nfc/nfc_tag.dart';
import 'common_tests/test_add_10.dart';
import 'common_tests/test_change_balance.dart';
import 'common_tests/test_change_uid.dart';
import 'common_tests/test_dump_tag.dart';
import 'common_tests/test_read_dump.dart';
import 'common_tests/test_tag_data.dart';
import 'common_tests/test_write_from_dump.dart';
import 'mock/mock_nfc_tag.dart';

void main(){
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  group("MiZip tests", (){
    group("Tag Data", (){
      testWidgets("Check displayed data in all menus", (tester) async {
        await testTagDataMizip(tester, generateMockMizipTag());
      });
    });

    group("Balance", (){
      testWidgets("Change balance success", (tester) async{
        await testChangeBalanceSuccess(tester, generateMockMizipTag(), "26.92");
      });

      testWidgets("Change balance tag removed", (tester) async{
        await testChangeBalanceTagRemoved(tester, generateMockMizipTag(), "26.92");
      });

      testWidgets("Add 10\$ success", (tester) async{
        await testAdd10Success(tester, generateMockMizipTag());
      });

      testWidgets("Add 10\$ tag removed", (tester) async{
        await testAdd10TagRemoved(tester, generateMockMizipTag());
      });
    });

    group("Dump", (){
      testWidgets("Dump tag success", (tester) async {
        await testDumpTagSuccess(tester, generateMockMizipTag());
      });

      testWidgets("Dump tag wrong key", (tester) async{
        await testDumpTagWrongKey(tester, generateMockMizipTag());
      });

      testWidgets("Write dump success", (tester) async {
        await testWriteFromDumpSuccess(tester, generateMockMizipTag());
      });

      testWidgets("Write dump not CUID", (tester) async {
        await testWriteFromDumpBlockZeroFail(tester, generateMockMizipTag());
      });

      testWidgets("Write dump wrong key", (tester) async {
        await testWriteFromDumpWrongKey(tester, generateMockMizipTag());
      });

      testWidgets("Write dump tag removed", (tester) async {
        await testWriteFromDumpTagLost(tester, generateMockMizipTag());
      });

      testWidgets("Read dump success", (tester) async {
        await testReadDumpSuccess(tester, generateMockMizipTag(), exampleDumpTestReadDump);
      });

    });

    group("Advanced", (){
      testWidgets("Change UID success", (tester) async {
        await testChangeUid(tester, generateMockMizipTag(), "ABD453C7", expectedTagContentChangeUidTestMizipSuccess);
      });

      testWidgets("Change UID not CUID", (tester) async {
        await testChangeUidNotCUID(tester, generateMockMizipTag(), "ABD453C7", expectedTagContentChangeUidTestMizipNotCUID);
      });

      testWidgets("Change UID wrong key", (tester) async {
        await testChangeUidWrongKey(tester, generateMockMizipTag(), "ABD453C7", "");
      });

      testWidgets("Change UID tag removed", (tester) async {
        await testChangeUidTagRemoved(tester, generateMockMizipTag(), "ABD453C7", "");
      });
    });
  });
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

