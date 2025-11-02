import 'package:flutter/material.dart';
import 'package:miziptools/widgets/basic/containerWithBorder.dart';

class AdvancedMenu extends StatelessWidget{

  const AdvancedMenu({super.key});

  // TODO: Faire le menu
  @override
  Widget build(BuildContext context) {
    return ContainerWithBorder(child: Text("Salut, je suis dans advanced"));
  }

}