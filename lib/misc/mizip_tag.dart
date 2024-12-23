
import 'package:flutter_nfc_kit/flutter_nfc_kit.dart';

/// Interface to the Mizip Tag
class MizipTag {

  MizipTag({required this.balance, required this.uid});

  String uid;
  String balance;

}