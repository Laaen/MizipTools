import 'package:flutter/material.dart';
import 'package:miziptools/nfc/currentnfctag.dart';
import 'package:miziptools/widgets/auto_repair.dart';
import 'package:miziptools/widgets/change_uid.dart';
import 'package:miziptools/widgets/tag_data.dart';
import 'package:provider/provider.dart';

class AdvancedMenu extends StatelessWidget{

  const AdvancedMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final tag = context.read<CurrentNFCTag>();
    return Column(
      spacing: 20,
      children: [
        TagData(),
        if (tag.isPresent()) ChangeUid(),
        if (tag.isPresent() && !tag.isMizipTag()) AutoRepair()
      ],
    );
  }

}