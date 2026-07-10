import "package:flutter/material.dart";
import "package:miziptools/nfc/currentnfctag.dart";
import "package:miziptools/widgets/advanced/auto_repair.dart";
import "package:miziptools/widgets/advanced/change_uid.dart";
import "package:miziptools/widgets/common/tag_data.dart";
import "package:provider/provider.dart";

/// Page for advanced options
///
/// Change UID => Tag is present
/// Auto-repair => Tag is present and is not Mizip
class AdvancedMenu extends StatelessWidget {
  /// Creates an [AdvancedMenu]
  const AdvancedMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final tag = context.read<CurrentNFCTag>();
    return ListView(
      children: [
        const TagData(),
        if (tag.isPresent()) ChangeUid(),
        if (tag.isPresent() && !tag.isMizipTag()) AutoRepair(),
      ],
    );
  }
}
