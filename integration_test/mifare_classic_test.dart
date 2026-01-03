import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:miziptools/extensions/string_extensions.dart';
import 'package:miziptools/nfc/nfc_tag.dart';
import 'common_tests/test_auto_repair.dart';
import 'common_tests/test_change_uid.dart';
import 'common_tests/test_dump_tag.dart';
import 'common_tests/test_read_dump.dart';
import 'common_tests/test_tag_data.dart';
import 'common_tests/test_write_from_dump.dart';
import 'mock/mock_nfc_tag.dart';

void main (){
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group("MifareClassic tests", (){

    group("Tag Data", (){
      testWidgets("Check displayed data in all menus", (tester) async {
        await testTagDataMifareClassic(tester, generateMockMifareClassic());
      });
    });

    group("Dump", (){
      testWidgets("Dump tag success", (tester) async {
        await testDumpTagSuccess(tester, generateMockMifareClassic());
      });

      testWidgets("Dump tag wrong key", (tester) async{
        await testDumpTagWrongKey(tester, generateMockMifareClassic());
      });

      testWidgets("Dump tag removed", (tester) async{
        await testDumpTagRemovedTag(tester, generateMockMifareClassic());
      });

      testWidgets("Write dump", (tester) async {
        await testWriteFromDumpSuccess(tester, generateMockMifareClassic());
      });

      testWidgets("Write dump not CUID", (tester) async {
        await testWriteFromDumpBlockZeroFail(tester, generateMockMifareClassic());
      });

      testWidgets("Write dump wrong key", (tester) async {
        await testWriteFromDumpWrongKey(tester, generateMockMifareClassic());
      });

      testWidgets("Write dump removed tag", (tester) async {
        await testWriteFromDumpTagLost(tester, generateMockMifareClassic());
      });

      testWidgets("Read dump success", (tester) async {
        await testReadDumpSuccess(tester, generateMockMifareClassic(), exampleDumpTestReadDump);
      });
    });

    group("Advanced", (){
      testWidgets("Change UID success", (tester) async {
        await testChangeUid(tester, generateMockMifareClassic(), "ABD453C7", expectedTagContentChangeUidTestMifareClassicSuccess);
      });

      testWidgets("Change UID not CUID", (tester) async {
        await testChangeUidNotCUID(tester, generateMockMifareClassic(), "ABD453C7", expectedTagContentChangeUidTestMifareClassicNotCUID);
      });

      testWidgets("Change UID wrong key", (tester) async {
        await testChangeUidWrongKey(tester, generateMockMifareClassic(), "ABD453C7", "");
      });

      testWidgets("Change UID tag removed", (tester) async {
        await testChangeUidTagRemoved(tester, generateMockMifareClassic(), "ABD453C7", "");
      });

      testWidgets("Auto-repair success", (tester) async{
        await testAutoRepairSuccess(tester, generateBrokenTag());
      });

      testWidgets("Auto-repair wrong key", (tester) async{
        await testAutoRepairWrongKey(tester, generateBrokenTag());
      });

      testWidgets("Auto-repair tag removed", (tester) async{
        await testAutoRepairTagRemoved(tester, generateBrokenTag());
      });
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

/// Returns a tag with mismatching UID and keys
/// Some key match the UID, and some other match another UID 
MockNfcTag generateBrokenTag(){
    return MockNfcTag(type: NfcTagType.mifareClassic,
    data: [
      "ED711B74F3890400C808002000000017".toUint8List(),
      "6200488849884A884B88000000000000".toUint8List(),
      "00000000000000000000000000000000".toUint8List(),
      "A0A1A2A3A4A5787788C1B4C123439EEF".toUint8List(),
      "0E43004E61BC80010001000000005E02".toUint8List(),
      "01000001000080010001000000008001".toUint8List(),
      "AA020000000000000000000000000000".toUint8List(),
      "A2C609E2223178778803A2EB2F878BE6".toUint8List(),
      "00A90AA3000000000000000000000006".toUint8List(),
      "006C0E62000000000000000000000007".toUint8List(),
      "55070000000000000000000000000000".toUint8List(),
      "00A19AF039FB787788122020322A6186".toUint8List(),
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