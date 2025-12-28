class RetriesExcedeedException implements Exception{
  String cause;
  RetriesExcedeedException(this.cause);
}

class SectorAuthenticationFailed implements Exception{
  String cause;
  SectorAuthenticationFailed(this.cause);
}

class WriteFailedException implements Exception{
  String cause;
  WriteFailedException(this.cause);
}

class WriteRetriesExcedeedException extends WriteFailedException{
  WriteRetriesExcedeedException(super.cause);
}

class WriteTagRemovedException extends WriteFailedException{
  WriteTagRemovedException(super.cause);
}

class WriteSectorAuthenticationFailed extends WriteFailedException{
  WriteSectorAuthenticationFailed(super.cause);
}

class WriteUnknownException extends WriteFailedException{
  WriteUnknownException(super.cause);
}

class ReleaseFailedException implements Exception{
  String cause;
  ReleaseFailedException(this.cause);
}

