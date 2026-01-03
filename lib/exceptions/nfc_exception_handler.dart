import 'package:flutter/material.dart';
import 'package:miziptools/exceptions/nfc_exceptions.dart';
import 'package:miziptools/misc/snackbar.dart';
import 'package:miziptools/nfc/nfc_adapter.dart';

class NfcExceptionHandler {

  static void handleException(Exception e, BuildContext context, {String prefix = ""}){
    switch(e.runtimeType){
      case const (RetriesExcedeedException):
        NfcExceptionHandler.displaySnackbar(context, "${prefix}Number of retries excedeed");
      case const (SectorAuthenticationFailed):
        NfcExceptionHandler.displaySnackbar(context, "${prefix}Incorrect keys");
      case const (NfcAdapterCommunicationException):
        NfcExceptionHandler.displaySnackbar(context, "${prefix}Communication error");
      case const (NfcAdapterTagRemovedException):
        NfcExceptionHandler.displaySnackbar(context, "${prefix}Tag was removed");
      case const (NfcAdapterException):
        NfcExceptionHandler.displaySnackbar(context, "${prefix}Unknown exception");
      case const (ReleaseFailedException):
        NfcExceptionHandler.displaySnackbar(context, "${prefix}Error while releasing the tag : Tag was lost");
      case const(WriteSectorZeroException):
        NfcExceptionHandler.displaySnackbar(context, "${prefix}Warning : Sector 0 write failed, tag is not a CUID one");
    }
  }

  static void displaySnackbar(BuildContext context, String message){
    if(context.mounted){
      showSnackBar(context, message);
    }
  }

}