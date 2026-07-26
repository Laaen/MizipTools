import "package:collection/collection.dart";
import "package:flutter/material.dart";
import "package:google_fonts/google_fonts.dart";
import "package:miziptools/widgets/basic/container_with_border.dart";

/// Dialog used to display a tag dump
class ReadDumpDialog extends StatelessWidget {
  /// Returns a new [ReadDumpDialog] with the given title and data to display
  const ReadDumpDialog({
    required this._title,
    required this._dataToDisplay,
    super.key,
  });

  final String _title;

  final String _dataToDisplay;

  @override
  Widget build(BuildContext context) {
    return ContainerWithBorder(
      child: Column(
        spacing: 20,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            _title,
            style: const TextStyle(fontSize: 18),
          ),
          const Divider(),
          Expanded(
            child: prettyViewer(_dataToDisplay),
          ),
          OutlinedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close"),
          ),
        ],
      ),
    );
  }

  /// Widget used to show the data in a formatted manner
  Widget prettyViewer(String tagData) {
    final items = tagData.split("\n").slices(4).toList();
    return ListView.separated(
      itemBuilder: (context, idx) {
        return Container(
          alignment: AlignmentGeometry.center,
          child: Text(
            style: GoogleFonts.robotoMono(fontSize: 13),
            items[idx].join("\n"),
          ),
        );
      },
      separatorBuilder: (context, idx) => const Divider(
        thickness: 0,
      ),
      itemCount: items.length,
    );
  }
}

