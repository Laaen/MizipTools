import 'package:flutter/material.dart';
import 'package:miziptools/exceptions/nfc_exceptions.dart';

class NfcExceptionHandler {

  static void handleException(Exception e, BuildContext context){
    switch(e.runtimeType){
      case ReadTagRemovedException _:
        NfcExceptionHandler.showSnackbar(context, "Error while reading : Tag was removed");
      case ReadSectorAuthenticationFailed _:
        NfcExceptionHandler.showSnackbar(context, "Error while reading : Incorrect key");
      case ReadRetriesExcedeedException _:
        NfcExceptionHandler.showSnackbar(context, "Error while reading : Maximum number of retries reached");
      case ReadUnknownException _:
        NfcExceptionHandler.showSnackbar(context, "Error while reading : Unknow error");
      case WriteTagRemovedException _:
        NfcExceptionHandler.showSnackbar(context, "Error while writing : Tag was removed");
      case WriteSectorAuthenticationFailed _:
        NfcExceptionHandler.showSnackbar(context, "Error while writing : Incorrect key");
      case WriteRetriesExcedeedException _:
        NfcExceptionHandler.showSnackbar(context, "Error while writing : Maximum number of retries reached");
      case WriteUnknownException _:
        NfcExceptionHandler.showSnackbar(context, "Error while writing : Unknow error");
    }
  }

  static void showSnackbar(BuildContext context, String message){
    if(context.mounted){
      showSnackbar(context, message);
    }
  }

}