import 'package:flutter/material.dart';
import 'package:miziptools/nfc/currentnfctag.dart';
import 'package:miziptools/widgets/advanced/auto_repair.dart';
import 'package:miziptools/widgets/advanced/change_uid.dart';
import 'package:miziptools/widgets/common/tag_data.dart';
import 'package:provider/provider.dart';

class AdvancedMenu extends StatelessWidget{

  const AdvancedMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final tag = context.read<CurrentNFCTag>();
    return ListView(
      children: [
        TagData(),
        if (tag.isPresent()) ChangeUid(),
        if (tag.isPresent() && !tag.isMizipTag()) AutoRepair()
      ],
    );
  }

}