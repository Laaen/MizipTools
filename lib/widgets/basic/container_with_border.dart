import 'package:flutter/material.dart';

class ContainerWithBorder extends StatelessWidget{

  final Widget child;

  const ContainerWithBorder({super.key, required this.child});

  @override
  Widget build(BuildContext context) {

    final padding = EdgeInsets.all(20);
    final margin = EdgeInsets.fromLTRB(30, 10, 30, 10);
    final alignment =  Alignment.center;
    final decoration = BoxDecoration(
        color: Theme.of(context).colorScheme.onSecondary, 
        shape: BoxShape.rectangle,
        borderRadius: BorderRadius.all(Radius.circular(20))
    );

    return Container(
      alignment: alignment,
      padding: padding,
      margin: margin,
      decoration: decoration,
      child: child
    );
  }

}