import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:miziptools/main.dart';
import 'package:miziptools/widgets/basic/container_with_border.dart';
import 'package:path_provider/path_provider.dart';

import 'common_tests/consts.dart';
import 'mock/mock_nfc_adapter.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  group("No NFC disabled test", () {
    testWidgets("Check displayed data in all menus", (tester) async {
      final dataDir = await getExternalStorageDirectory();
      final mockAdapter = MockNfcAdapter(available: false);

      await tester.pumpWidget(App(
        nfcAdapter: mockAdapter,
        dataDir: dataDir!,
      ));
      await tester.pumpAndSettle(delay);

      find.widgetWithText(ContainerWithBorder, "NFC not enabled");
    });
  });
}
