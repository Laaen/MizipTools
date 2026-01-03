import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:miziptools/extensions/string_extensions.dart';
import 'package:miziptools/nfc/nfc_tag.dart';
import 'common_tests/test_add_10.dart';
import 'common_tests/test_auto_repair.dart';
import 'common_tests/test_change_balance.dart';
import 'common_tests/test_change_uid.dart';
import 'common_tests/test_dump_tag.dart';
import 'common_tests/test_read_dump.dart';
import 'common_tests/test_tag_data.dart';
import 'common_tests/test_write_from_dump.dart';
import 'mock_nfc_tag.dart';

void main(){
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  group("No tag tests", (){
    testWidgets("Start The app, and check displayed data in all menus", (tester) async {
      await testTagDataNoTag(tester, null);
    });

    testWidgets("Test read dump", (tester) async {
      await testReadDumpSuccessful(tester, null, exampleDumpTestReadDump);
    });

  });

  group("MifareClassic tests", (){
    testWidgets("Start The app, and check displayed data in all menus", (tester) async {
      await testTagDataMifareClassic(tester, generateMockMifareClassic());
    });

    testWidgets("Test dump tag success", (tester) async {
      await testDumpTagSuccesful(tester, generateMockMifareClassic());
    });

    testWidgets("Test dump tag incorrect keys", (tester) async{
      await testDumpTagKeyError(tester, generateMockMifareClassic());
    });

    testWidgets("Test dump tag disconnect", (tester) async{
      await testDumpTagRemovedTag(tester, generateMockMifareClassic());
    });

    testWidgets("Test write from dump", (tester) async {
      await testWriteFromDumpSuccesful(tester, generateMockMifareClassic());
    });

    testWidgets("Test write dump to no CUID tag fails with message", (tester) async {
      await testWriteFromDumpBlockZeroFail(tester, generateMockMifareClassic());
    });

    testWidgets("Test writing dump to a MifareClassic with unknown keys fails", (tester) async {
      await testWriteFromDumpBadKey(tester, generateMockMifareClassic());
    });

    testWidgets("Test writing dump to a diconnected tag", (tester) async {
      await testWriteFromDumpTagLost(tester, generateMockMifareClassic());
    });


    testWidgets("Test read dump", (tester) async {
      await testReadDumpSuccessful(tester, generateMockMifareClassic(), exampleDumpTestReadDump);
    });

    testWidgets("Test change UID", (tester) async {
      await testChangeUid(tester, generateMockMifareClassic(), "ABD453C7", expectedTagContentChangeUidTestMifareClassicSuccess);
    });

    testWidgets("Test change UID Fail on block 0 write", (tester) async {
      await testChangeUidFailBlockZero(tester, generateMockMifareClassic(), "ABD453C7", expectedTagContentChangeUidTestMifareClassicFailBlockZero);
    });

    testWidgets("Test change UID fail with bad keys", (tester) async {
      await testChangeUidBadKey(tester, generateMockMifareClassic(), "ABD453C7", "");
    });

    testWidgets("Test change UID tag disconnected", (tester) async {
      await testChangeUidTagDisconnected(tester, generateMockMifareClassic(), "ABD453C7", "");
    });

    testWidgets("Test auto-repair success", (tester) async{
      await testAutoRepairSuccess(tester, generateBrokenTag());
    });

    testWidgets("Test auto-repair key fail", (tester) async{
      await testAutoRepairKeyFail(tester, generateBrokenTag());
    });

    testWidgets("Test auto-repair tag disconnected", (tester) async{
      await testAutoRepairTagDisconnected(tester, generateBrokenTag());
    });

  });


  group("MiZip tests", (){
    testWidgets("Start The app, and check displayed data in all menus", (tester) async {
      await testTagDataMizip(tester, generateMockMizipTag());
    });

    testWidgets("Change balance success", (tester) async{
      await testChangeBalanceSuccess(tester, generateMockMizipTag(), "26.92");
    });

    testWidgets("Change balance tag disconnected", (tester) async{
      await testChangeBalanceTagRemoved(tester, generateMockMizipTag(), "26.92");
    });

    testWidgets("Add 10\$", (tester) async{
      await testAdd10Success(tester, generateMockMizipTag());
    });

    testWidgets("Add 10\$ tag disconnected", (tester) async{
      await testAdd10TagDisconnected(tester, generateMockMizipTag());
    });

    testWidgets("Test dump tag success", (tester) async {
      await testDumpTagSuccesful(tester, generateMockMizipTag());
    });

    testWidgets("Test dump tag incorrect keys", (tester) async{
      await testDumpTagKeyError(tester, generateMockMizipTag());
    });

    testWidgets("Test write from dump", (tester) async {
      await testWriteFromDumpSuccesful(tester, generateMockMizipTag());
    });

    testWidgets("Test write dump to no CUID tag fails with message", (tester) async {
      await testWriteFromDumpBlockZeroFail(tester, generateMockMizipTag());
    });

    testWidgets("Test writing dump with unknown keys fails", (tester) async {
      await testWriteFromDumpBadKey(tester, generateMockMizipTag());
    });

    testWidgets("Test writing dump to a diconnected tag", (tester) async {
      await testWriteFromDumpTagLost(tester, generateMockMizipTag());
    });

    testWidgets("Test read dump", (tester) async {
      await testReadDumpSuccessful(tester, generateMockMizipTag(), exampleDumpTestReadDump);
    });

    testWidgets("Test change UID", (tester) async {
      await testChangeUid(tester, generateMockMizipTag(), "ABD453C7", expectedTagContentChangeUidTestMizipSuccess);
    });

    testWidgets("Test change UID Fail on block 0 write", (tester) async {
      await testChangeUidFailBlockZero(tester, generateMockMizipTag(), "ABD453C7", expectedTagContentChangeUidTestMizipFailBlockZero);
    });

    testWidgets("Test change UID fail with bad keys", (tester) async {
      await testChangeUidBadKey(tester, generateMockMizipTag(), "ABD453C7", "");
    });

    testWidgets("Test change UID tag disconnected", (tester) async {
      await testChangeUidTagDisconnected(tester, generateMockMizipTag(), "ABD453C7", "");
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