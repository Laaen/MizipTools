import "package:flutter/material.dart";
import "package:miziptools/exceptions/nfc_exceptions.dart";
import "package:miziptools/misc/snackbar.dart";
import "package:miziptools/nfc/nfc_adapter.dart";

///
void handleException(Exception e, BuildContext context, {String prefix = ""}) {
  switch (e.runtimeType) {
    case const (RetriesExcedeedException):
      displaySnackbar(
        context,
        "${prefix}Number of retries excedeed",
      );
    case const (SectorAuthenticationFailed):
      displaySnackbar(
        context,
        "${prefix}Incorrect keys",
      );
    case const (NfcAdapterCommunicationException):
      displaySnackbar(
        context,
        "${prefix}Communication error",
      );
    case const (NfcAdapterTagRemovedException):
      displaySnackbar(
        context,
        "${prefix}Tag was removed",
      );
    case const (NfcAdapterException):
      displaySnackbar(
        context,
        "${prefix}Unknown exception",
      );
    case const (ReleaseFailedException):
      displaySnackbar(
        context,
        "${prefix}Error while releasing the tag : Tag was lost",
      );
    case const (WriteSectorZeroException):
      displaySnackbar(
        context,
        "${prefix}Warning : Sector 0 write failed, tag is not a CUID one",
      );
  }
}

/// Shows a snackbar displaying the given message
void displaySnackbar(BuildContext context, String message) {
  if (context.mounted) {
    showSnackBar(context, message);
  }
}
