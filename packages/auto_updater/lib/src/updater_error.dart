class UpdaterError extends Error {
  UpdaterError(this.message);

  final String message;

  @override
  String toString() {
    return 'UpdaterError: $message';
  }
}
