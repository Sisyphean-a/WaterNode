class AppException implements Exception {
  const AppException(this.message, {this.cause});

  final String message;
  final Object? cause;

  @override
  String toString() {
    return 'AppException(message: $message, cause: $cause)';
  }
}
