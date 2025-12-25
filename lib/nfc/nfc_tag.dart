enum NfcTagType{
  mifareClassic,
  other
}

class NfcTag {
  final NfcTagType type;
  final String id;

  NfcTag({required this.type, required this.id});

}