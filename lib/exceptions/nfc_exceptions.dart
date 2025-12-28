class RetriesExcedeedException implements Exception{
  String cause;
  RetriesExcedeedException(this.cause);
}

class SectorAuthenticationFailed implements Exception{
  String cause;
  SectorAuthenticationFailed(this.cause);
}

class ReleaseFailedException implements Exception{
  String cause;
  ReleaseFailedException(this.cause);
}

