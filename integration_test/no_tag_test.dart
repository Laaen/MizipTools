import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'common_tests/test_read_dump.dart';
import 'common_tests/test_tag_data.dart';

void main(){
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  group("No tag tests", (){
    group("Tag Data", (){
      testWidgets("Check displayed data in all menus", (tester) async {
        await testTagDataNoTag(tester, null);
      });
    });
    group("Dump", (){
      testWidgets("Read dump success", (tester) async {
        await testReadDumpSuccess(tester, null, exampleDumpTestReadDump);
      });
    });
  });
}