class SyncError implements Exception{
  String cause;
  SyncError(this.cause);
}