import "package:flutter/material.dart";
import "package:miziptools/data_dir/data_dir.dart";
import "package:miziptools/nfc/currentnfctag.dart";
import "package:miziptools/widgets/common/tag_data.dart";
import "package:miziptools/widgets/dump/dump_tag.dart";
import "package:miziptools/widgets/dump/read_dump.dart";
import "package:miziptools/widgets/dump/write_from_dump.dart";
import "package:provider/provider.dart";

/// Menu for reading / creating dumps
///
/// Uses the DataDir provider to access files
///
/// DumpTag => Tag is present
/// WriteFromDump => Tag is present
/// ReadDump => Always
class DumpMenu extends StatelessWidget {
  /// Returns a [DumpMenu]
  const DumpMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final tag = context.read<CurrentNFCTag>();
    return Consumer<DataDir>(
      builder: (context, value, child) {
        return ListView(
          children: [
            const TagData(),
            if (tag.isPresent()) const DumpTag(),
            if (tag.isPresent()) WriteFromDump(),
            ReadDump(),
          ],
        );
      },
    );
  }
}
