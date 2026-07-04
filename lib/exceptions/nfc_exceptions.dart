import "package:miziptools/nfc/nfc_adapter.dart";

/// Thrown if the maximum number of retries during communication with the tag
/// is reached
class RetriesExcedeedException implements Exception {
  /// Creates a [RetriesExcedeedException] with the given cause
  RetriesExcedeedException(this.cause);

  /// Why the exception was raised
  String cause;
}

/// Thrown if the authentication with a sector failed
/// Multiple causes are possible (communication failure, incorrect keys, ...)
class SectorAuthenticationFailed implements Exception {
  /// Creates a [SectorAuthenticationFailed] with the given cause
  SectorAuthenticationFailed(this.cause);

  /// Why the exception was raised
  String cause;
}

/// Thrown if the [NfcAdapter] has an issue during the tag release
class ReleaseFailedException implements Exception {
  /// Creates a [ReleaseFailedException] with the given cause
  ReleaseFailedException(this.cause);

  /// Why the exception was raised
  String cause;
}

/// Thrown if something happens during a write operation on sector 0 of the tag
class WriteSectorZeroException implements Exception {
  /// Creates a [WriteSectorZeroException] with the given cause
  WriteSectorZeroException(this.cause);

  /// Why the exception was raised
  String cause;
}
