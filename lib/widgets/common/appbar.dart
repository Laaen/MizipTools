import 'package:flutter/material.dart';

class MizipToolsAppBar extends StatelessWidget implements PreferredSize{

  const MizipToolsAppBar({super.key});

  @override
  // TODO: Properly implement this
  Widget get child => throw UnimplementedError();

  @override
  Size get preferredSize => Size.fromHeight(100);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      title: Text("MizipTools"),
      bottom: const TabBar(
        tabs: [
          Tab(text: "Balance"),
          Tab(text: "Dumps"),
          Tab(text: "Advanced")
        ] 
      ),
    );
  }

}