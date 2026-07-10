import "package:flutter/material.dart";
import "package:miziptools/nfc/currentnfctag.dart";
import "package:miziptools/widgets/balance/tag_add_10.dart";
import "package:miziptools/widgets/balance/tag_balance.dart";
import "package:miziptools/widgets/common/tag_data.dart";
import "package:provider/provider.dart";

/// Menu to change balance
///
/// TagBalance => Tag is present and Mizip
/// TagAdd10 => Tag is present and Mizip
class BalanceMenu extends StatelessWidget {
  /// Returns a [BalanceMenu]
  const BalanceMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final tag = context.read<CurrentNFCTag>();
    return ListView(
      children: [
        const TagData(),
        if (tag.isPresent() && tag.isMizipTag()) TagBalance(),
        if (tag.isPresent() && tag.isMizipTag()) const TagAdd10(),
      ],
    );
  }
}
