import "package:flutter/material.dart";
import "package:miziptools/extensions/uint8list_extensions.dart";
import "package:miziptools/nfc/currentnfctag.dart";
import "package:miziptools/tags/balance.dart";
import "package:miziptools/widgets/basic/container_with_border.dart";
import "package:provider/provider.dart";

/// Widget used to display TagData
class TagData extends StatelessWidget {
  /// Returns a new [TagData]
  const TagData({super.key});

  @override
  Widget build(BuildContext context) {
    final tag = Provider.of<CurrentNFCTag>(context);
    // Order of evaluation is important as MizipTag inherits MifareClassicTag
    if (tag.isPresent()) {
      return ContainerWithBorder(child: getTagDataDisplay(tag));
    } else {
      return const ContainerWithBorder(
        child: Text("No tag detected", style: TextStyle(fontSize: 16)),
      );
    }
  }

  /// The widget which displays the data
  Widget getTagDataDisplay(CurrentNFCTag tag) {
    return Column(
      children: [
        const Text(
          "Tag data",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
        // Empty container for some spacing
        Container(
          height: 10,
        ),
        if (!tag.isMizipTag())
          const Row(
            children: [
              Text(
                "Not a MiZip tag (Mifare Classic)",
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
        Row(
          children: [
            Text(
              "UID: ${tag.getUid().toHexString().toUpperCase()}",
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
        if (tag.isMizipTag())
          Row(
            children: [
              Text(
                "Balance: ${tag.getBalance().getStringBalance()}\$",
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
        if (tag.isMizipTag() && tag.getBalance().valid != BalanceValidity.valid)
          const Row(
            children: [
              Text(
                "Invalid checksum",
                style: TextStyle(fontSize: 18, color: Colors.red),
              ),
            ],
          ),
      ],
    );
  }
}
