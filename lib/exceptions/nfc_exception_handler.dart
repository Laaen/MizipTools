import 'package:flutter/material.dart';
import 'package:miziptools/exceptions/nfc_exceptions.dart';
import 'package:miziptools/misc/snackbar.dart';

class NfcExceptionHandler {

  static void handleException(Exception e, BuildContext context){
    switch(e.runtimeType){
      case const (ReadTagRemovedException):
        NfcExceptionHandler.displaySnackbar(context, "Error while reading : Tag was removed");
      case const (ReadSectorAuthenticationFailed):
        NfcExceptionHandler.displaySnackbar(context, "Error while reading : Incorrect key");
      case const (ReadRetriesExcedeedException):
        NfcExceptionHandler.displaySnackbar(context, "Error while reading : Maximum number of retries reached");
      case const (ReadUnknownException):
        NfcExceptionHandler.displaySnackbar(context, "Error while reading : Unknow error");
      case const (WriteTagRemovedException):
        NfcExceptionHandler.displaySnackbar(context, "Error while writing : Tag was removed");
      case const (WriteSectorAuthenticationFailed):
        NfcExceptionHandler.displaySnackbar(context, "Error while writing : Incorrect key");
      case const (WriteRetriesExcedeedException):
        NfcExceptionHandler.displaySnackbar(context, "Error while writing : Maximum number of retries reached");
      case const (WriteUnknownException):
        NfcExceptionHandler.displaySnackbar(context, "Error while writing : Unknow error");
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