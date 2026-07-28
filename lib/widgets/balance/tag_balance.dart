import "package:flutter/material.dart";
import "package:miziptools/exceptions/nfc_exception_handler.dart";
import "package:miziptools/misc/snackbar.dart";
import "package:miziptools/nfc/currentnfctag.dart";
import "package:miziptools/widgets/basic/container_with_border.dart";
import "package:provider/provider.dart";

/// Widget to change the tag's balance to the value set by the user
class TagBalance extends StatelessWidget {
  /// Returns a new [TagBalance]
  TagBalance({super.key});

  final _tagBalanceForm = GlobalKey<FormState>();
  final _balanceController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final textField = newBalanceField();

    return Form(
      child: ContainerWithBorder(
        child: Column(
          spacing: 15,
          children: [
            Form(key: _tagBalanceForm, child: textField),
            OutlinedButton(
              onPressed: () => changeBalance(context),
              child: const Text("Ok"),
            ),
          ],
        ),
      ),
    );
  }

  /// Field where the user sets the new balance of the tag
  TextFormField newBalanceField() {
    return TextFormField(
      controller: _balanceController,
      maxLength: 5,
      keyboardType: TextInputType.number,
      decoration: const InputDecoration(
        labelText: "New balance",
        border: UnderlineInputBorder(),
      ),
      validator: newBalanceValidator,
    );
  }

  /// Validator for the balance
  ///
  /// The balance must be :
  /// - Greater or equal to 0
  /// - Not empty
  /// - A valid double
  /// - Less than 100
  String? newBalanceValidator(String? newBalance) {
    if (newBalance == null || newBalance.isEmpty) {
      return "Can't be empty";
    }
    final double? value = double.tryParse(newBalance);
    if (value == null) {
      return "Not a valid number";
    }
    if (value < 0.0) {
      return "Can't be negative";
    }
    if (value > 100.0) {
      return "Can't be over 100.0";
    }
    return null;
  }

  /// Communicates with the tag to change its balance
  Future<void> changeBalance(BuildContext context) async {
    if (_tagBalanceForm.currentState!.validate()) {
      final tag = context.read<CurrentNFCTag>();
      showSnackBar(context, "Changing balance");
      try {
        await tag.setBalance(_balanceController.text);
        if (context.mounted) {
          showSnackBar(context, "Balance changed successfully");
        }
      } on Exception catch (e) {
        // We don't care if the message is not displayed
        // ignore: use_build_context_synchronously
        handleException(e, context);
        return;
      }
    }
  }
}
