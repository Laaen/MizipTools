import "dart:io";
import "package:flutter/material.dart";
import "package:miziptools/data_dir/data_dir.dart";
import "package:miziptools/misc/snackbar.dart";
import "package:miziptools/widgets/basic/container_with_border.dart";
import "package:miziptools/widgets/dump/dialog_read_dump.dart";
import "package:provider/provider.dart";

/// Widget used to select a dump to read
class ReadDump extends StatelessWidget {
  /// Returns a new [ReadDump]
  ReadDump({super.key});

  final _currentDumpChoice = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final dataDir = context.read<DataDir>();

    return ContainerWithBorder(
      child: Column(
        spacing: 15,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text("Read dump", style: TextStyle(fontSize: 18)),
          Column(
            spacing: 15,
            children: [
              DropdownMenu(
                dropdownMenuEntries: getDumpList(dataDir.getFilesList()),
                controller: _currentDumpChoice,
                width: 160,
              ),
              OutlinedButton(
                onPressed: () => readDump(context),
                child: const Text("Read"),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Retreives the list of dump files
  List<DropdownMenuEntry> getDumpList(List<FileSystemEntity> dataDir) {
    return dataDir
        .map(
          (entry) => DropdownMenuEntry(
            value: entry.path,
            label: entry.path.split("/").last.split(".").first,
          ),
        )
        .where((name) => !["uid_save", "debug"].contains(name.label))
        .toList();
  }

  /// Reads the selected dump and creates a [ReadDumpDialog] to display it
  Future<void> readDump(BuildContext context) async {
    if (_currentDumpChoice.text.isEmpty) {
      if (context.mounted) {
        showSnackBar(context, "You must select a file");
      }
      return;
    }

    final dataDir = context.read<DataDir>();

    try {
      final fileContent = dataDir.readFile("${_currentDumpChoice.text}.dump");
      await showDialog<String>(
        context: context,
        builder: (context) {
          return ReadDumpDialog(
            title: _currentDumpChoice.text,
            dataToDisplay: fileContent,
          );
        },
      );
    } on Exception catch (e) {
      if (context.mounted) {
        showSnackBar(context, "Error while reading dump : $e");
      }
    }
  }
}

