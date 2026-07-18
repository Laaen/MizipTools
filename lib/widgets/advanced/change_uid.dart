import "package:flutter/material.dart";
import "package:miziptools/exceptions/nfc_exception_handler.dart";
import "package:miziptools/extensions/string_extensions.dart";
import "package:miziptools/misc/snackbar.dart";
import "package:miziptools/nfc/currentnfctag.dart";
import "package:miziptools/widgets/basic/container_with_border.dart";
import "package:provider/provider.dart";

/// Widget for changing the UID of the tag
///
/// The user fills the field with the new UID to write
class ChangeUid extends StatelessWidget {
  /// Returns a new [ChangeUid]
  ChangeUid({super.key});

  /// Valid hexadecimal characters
  static const validChars = "0123456789ABCDEF";
  final _uidFormKey = GlobalKey<FormState>();

  final _uidFormController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final textField = TextFormField(
      controller: _uidFormController,
      maxLength: 8,
      validator: uidFieldValidator,
      decoration: const InputDecoration(
        labelText: "New UID",
        border: UnderlineInputBorder(),
      ),
    );

    return ContainerWithBorder(
      child: Column(
        spacing: 15,
        children: [
          Form(key: _uidFormKey, child: textField),
          OutlinedButton(
            onPressed: () async => changeUid(context),
            child: const Text("Ok"),
          ),
        ],
      ),
    );
  }

  /// Changes the UID of the tag (and all keys)
  Future<void> changeUid(BuildContext context) async {
    final tag = context.read<CurrentNFCTag>();
    if (_uidFormKey.currentState!.validate()) {
      showSnackBar(context, "Changing UID");
      try {
        await tag.setUid(_uidFormController.text.toUint8List());
      } on Exception catch (e) {
        // We can survive if the message is not displayed
        // ignore: use_build_context_synchronously
        handleException(e, context);
        return;
      }

      if (context.mounted) {
        showSnackBar(context, "UID changed successfully");
      }

      try {
        await tag.releaseTag();
      } on Exception catch (e) {
        // We can survive if the message is not displayed
        // ignore: use_build_context_synchronously
        handleException(e, context);
        return;
      }
    }
  }

  /// Validator for UID
  ///
  /// The UID must have only hexadecimal chars and be 8 chars long
  String? uidFieldValidator(String? data) {
    final uid = data?.toUpperCase();

    if (uid == null || uid.length < 8) {
      return "UID must be 8 chars";
    }
    if (uid.characters.any((char) => !validChars.contains(char))) {
      return "Must be valid hexa";
    }
    return null;
  }
}
