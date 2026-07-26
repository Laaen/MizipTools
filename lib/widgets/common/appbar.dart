import "package:flutter/material.dart";

/// Appbar with title + tabs
class MizipToolsAppBar extends StatelessWidget implements PreferredSizeWidget {
  /// Return a new [MizipToolsAppBar]
  const MizipToolsAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(100);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      title: const Text("MizipTools"),
      bottom: const TabBar(
        tabs: [
          Tab(text: "Balance"),
          Tab(text: "Dumps"),
          Tab(text: "Advanced"),
        ],
      ),
    );
  }
}
