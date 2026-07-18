import "package:flutter/foundation.dart";
import "package:flutter/material.dart";
import "package:logging/logging.dart";
import "package:miziptools/exceptions/nfc_exception_handler.dart";
import "package:miziptools/extensions/string_extensions.dart";
import "package:miziptools/misc/snackbar.dart";
import "package:miziptools/nfc/currentnfctag.dart";
import "package:miziptools/nfc/nfc.dart";
import "package:miziptools/nfc/nfc_adapter.dart";
import "package:miziptools/nfc/nfc_tag.dart";
import "package:miziptools/pages/advanced_menu.dart";
import "package:miziptools/pages/balance_menu.dart";
import "package:miziptools/pages/dump_menu.dart";
import "package:miziptools/tags/balance.dart";
import "package:miziptools/tags/mifare_classic_tag.dart";
import "package:miziptools/tags/mizip_tag.dart";
import "package:miziptools/widgets/common/appbar.dart";
import "package:provider/provider.dart";
import "package:synchronized/synchronized.dart";

/// The main page of the application
///
/// It is a complex and important widget
///
/// It will start the NFC communication loop on first launch
class MainPage extends StatefulWidget {
  /// Returns a [MainPage]
  const MainPage({super.key});

  @override
  State<StatefulWidget> createState() {
    return MainPageState();
  }
}

/// State of [MainPage]
///
/// We use a State to start the NFC communication loop in [initState]
class MainPageState extends State<MainPage> {
  /// Lock to prevent overlapping communication with the NFC tag
  /// It is useful to prevent a ping send while another operation is being
  /// done
  Lock globalLock = Lock(reentrant: true);

  @override
  Widget build(BuildContext context) {
    Logger.root.info("Starting app");
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: const MizipToolsAppBar(),
        body: Consumer<CurrentNFCTag>(
          builder: (context, tag, child) {
            return Container(
              padding: const EdgeInsets.fromLTRB(0, 30, 0, 30),
              child: TabBarView(
                children: [
                  BalanceMenu(),
                  DumpMenu(),
                  AdvancedMenu(),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  /// Shows a snackbar telling the current tag is not supported
  /// Waits for 2 seconds to avoid spam
  Future<void> handleNotMifareClassicTag() async {
    showSnackBar(context, "Not a Mifare Classic tag");
    Logger.root.warning("Not a Mifare classic tag");
    await Future.delayed(const Duration(seconds: 2));
  }

  @override
  void initState() {
    super.initState();
    final currentTag = context.read<CurrentNFCTag>();
    final nfcAdapter = context.read<NfcAdapter>();
    Logger.root.info("Starting nfc watch loop");
    // This is the main "sloppy hack", we don't await this Future since it's an
    // infinite loop, a better way to do it would be to use an Isolate
    // ignore: discarded_futures
    watchForTag(
      currentTag,
      nfcAdapter,
      globalLock,
      context,
      onTagLost,
      onTagDetected,
    );
  }

  /// Returns wether the given tag is a Mizip one
  ///
  /// If the inner balance can be read, then it is a Mizip tag
  /// The checksum can be bad, in this case a message will be
  /// showed to the user
  Future<bool> isMizipTag(NfcTag tag, NfcAdapter nfcAdapter) async {
    final cTag = MizipTag(
      uid: tag.id.toUint8List(),
      lock: globalLock,
      nfcAdapter: nfcAdapter,
    );
    try {
      await cTag.updateInnerBalance();
      // We need to catch all excetpions to convert them to a custom one
      // ignore: avoid_catches_without_on_clauses
    } catch (e) {
      Logger.root.warning("Error while getting balance : $e");
      return false;
    }
    final Balance balance = cTag.getBalance();
    return balance.balanceValidity == BalanceValidity.valid ||
        balance.balanceValidity == BalanceValidity.badChecksum;
  }

  /// Callback executed when a new tag is detected
  ///
  /// It first checks if the tag is a Mifare Classic
  /// Depending on wether it is a Mizip or a MifareClassic,
  /// it will update the [CurrentNFCTag] object
  Future<void> onTagDetected(
    Lock globalLock,
    NfcTag tag,
    NfcAdapter nfcAdapter,
  ) async {
    Logger.root.info("Tag detected");
    if (tag.type != NfcTagType.mifareClassic) {
      await handleNotMifareClassicTag();
      return;
    }

    MifareClassicTag currentTag;
    if (await isMizipTag(tag, nfcAdapter)) {
      currentTag = MizipTag(
        uid: tag.id.toUint8List(),
        lock: globalLock,
        nfcAdapter: nfcAdapter,
      );
    } else {
      currentTag = MifareClassicTag(
        uid: tag.id.toUint8List(),
        lock: globalLock,
        nfcAdapter: nfcAdapter,
      );
    }

    if (mounted) {
      final t = context.read<CurrentNFCTag>();
      try {
        await t.updateInnerTag(currentTag);
      } on Exception catch (e) {
        // It's not important if the message is not displayed
        // ignore: use_build_context_synchronously
        handleException(e, context);
      }
    }
  }

  /// Called when the tag is lost,
  /// il sets [CurrentNFCTag]'s innerTag to null
  Future<void> onTagLost() async {
    if (mounted) {
      context.read<CurrentNFCTag>().setTagAbsent();
    }
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<Lock>("globalLock", globalLock));
  }
}
