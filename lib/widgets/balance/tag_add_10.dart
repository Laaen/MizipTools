import "dart:math";
import "package:flutter/material.dart";
import "package:miziptools/exceptions/nfc_exception_handler.dart";
import "package:miziptools/misc/snackbar.dart";
import "package:miziptools/nfc/currentnfctag.dart";
import "package:miziptools/tags/balance.dart";
import "package:miziptools/widgets/basic/container_with_border.dart";
import "package:provider/provider.dart";

/// Widget to add 10 units to the tag balance
class TagAdd10 extends StatelessWidget {
  /// Returns a [TagAdd10]
  const TagAdd10({super.key});

  @override
  Widget build(BuildContext context) {
    return ContainerWithBorder(
      child: OutlinedButton(
        onPressed: () async => add10(context),
        child: const Text(r"Add 10$"),
      ),
    );
  }

  /// Changes the balance of the tag to add 10 units to it
  Future<void> add10(BuildContext context) async {
    showSnackBar(context, r"Adding 10$");
    final tag = context.read<CurrentNFCTag>();

    try {
      await tag.updateInnerBalance();
    } on Exception catch (e) {
      // ignore: use_build_context_synchronously
      handleException(e, context,
          prefix: "Error: Could not get tag's current balance : ");
      return;
    }

    final currentBalance = tag.getBalance();
    if (currentBalance.valid == BalanceValidity.invalid) {
      if (context.mounted) {
        showSnackBar(context, "Error: The retreived balance is incorrect");
      }
      return;
    }

    final newBalance = min(currentBalance.getDoubleBalance() + 10, 100.0);

    try {
      await tag.setBalance(newBalance.toString());
    } on Exception catch (e) {
      // ignore: use_build_context_synchronously
      handleException(e, context, prefix: "Error while writing new balance : ");
      return;
    }

    if (context.mounted) {
      showSnackBar(context, "Balance changed successfully");
    }
  }
}
