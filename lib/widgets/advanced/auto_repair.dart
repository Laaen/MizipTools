import "dart:io";
import "package:flutter/material.dart";
import "package:logging/logging.dart";
import "package:miziptools/data_dir/data_dir.dart";
import "package:miziptools/exceptions/nfc_exception_handler.dart";
import "package:miziptools/extensions/string_extensions.dart";
import "package:miziptools/misc/snackbar.dart";
import "package:miziptools/nfc/currentnfctag.dart";
import "package:miziptools/widgets/basic/container_with_border.dart";
import "package:provider/provider.dart";

/// Widget for auto-repair
///
/// Has a field in which the user can give an UID
/// On button press, it will try to get the current keys of the tag,
/// and to replace them with which Mizip keys it should have
class AutoRepair extends StatelessWidget {
  /// Returns a new [AutoRepair]
  AutoRepair({super.key});

  final _uidFormKey = GlobalKey<FormState>();
  final _uidFormController = TextEditingController();

  /// List of valid hexadecimal chars
  static const validChars = "0123456789ABCDEF";

  @override
  Widget build(BuildContext context) {
    final textField = TextFormField(
      controller: _uidFormController,
      maxLength: 8,
      validator: uidFieldValidator,
      decoration: const InputDecoration(
        labelText: "Old UID",
        border: UnderlineInputBorder(),
      ),
    );

    _uidFormController.text = getSavedUid(context);

    return ContainerWithBorder(
      child: Column(
        spacing: 10,
        children: [
          const Text("Auto-Repair", style: TextStyle(fontSize: 18)),
          Column(
            spacing: 15,
            children: [
              Form(key: _uidFormKey, child: textField),
              OutlinedButton(
                onPressed: () async => autoRepair(context),
                child: const Text("Ok"),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Validator method for the UID field
  ///
  /// It checks if the given UID is :
  /// - Of 8 characters long
  /// - Has only hexadecimal characters
  String? uidFieldValidator(String? data) {
    final upcasedData = data?.toUpperCase();

    if (upcasedData == null || upcasedData.length < 8) {
      return "UID must be 8 chars";
    }
    if (upcasedData.characters.any((char) => !validChars.contains(char))) {
      return "Must be valid hexa";
    }
    return null;
  }

  /// Performs the autorepair
  Future<void> autoRepair(BuildContext context) async {
    final tag = context.read<CurrentNFCTag>();
    if (_uidFormKey.currentState!.validate()) {
      showSnackBar(context, "Trying to auto-repair");

      try {
        await tag.autoRepair(_uidFormController.text.toUint8List());
        if (context.mounted) {
          showSnackBar(context, "Repair successful");
        }
      } on Exception catch (e) {
        // Non-critical snackbar, if is is not shown it's not the end of the world
        // ignore: use_build_context_synchronously
        handleException(e, context);
        return;
      }

      try {
        // Release to poll new tag
        await tag.releaseTag();
      } on Exception catch (e) {
        // Non-critical snackbar, if is is not shown it's not the end of the world
        // ignore: use_build_context_synchronously
        handleException(e, context);
        return;
      }
    }
  }

  /// Returns the content of the `uid_save` file
  String getSavedUid(BuildContext context) {
    try {
      final dataDir = context.read<DataDir>();
      return dataDir.readFile("uid_save");
    } on FileSystemException catch (e) {
      Logger.root.severe("Error while reading save uid file : $e");
      return "00000000";
    }
  }
}
