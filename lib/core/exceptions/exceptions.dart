/// Custom exception for API errors
class ApiException implements Exception {
  final String message;

  ApiException(this.message);

  @override
  String toString() => 'ApiException: $message';
}

class Failure implements Exception {
  final String message;

  Failure([this.message = 'An Unexpected Error occurred.']);
  @override
  String toString() {
    return message;
  }
}
