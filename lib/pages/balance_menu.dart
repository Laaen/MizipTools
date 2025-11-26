import 'package:flutter/material.dart';
import 'package:miziptools/nfc/currentnfctag.dart';
import 'package:miziptools/widgets/balance/tag_balance.dart';
import 'package:miziptools/widgets/balance/tag_add_10.dart';
import 'package:miziptools/widgets/common/tag_data.dart';
import 'package:provider/provider.dart';

class BalanceMenu extends StatelessWidget{

  const BalanceMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final tag = context.read<CurrentNFCTag>();
    return ListView(
      children: [
        TagData(),
        if (tag.isPresent() && tag.isMizipTag()) TagBalance(),
        if (tag.isPresent() && tag.isMizipTag()) TagAdd10(),
      ],
    );
  }

}