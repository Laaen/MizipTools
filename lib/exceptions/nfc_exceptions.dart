class ReadFailedException implements Exception{
  String cause;
  ReadFailedException(this.cause);
}

class ReadRetriesExcedeedException extends ReadFailedException{
  ReadRetriesExcedeedException(super.cause);
}

class ReadSectorAuthenticationFailed extends ReadFailedException{
  ReadSectorAuthenticationFailed(super.cause);
}

class ReadTagRemovedException extends ReadFailedException{
  ReadTagRemovedException(super.cause);
}

class ReadUnknownException extends ReadFailedException{
  ReadUnknownException(super.cause);
}

class WriteFailedException implements Exception{
  String cause;
  WriteFailedException(this.cause);
}

class WriteRetriesExcedeedException extends WriteFailedException{
  WriteRetriesExcedeedException(super.cause);
}

class WriteTagRemovedException extends ReadFailedException{
  WriteTagRemovedException(super.cause);
}

class WriteSectorAuthenticationFailed extends WriteFailedException{
  WriteSectorAuthenticationFailed(super.cause);
}

class WriteUnknownException extends ReadFailedException{
  WriteUnknownException(super.cause);
}

class ReleaseFailedException implements Exception{
  String cause;
  ReleaseFailedException(this.cause);
}

