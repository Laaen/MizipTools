import "package:flutter/material.dart";

/// Shows a snackbar with the given message
void showSnackBar(BuildContext context, String message) {
  final snackbar = SnackBar(
    content: Text(message),
    duration: const Duration(seconds: 2),
  );
  ScaffoldMessenger.of(context).hideCurrentSnackBar();
  ScaffoldMessenger.of(context).showSnackBar(snackbar);
}

