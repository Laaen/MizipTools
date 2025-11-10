import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:miziptools/widgets/basic/container_with_border.dart';
import 'package:google_fonts/google_fonts.dart';

class ReadDumpDialog extends StatelessWidget {

  final String title;
  final String dataToDisplay;

  const ReadDumpDialog ({super.key, required this.title, required this.dataToDisplay});


  @override
  Widget build(BuildContext context) {
    return ContainerWithBorder(child: 
      Column( spacing: 20,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(title, style: TextStyle(fontSize: 18),),
          Divider(),
          Expanded(child: prettyViewer(dataToDisplay),
          ),
          OutlinedButton(onPressed: () => Navigator.pop(context), child: Text("Close"),)
        ]
      )
    );
  }

  Widget prettyViewer(String tagData){
    final items = tagData.split("\n").slices(4).toList();
    return ListView.separated(
      itemBuilder: (context, idx){
        return Container(
          alignment: AlignmentGeometry.center,
          child: Text(
            style: GoogleFonts.robotoMono(fontSize: 13),
            items[idx].join("\n")
          )
        );
      }, 
      separatorBuilder: (context, idx) => Divider(thickness: 0,),
      itemCount: items.length
    );
  }

}