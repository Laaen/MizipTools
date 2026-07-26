import "dart:typed_data";

import "package:flutter/material.dart";
import "package:miziptools/data_dir/data_dir.dart";
import "package:miziptools/exceptions/nfc_exception_handler.dart";
import "package:miziptools/extensions/uint8list_extensions.dart";
import "package:miziptools/misc/snackbar.dart";
import "package:miziptools/nfc/currentnfctag.dart";
import "package:miziptools/tags/mifare_classic_tag.dart";
import "package:miziptools/widgets/basic/container_with_border.dart";
import "package:provider/provider.dart";

/// Widget for dumping the tag
class DumpTag extends StatelessWidget {
  /// Returns a [DumpTag]
  const DumpTag({super.key});

  @override
  Widget build(BuildContext context) {
    return ContainerWithBorder(
      child: OutlinedButton(
        onPressed: () async => dumpTag(context),
        child: const Text("Dump Tag"),
      ),
    );
  }

  /// Gets the data from the tag, and writes it to a file
  Future<void> dumpTag(BuildContext context) async {
    final tag = context.read<CurrentNFCTag>();
    final keys = tag.getKeys();
    final fileName = tag.getUid().toHexString().toUpperCase();

    showSnackBar(context, "Dumping tag's data");

    List<Uint8List> rawDump = [];
    try {
      rawDump = await tag.dumpTagData();
    } on Exception catch (e) {
      // We don't care if the message is really displayed
      // ignore: use_build_context_synchronously
      handleException(e, context);
      return;
    }

    List<String> stringDump = [];
    try {
      stringDump = toStringDump(rawDump);
      stringDump = addKeysToDump(stringDump, keys);
    } on Exception catch (e) {
      if (context.mounted) {
        showSnackBar(context, "Error while processing dump : $e");
      }
      return;
    }

    try {
      if (context.mounted) {
        await writeDumpToFile(context, fileName, stringDump);
      }
    } catch (e) {
      if (context.mounted) {
        showSnackBar(context, "Error while writing dump to file : $e");
      }
      return;
    }

    if (context.mounted) {
      showSnackBar(context, "Dump done file : $fileName.dump");
    }
  }

  /// Returns a list of string from the raw dump
  List<String> toStringDump(List<Uint8List> rawDump) {
    final List<String> result = [];
    for (final block in rawDump) {
      result.add(block.toHexString().toUpperCase());
    }
    return result;
  }

  /// Adds the keys to the dump
  ///
  /// When the tag's data is read from the tag, the keys are not included
  /// in the trailer blocks, so we have to add them manually
  List<String> addKeysToDump(List<String> dump, MifareKeys keys) {
    var modifiedDump = dump.toList();
    for (final (sectorNb, blockNb) in [3, 7, 11, 15, 19].indexed) {
      final keyA = keys.a[sectorNb].toHexString().toUpperCase();
      final keyB = keys.b[sectorNb].toHexString().toUpperCase();
      final permissions = modifiedDump[blockNb].substring(12, 20);
      modifiedDump[blockNb] = keyA + permissions + keyB;
    }
    return modifiedDump;
  }

  /// Writes the dump to a file
  Future<void> writeDumpToFile(
    BuildContext context,
    String fileName,
    List<String> content,
  ) async {
    await context.read<DataDir>().writeFile(
      "$fileName.dump",
      content.join("\n"),
    );
  }
}

