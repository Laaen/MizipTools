import 'package:flutter/material.dart';
import "package:logging/logging.dart";
import "package:miziptools/exceptions/nfc_exception_handler.dart";
import "package:miziptools/extensions/string_extensions.dart";
import "package:miziptools/nfc/nfc_adapter.dart";
import "package:miziptools/nfc/nfc_tag.dart";
import "package:miziptools/pages/advanced_menu.dart";
import "package:miziptools/tags/balance.dart";
import "package:miziptools/tags/mifare_classic_tag.dart";
import "package:miziptools/nfc/nfc.dart";
import "package:miziptools/nfc/currentnfctag.dart";
import "package:miziptools/misc/snackbar.dart";
import "package:miziptools/pages/balance_menu.dart";
import "package:miziptools/pages/dump_menu.dart";
import "package:provider/provider.dart";
import 'package:synchronized/synchronized.dart';
import "../tags/mizip_tag.dart";
import "../widgets/common/appbar.dart";

class MainPage extends StatefulWidget{

const MainPage({super.key});

@override
  State<StatefulWidget> createState() {
    return MainPageState();
  }
}

class MainPageState extends State<MainPage>{

  Lock globalLock = Lock(reentrant: true);

  @override
  Widget build(BuildContext context){
    Logger.root.info("Starting app");
    return DefaultTabController(initialIndex: 0,
      length: 3, 
      child: Scaffold(
        appBar: MizipToolsAppBar(),
        body: Consumer<CurrentNFCTag>(builder: (context, tag, child) {
          return Container(
            padding: EdgeInsets.fromLTRB(0, 30, 0, 30),
            child: 
              TabBarView(
                children: [
                  BalanceMenu(),
                  DumpMenu(),
                  AdvancedMenu()
              ] 
            )
          );
          }
        )
      )
    );
  }

  @override
  void initState(){
    super.initState();
    final currentTag = context.read<CurrentNFCTag>();
    final nfcAdapter = context.read<NfcAdapter>();
    Logger.root.info("Starting nfc watch loop");
    watchForTag(currentTag, nfcAdapter, globalLock, context, onTagLost, onTagDetected);
  }

  void onTagLost() async {
    if(mounted){
      context.read<CurrentNFCTag>().setTagAbsent();
    } 
  }

  /// Callback executed when a new tag is detected, gets the tag's handle + its keys
  Future<void> onTagDetected (Lock globalLock, NfcTag tag, NfcAdapter nfcAdapter) async{
    if(tag.type != NfcTagType.mifareClassic){
      await handleNotMifareClassicTag();
      return;
    }

    MifareClassicTag currentTag;
    if (await isMizipTag(tag, nfcAdapter)){
      currentTag = MizipTag(uid: tag.id.toUint8List(), lock: globalLock, nfcAdapter: nfcAdapter);
    } else {
      currentTag = MifareClassicTag(uid: tag.id.toUint8List(), lock: globalLock, nfcAdapter: nfcAdapter);
    }
    
    if (mounted){
      var t = context.read<CurrentNFCTag>();
      try{
        await t.updateInnerTag(currentTag);  
      } on Exception catch(e){
        // ignore: use_build_context_synchronously
        NfcExceptionHandler.handleException(e, context);
      } 
    }
  }

  Future<void> handleNotMifareClassicTag() async {
    showSnackBar(context, "Not a Mifare Classic tag");
    Logger.root.warning("Not a Mifare classic tag");
    await Future.delayed(Duration(seconds: 2));
  }

  Future<bool> isMizipTag(NfcTag tag, NfcAdapter nfcAdapter) async{
    final cTag = MizipTag(uid: tag.id.toUint8List(), lock: globalLock, nfcAdapter: nfcAdapter);
    try{
      await cTag.updateInnerBalance();
    } catch (e){
      Logger.root.warning("Error while getting balance : $e");
      return false;
    }
    Balance balance = cTag.getBalance();
    return balance.valid;
  }
}