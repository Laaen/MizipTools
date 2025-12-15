import 'package:flutter/material.dart';
import 'package:miziptools/data_dir/data_dir.dart';
import 'package:miziptools/nfc/currentnfctag.dart';
import 'package:miziptools/widgets/dump/dump_tag.dart';
import 'package:miziptools/widgets/dump/read_dump.dart';
import 'package:miziptools/widgets/common/tag_data.dart';
import 'package:miziptools/widgets/dump/write_from_dump.dart';
import 'package:provider/provider.dart';

class DumpMenu extends StatelessWidget{

  const DumpMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final tag = context.read<CurrentNFCTag>();
    return Consumer<DataDir>(builder:(context, value, child) {
      return ListView(
        children: [
          TagData(),
          if (tag.isPresent()) DumpTag(),
          if (tag.isPresent()) WriteFromDump(),
          ReadDump(),
        ],
      );},
    );
  }

}