class HttpException implements Exception {
  final int statusCode;
  final String message;

  HttpException(this.statusCode, this.message);

  @override
  String toString() => message;
}

class CustomTimeoutException implements Exception {
  final int statusCode;
  final String message;

  CustomTimeoutException(this.statusCode, this.message);

  @override
  String toString() => message;
}
