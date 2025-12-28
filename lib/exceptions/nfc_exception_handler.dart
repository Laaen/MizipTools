import 'package:flutter/material.dart';
import 'package:miziptools/exceptions/nfc_exceptions.dart';
import 'package:miziptools/misc/snackbar.dart';
import 'package:miziptools/nfc/nfc_adapter.dart';

class NfcExceptionHandler {

  static void handleException(Exception e, BuildContext context){
    switch(e.runtimeType){
      case const (RetriesExcedeedException):
        NfcExceptionHandler.displaySnackbar(context, "Number of retries excedeed");
      case const (SectorAuthenticationFailed):
        NfcExceptionHandler.displaySnackbar(context, "Incorrect keys");
      case const (NfcAdapterCommunicationException):
        NfcExceptionHandler.displaySnackbar(context, "Communication error");
      case const (NfcAdapterTagRemovedException):
        NfcExceptionHandler.displaySnackbar(context, "Tag was removed");
      case const (NfcAdapterException):
        NfcExceptionHandler.displaySnackbar(context, "Unknown exception");
      case const (ReleaseFailedException):
        NfcExceptionHandler.displaySnackbar(context, "Error while releasing the tag : Tag was lost");
    }
  }

  static void displaySnackbar(BuildContext context, String message){
    if(context.mounted){
      showSnackBar(context, message);
    }
  }

}