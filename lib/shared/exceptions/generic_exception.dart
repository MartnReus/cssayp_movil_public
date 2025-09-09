class GenericException implements Exception {
  final String message;
  final String code;

  GenericException(this.message, this.code);
}
