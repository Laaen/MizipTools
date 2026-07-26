import "package:flutter/material.dart";

/// Basic widget : Container with a rounded rectangle shape
/// It will have a widget in the center of it
class ContainerWithBorder extends StatelessWidget {
  /// Returns a new [ContainerWithBorder] with the given widget
  const ContainerWithBorder({required this.child, super.key});

  /// The widget which will be displayed in the center
  final Widget child;

  @override
  Widget build(BuildContext context) {
    const padding = EdgeInsets.all(20);
    const margin = EdgeInsets.fromLTRB(30, 10, 30, 10);
    const alignment = Alignment.center;
    final decoration = BoxDecoration(
      color: Theme.of(context).colorScheme.onSecondary,
      borderRadius: const BorderRadius.all(Radius.circular(20)),
    );

    return Container(
      alignment: alignment,
      padding: padding,
      margin: margin,
      decoration: decoration,
      child: child,
    );
  }
}

