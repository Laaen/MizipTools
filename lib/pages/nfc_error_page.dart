import 'package:flutter/material.dart';
import 'package:miziptools/widgets/basic/container_with_border.dart';

class NfcErrorPage extends StatelessWidget {
  const NfcErrorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: Text("MizipTools"),
        ),
        body: Column(
          children: [
            Expanded(child: Container()),
            ContainerWithBorder(
              child: Column(
                spacing: 15,
                children: [
                  Text(
                    "NFC not enabled",
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
                  ),
                  Text(
                    "NFC is either not enabled or not supported on this device\nGo to your device settings to enable it and restart the application",
                  ),
                ],
              ),
            ),
            Expanded(child: Container()),
          ],
        ));
  }
}
