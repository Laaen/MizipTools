import 'package:flutter/material.dart';
import "package:miziptools/misc/nfctag.dart";
import "package:miziptools/misc/snackbar.dart";
import "package:miziptools/widgets/basic/containerWithBorder.dart";
import "package:provider/provider.dart";


class TagAdd10 extends StatelessWidget{

  const TagAdd10({super.key});

  @override
  Widget build(BuildContext context) {
    return ContainerWithBorder(
      child: OutlinedButton(onPressed: () => add10(context), child: Text("Add 10\$"),),
    );
  }

  void add10(BuildContext context) async {
    
    showSnackBar(context, "Adding 10\$");
    final tag = context.read<CurrentNFCTag>();

    try {
      final currentBalance = await tag.getBalance();
      final newBalance = double.parse(currentBalance) + 10;
      if (newBalance > 100){
        await tag.setBalance(100.toString());
      } else {
        await tag.setBalance(newBalance.toString());
      }
    } catch (e) {
      showSnackBar(context, "Error while adding 10\$");
    }
    if(context.mounted){
      showSnackBar(context, "Balance changed successfully");  
    }
  }

}