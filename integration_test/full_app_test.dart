import "package:integration_test/integration_test.dart";

import "mifare_classic_test.dart" as mifare_classic;
import "mizip_test.dart" as mizip;
import "nfc_disabled.dart" as nfc_disabled;
import "no_tag_test.dart" as no_tag;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  nfc_disabled.main();
  no_tag.main();
  mifare_classic.main();
  mizip.main();
}
