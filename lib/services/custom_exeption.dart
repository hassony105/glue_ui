/// A custom exception class for handling specific errors in the application.
///
/// This class implements the standard [Exception] interface and allows for
/// providing a user-friendly message along with an optional hidden message
/// for debugging purposes.
class CustomException implements Exception {
  /// The primary message of the exception, typically displayed to the user.
  late final String message;

  /// An optional hidden message that can provide more technical details for debugging.
  final String? hiddenMessage;

  /// Creates a [CustomException].
  ///
  /// The [message] can be a single object (which will be converted to a string)
  /// or a [List] of objects (which will be joined with newlines). If no message
  /// is provided, a default 'Unimplemented Error' message is used.
  ///
  /// The [hiddenMessage] is optional and intended for internal use or logging.
  CustomException({Object? message, this.hiddenMessage}) {
    if (message == null) {
      this.message = 'Unimplemented Error';
    } else if (message is List) {
      this.message = message.join('\n');
    } else {
      this.message = message.toString();
    }
  }

  /// Returns the [message] of the exception as its string representation.
  @override
  String toString() {
    return message;
  }
}
